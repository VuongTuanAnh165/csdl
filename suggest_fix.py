# suggest_fix.py
# ✅ Gợi ý tối ưu hóa truy vấn SQL dựa trên đặc trưng đã khai phá
# ✅ Phiên bản mở rộng bám sát các feature mới
"""
Sinh gợi ý tối ưu hoá cho một truy vấn dựa trên đặc trưng và model đã train.

Cách dùng:
- Lấy truy vấn từ `query_log.csv` theo id hoặc tìm gần đúng (USE_FROM_LOG=True).
- Hoặc nhập tay một bộ đặc trưng tối thiểu tương thích `model_features.pkl`.

Kết quả in ra màn hình, đồng thời lưu tóm tắt vào `figures/suggest_summary.csv`
và chi tiết từng truy vấn vào `figures/suggest_detail.txt`.
"""

import pandas as pd
import joblib
import os
import difflib
import csv

# ==== 1. Kiểm tra mô hình đã huấn luyện ====
if not os.path.exists("slow_query_model.pkl") or not os.path.exists("model_features.pkl"):
    print("❌ Không tìm thấy mô hình. Hãy chạy train_model.py trước.")
    exit(1)

model = joblib.load("slow_query_model.pkl")
features = joblib.load("model_features.pkl")

# ==== 2. Chọn cách nhập truy vấn ====
USE_FROM_LOG = True  # 👈 Đổi thành False nếu muốn nhập tay

if USE_FROM_LOG:
    if not os.path.exists("query_log.csv"):
        print("❌ Không tìm thấy file query_log.csv. Hãy chạy log_queries.py trước.")
        exit(1)

    df = pd.read_csv("query_log.csv")
    df = df[df['status'] == 'OK'].copy()

    print("\n📝 Có", len(df), "truy vấn trong log. Bạn có thể:")
    print(" - Nhập query_id (số dòng từ 0)")
    print(" - Hoặc nhập chuỗi gần đúng để tìm truy vấn")

    user_input = input("🔍 Nhập query_id hoặc một phần truy vấn: ").strip()

    try:
        idx = int(user_input)
        query_row = df.iloc[idx]
    except ValueError:
        matches = difflib.get_close_matches(user_input, df['query_raw'].astype(str), n=1)
        if not matches:
            print("❌ Không tìm thấy truy vấn phù hợp.")
            exit(1)
        query_row = df[df['query_raw'] == matches[0]].iloc[0]

    print("\n🔎 Truy vấn được chọn:")
    print(query_row['query_raw'])

    query_features = {col: query_row[col] if col in query_row else 0 for col in features}
    raw_query = query_row['query_raw']

else:
    # ==== Nhập tay đặc trưng ====
    raw_query = "[Nhập tay]"
    # Ý nghĩa đặc trưng tương tự predict_demo.py; đảm bảo tương thích với model_features.pkl
    query_features = {
        'rows_examined': 50000,
        'uses_index': 0,
        'num_tables': 3,
        'num_predicates': 5,
        'num_subqueries': 2,
        'has_like': 1,
        'has_group': 1,
        'has_join': 1,
        'has_order': 1,
        'has_limit': 0,
        'has_distinct': 1,
        'has_function': 1,
        'ALL': 1, 'index': 0, 'ref': 0, 'const': 0, 'eq_ref': 0
    }

    for f in features:
        if f not in query_features:
            query_features[f] = 0

# ==== 3. Dự đoán ====
X = pd.DataFrame([query_features])[features]
result = model.predict(X)[0]
proba = model.predict_proba(X)[0][1]

print(f"\n📈 Xác suất truy vấn bị chậm: {proba:.2%}")
print("📢 Dự đoán:", "❌ Truy vấn CHẬM" if result else "✅ Truy vấn NHANH")

# ==== 4. Gợi ý tối ưu hóa nếu chậm ====
suggestions = []

if result:
    print("\n💡 GỢI Ý CẢI TIẾN TRUY VẤN:")

    if query_features.get('uses_index', 1) == 0:
        msg = "- 🔍 Truy vấn không sử dụng chỉ mục. Cân nhắc thêm INDEX hoặc COVERING INDEX."
        print(msg)
        suggestions.append(msg)

    if query_features.get('has_join'):
        msg = "- 🔄 JOIN nhiều bảng: kiểm tra index trên khóa ngoại, tránh JOIN thừa."
        print(msg)
        suggestions.append(msg)

    if query_features.get('has_like'):
        msg = "- 🔠 LIKE '%...%': gây full-scan. Dùng FULLTEXT INDEX hoặc ElasticSearch."
        print(msg)
        suggestions.append(msg)

    if query_features.get('has_group'):
        msg = "- 📊 GROUP BY: thêm index hoặc dùng pre-aggregated table."
        print(msg)
        suggestions.append(msg)

    if query_features.get('has_order') and not query_features.get('has_limit'):
        msg = "- 🪙 ORDER BY không có LIMIT: nên thêm LIMIT hoặc index phù hợp."
        print(msg)
        suggestions.append(msg)

    # Các ngưỡng dưới đây là kinh nghiệm/điểm gợi ý, có thể điều chỉnh theo dữ liệu
    if query_features.get('rows_examined', 0) > 20000:
        msg = "- 🧱 Quét quá nhiều dòng. Thêm điều kiện WHERE, partition table hoặc index."
        print(msg)
        suggestions.append(msg)

    if query_features.get('num_predicates', 0) > 5:
        msg = "- 🧮 Quá nhiều điều kiện WHERE: xem xét tối ưu filter hoặc tách truy vấn."
        print(msg)
        suggestions.append(msg)

    if query_features.get('num_subqueries', 0) > 1:
        msg = "- 🔁 Subquery lồng nhau: thay bằng JOIN hoặc WITH (CTE)."
        print(msg)
        suggestions.append(msg)

    if query_features.get('has_function', 0) == 1:
        msg = "- 📐 Hàm trên cột (VD: YEAR(date)): tránh để index có tác dụng."
        print(msg)
        suggestions.append(msg)

else:
    print("\n✅ Truy vấn đã được tối ưu. Không cần cải tiến.")

# ==== 5. Lưu kết quả ra file ====
os.makedirs("figures", exist_ok=True)

# Lưu dạng CSV append nhiều truy vấn
result_path = "figures/suggest_summary.csv"
file_exists = os.path.exists(result_path)

with open(result_path, "a", newline='', encoding="utf-8") as f:
    writer = csv.writer(f)
    if not file_exists:
        writer.writerow(["Truy vấn", "Xác suất chậm", "Kết luận", "Gợi ý"])
    writer.writerow([
        raw_query[:100] + "..." if len(raw_query) > 100 else raw_query,
        f"{proba:.2%}",
        "CHẬM" if result else "NHANH",
        "; ".join(suggestions) if suggestions else "Không cần cải tiến"
    ])

print(f"\n📝 Đã lưu kết quả vào: {result_path}")

# ==== 6. Lưu chi tiết từng truy vấn ====
detail_path = "figures/suggest_detail.txt"
with open(detail_path, "a", encoding="utf-8") as f:
    f.write("\n===========================\n")
    f.write("Truy vấn được phân tích:\n")
    f.write(raw_query + "\n\n")
    f.write(f"Xác suất chậm: {proba:.2%}\n")
    f.write(f"Kết luận: {'CHẬM' if result else 'NHANH'}\n\n")
    if suggestions:
        f.write("Các gợi ý tối ưu:\n")
        for s in suggestions:
            f.write(f"- {s}\n")
    else:
        f.write("Không cần cải tiến.\n")
