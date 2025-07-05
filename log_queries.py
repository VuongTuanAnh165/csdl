import time
import pymysql
import csv

# Kết nối CSDL
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='',
    db='employees',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

def extract_features(cursor, query, exec_time):
    cursor.execute(f"EXPLAIN {query}")
    explain = cursor.fetchall()

    total_rows = sum(row.get('rows', 0) for row in explain)
    uses_index = any(row.get('key') is not None for row in explain)
    type_set = {row['type'] for row in explain}

    # Đặc trưng bổ sung từ câu query
    query_lower = query.lower()
    has_like = int("like" in query_lower)
    has_group = int("group by" in query_lower)
    has_join = int("join" in query_lower)

    return {
        'rows_examined': total_rows,
        'uses_index': int(uses_index),
        'types': ','.join(type_set),
        'has_like': has_like,
        'has_group': has_group,
        'has_join': has_join,
        'is_slow': int(exec_time > 1)
    }

with conn.cursor() as cursor, open("query_log.csv", "w", newline='', encoding="utf-8") as csvfile:
    fieldnames = [
        'query', 'exec_time_sec', 'rows_examined', 'uses_index', 'types',
        'has_like', 'has_group', 'has_join', 'is_slow'
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    with open("queries.sql", "r", encoding="utf-8") as f:
        sql = f.read()
        queries = [q.strip() for q in sql.split(';') if q.strip()]

        for query in queries:
            try:
                start = time.time()
                cursor.execute(query)
                _ = cursor.fetchall()
                end = time.time()

                exec_time = round(end - start, 4)
                features = extract_features(cursor, query, exec_time)
                features['query'] = query
                features['exec_time_sec'] = exec_time

                writer.writerow(features)
                print(f"[✓] Done: {query[:50]}...")

            except Exception as e:
                print(f"[X] Error: {query[:50]}... → {e}")

conn.close()
