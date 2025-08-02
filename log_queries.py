import time
import pymysql
import csv
import re

# Kết nối CSDL
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='',
    db='employees',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

def extract_features(cursor, query, exec_time, status):
    features = {
        'query_raw': query,
        'exec_time_sec': round(exec_time, 4),
        'status': status,
        'rows_examined': 0,
        'uses_index': 0,
        'types': '',
        'num_tables': 0,
        'has_like': 0,
        'has_group': 0,
        'has_join': 0,
        'has_order': 0,
        'has_limit': 0,
        'has_distinct': 0,
        'is_slow': 0
    }

    try:
        cursor.execute(f"EXPLAIN {query}")
        explain = cursor.fetchall()

        features['rows_examined'] = sum(row.get('rows', 0) for row in explain)
        features['uses_index'] = int(any(row.get('key') for row in explain))
        features['types'] = ','.join({row['type'] for row in explain})

    except Exception as ex:
        features['status'] = f"EXPLAIN_ERROR: {ex}"
        return features

    # Đặc trưng cú pháp từ câu query
    q = query.lower()
    features['has_like'] = int("like" in q)
    features['has_group'] = int("group by" in q)
    features['has_join'] = int("join" in q)
    features['has_order'] = int("order by" in q)
    features['has_limit'] = int("limit" in q)
    features['has_distinct'] = int("distinct" in q)
    features['num_tables'] = len(re.findall(r'from|join', q))
    features['is_slow'] = int(exec_time > 1)

    return features

with conn.cursor() as cursor, open("query_log.csv", "w", newline='', encoding="utf-8") as csvfile:
    fieldnames = [
        'query_raw', 'exec_time_sec', 'status',
        'rows_examined', 'uses_index', 'types', 'num_tables',
        'has_like', 'has_group', 'has_join',
        'has_order', 'has_limit', 'has_distinct',
        'is_slow'
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    with open("queries.sql", "r", encoding="utf-8") as f:
        sql = f.read()
        queries = [q.strip() for q in sql.split(';') if q.strip()]

        for query in queries:
            start = time.time()
            status = "OK"
            exec_time = 0

            try:
                cursor.execute(query)
                _ = cursor.fetchall()
                exec_time = time.time() - start

            except Exception as e:
                status = f"ERROR: {e}"

            features = extract_features(cursor, query, exec_time, status)
            writer.writerow(features)

            print(f"[✓] Ghi log: {query[:60]}...")

conn.close()
print("[✓] Hoàn tất ghi log vào query_log.csv")
