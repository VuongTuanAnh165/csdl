# suggest_fix.py
# ✅ Gợi ý tối ưu hóa truy vấn SQL dựa trên đặc trưng đã khai phá
# ✅ Dự đoán nhanh/chậm và lưu kết quả ra file phục vụ báo cáo

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
USE_FROM_LOG = True  # 👈 Đổi thành False để nhập tay

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
    query_features = {
        'rows_examined': 30000,
        'uses_index': 0,
        'num_tables': 3,
        'has_like': 1,
        'has_group': 1,
        'has_join': 1,
        'has_order': 1,
        'has_limit': 0,
        'has_distinct': 0,
        'ALL': 1,
        'index': 0,
        'ref': 0,
        'const': 0,
        'eq_ref': 0
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
        msg = "- 🔍 Truy vấn không sử dụng chỉ mục. Kiểm tra điều kiện WHERE hoặc thêm INDEX phù hợp."
        print(msg)
        suggestions.append("Bổ sung chỉ mục")

    if query_features.get('has_join'):
        msg = "- 🔄 Truy vấn có JOIN nhiều bảng. Đảm bảo các khóa ngoại có chỉ mục."
        print(msg)
        suggestions.append("Tối ưu JOIN")

    if query_features.get('has_like'):
        msg = "- 🔠 LIKE '%...%' gây quét toàn bảng. Tránh nếu không có chỉ mục."
        print(msg)
        suggestions.append("Hạn chế LIKE")

    if query_features.get('has_group'):
        msg = "- 📊 GROUP BY có thể chậm với bảng lớn. Dùng LIMIT nếu không cần toàn bộ."
        print(msg)
        suggestions.append("Giảm GROUP BY")

    if query_features.get('has_order') and not query_features.get('has_limit'):
        msg = "- 🪙 ORDER BY không kèm LIMIT có thể làm truy vấn toàn bảng."
        print(msg)
        suggestions.append("ORDER BY nên kèm LIMIT")

    if query_features.get('rows_examined', 0) > 20000:
        msg = "- 🧱 Truy vấn xử lý quá nhiều dòng. Xem lại điều kiện WHERE hoặc chia nhỏ truy vấn."
        print(msg)
        suggestions.append("Giảm rows_examined")

else:
    print("\n✅ Truy vấn đã được tối ưu tốt. Không cần cải tiến.")

# ==== 5. Lưu kết quả ra file ====
os.makedirs("figures", exist_ok=True)
result_path = "figures/suggest_result.csv"

with open(result_path, "w", newline='', encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["Truy vấn", "Xác suất chậm", "Kết luận", "Gợi ý"])
    writer.writerow([
        raw_query[:100] + "..." if len(raw_query) > 100 else raw_query,
        f"{proba:.2%}",
        "CHẬM" if result else "NHANH",
        "; ".join(suggestions) if suggestions else "Không cần cải tiến"
    ])

print(f"\n📝 Đã lưu kết quả vào: {result_path}")

# ==== 5b. Lưu chi tiết gợi ý ====
detail_path = "figures/suggest_detail.txt"
with open(detail_path, "w", encoding="utf-8") as f:
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
print(f"📝 Đã lưu gợi ý chi tiết vào: {detail_path}")