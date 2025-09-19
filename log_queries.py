import time
import pymysql
import csv
import re
import pandas as pd

"""
Ghi log thực thi các truy vấn SQL và trích xuất đặc trưng phục vụ phân tích/huấn luyện.

Luồng chính:
- Đọc toàn bộ truy vấn trong file `queries.sql` (bỏ comment, gộp dòng, tách theo dấu ';').
- Thiết lập timeout mỗi truy vấn, thực thi, đo `exec_time_sec`, đánh dấu `timeout_flag`/`status`.
- Dùng `EXPLAIN` để lấy thông tin `rows_examined`, `uses_index`, `types`.
- Suy ra các đặc trưng cú pháp: has_like/has_join/...; đếm số bảng, điều kiện WHERE, subquery.
- Ghi từng bản ghi vào `query_log.csv`, sau đó gán nhãn `is_slow` theo median (timeout luôn là chậm).
"""

# Cấu hình timeout
TIMEOUT = 10.0  # giây

# Kết nối CSDL
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='',
    db='employees',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

def extract_features(cursor, query, exec_time, status, timeout_flag):
    """Trích xuất đặc trưng từ một truy vấn SQL.

    Tham số:
        cursor: Cursor MySQL đã kết nối.
        query (str): Câu truy vấn gốc.
        exec_time (float): Thời gian thực thi (giây).
        status (str): Trạng thái thực thi (OK / TIMEOUT / ERROR: ...).
        timeout_flag (int): 1 nếu truy vấn bị timeout, ngược lại 0.

    Trả về:
        dict: Tập đặc trưng đã suy ra, bao gồm thông tin từ EXPLAIN nếu có.
    """
    # Ý nghĩa từng đặc trưng:
    # - query_raw: Câu truy vấn gốc (dạng text) để đối chiếu/hiển thị.
    # - exec_time_sec: Thời gian thực thi (giây) đo được khi chạy truy vấn.
    # - status: Trạng thái chạy (OK/TIMEOUT/ERROR:...).
    # - rows_examined: Tổng số dòng ước lượng đã quét theo EXPLAIN (cộng từng dòng).
    # - uses_index: Có sử dụng chỉ mục ở bất kỳ bước nào trong kế hoạch (1) hay không (0).
    # - types: Danh sách kiểu join/scan (MySQL `type`) như ALL, index, ref, eq_ref, range...
    # - num_tables: Số lượng bảng tham gia (đếm FROM/JOIN).
    # - num_predicates: Số điều kiện lọc ước lượng (WHERE/AND/OR).
    # - num_subqueries: Số subquery lồng nhau (SL SELECT - 1).
    # - has_like/has_group/has_join/has_order/has_limit/has_distinct/has_function:
    #   Cờ nhị phân 0/1 cho thấy truy vấn có dùng các cấu trúc cú pháp này.
    # - timeout_flag: 1 nếu truy vấn bị timeout theo cấu hình, ngược lại 0.
    # - is_slow: Nhãn chậm (1) hay nhanh (0); sẽ cập nhật sau khi ghi log xong.
    features = {
        'query_raw': query,
        'exec_time_sec': round(exec_time, 4),
        'status': status,
        'rows_examined': 0,
        'uses_index': 0,
        'types': '',
        'num_tables': 0,
        'num_predicates': 0,
        'num_subqueries': 0,
        'has_like': 0,
        'has_group': 0,
        'has_join': 0,
        'has_order': 0,
        'has_limit': 0,
        'has_distinct': 0,
        'has_function': 0,
        'timeout_flag': timeout_flag,
        'is_slow': 0
    }

    # Chuẩn hoá câu truy vấn về chữ thường để dò mẫu
    q = query.lower()
    features['has_like'] = int("like" in q)
    features['has_group'] = int("group by" in q)
    features['has_join'] = int("join" in q)
    features['has_order'] = int("order by" in q)
    features['has_limit'] = int("limit" in q)
    features['has_distinct'] = int("distinct" in q)
    features['has_function'] = int(bool(re.search(
        r'\b(year|upper|lower|length|substr|substring|rand|date_format|timestampdiff|now|ifnull)\b', q)))
    features['num_tables'] = len(re.findall(r'from|join', q))
    features['num_predicates'] = len(re.findall(r'\bwhere\b|\band\b|\bor\b', q))
    features['num_subqueries'] = max(0, q.count("select") - 1)

    try:
        # Lấy kế hoạch thực thi để ước lượng số dòng quét và việc dùng chỉ mục
        cursor.execute(f"EXPLAIN {query}")
        explain = cursor.fetchall()
        features['rows_examined'] = sum(int(row.get('rows') or 0) for row in explain)
        features['uses_index'] = int(any(row.get('key') for row in explain))
        features['types'] = ','.join(sorted({str(row.get('type') or '') for row in explain}))
    except Exception as ex:
        features['status'] = f"EXPLAIN_ERROR: {ex}"

    return features


# === Ghi log ===
with conn.cursor() as cursor, open("query_log.csv", "w", newline='', encoding="utf-8") as csvfile:
    fieldnames = [
        'query_raw', 'exec_time_sec', 'status',
        'rows_examined', 'uses_index', 'types',
        'num_tables', 'num_predicates', 'num_subqueries',
        'has_like', 'has_group', 'has_join',
        'has_order', 'has_limit', 'has_distinct', 'has_function',
        'timeout_flag',
        'is_slow'
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # Đọc file SQL
    with open("queries.sql", "r", encoding="utf-8") as f:
        sql_lines = f.readlines()

    # Bỏ comment và dòng trống
    # Lưu ý: chúng ta gộp tất cả dòng thành một chuỗi để tách theo ';'
    # nên các query nhiều dòng vẫn được nhận diện đúng.
    sql_clean = [line.strip() for line in sql_lines if line.strip() and not line.strip().startswith("--")]
    sql = " ".join(sql_clean)
    raw_queries = [q.strip() for q in sql.split(";") if q.strip()]
    print(f"📌 Đọc được {len(raw_queries)} query trong file queries.sql")

    # Lọc query SELECT
    # Tránh chạy EXPLAIN/SELECT lồng EXPLAIN, chỉ lấy truy vấn bắt đầu bằng SELECT.
    queries = []
    for q in raw_queries:
        q_low = q.lower()
        if not q_low.startswith("select"): continue
        if q_low.startswith("explain"): continue
        queries.append(q.strip())

    print(f"📌 Sau khi lọc còn {len(queries)} query SELECT hợp lệ")

    # Ghi log từng query
    for query in queries:
        status = "OK"
        exec_time = 0
        timeout_flag = 0
        try:
            # set timeout cho session (ms)
            cursor.execute(f"SET SESSION max_execution_time={int(TIMEOUT*1000)}")

            start = time.time()
            cursor.execute(query)
            _ = cursor.fetchall()
            exec_time = time.time() - start

        except Exception as e:
            if "execution was interrupted" in str(e).lower():
                status = "TIMEOUT"
                exec_time = TIMEOUT
                timeout_flag = 1
            else:
                status = f"ERROR: {e}"
                exec_time = TIMEOUT
                timeout_flag = 1

        features = extract_features(cursor, query, exec_time, status, timeout_flag)

        if timeout_flag == 1:
            # Timeout được coi là chậm bất kể median
            features["is_slow"] = 1

        writer.writerow(features)
        print(f"[✓] Ghi log: {query[:60]}... | time={exec_time:.4f}s | status={status} | timeout_flag={timeout_flag}")

conn.close()

# === Gán nhãn nhanh/chậm theo median (không bỏ record) ===
# Quy tắc: timeout = chậm; còn lại so sánh với median của toàn bộ exec_time_sec.
df = pd.read_csv("query_log.csv")
if not df.empty:
    median = df["exec_time_sec"].median()

    # Query timeout luôn coi là chậm (1)
    df["is_slow"] = df.apply(
        lambda row: 1 if row["timeout_flag"] == 1 else int(row["exec_time_sec"] >= median),
        axis=1
    )

    df.to_csv("query_log.csv", index=False)

    print(f"[✓] Đã cập nhật nhãn is_slow (median={median:.4f}s, timeout=chậm)")
    print(f"📊 Phân phối nhãn:\n{df['is_slow'].value_counts(normalize=True)}")
    print(f"📊 Số query timeout_flag=1: {df['timeout_flag'].sum()}")
else:
    print("⚠️ Không có dữ liệu trong query_log.csv")

print("[✓] Hoàn tất ghi log vào query_log.csv")
