import pandas as pd
import joblib

# Load mô hình và danh sách đặc trưng
model = joblib.load("slow_query_model.pkl")
model_features = joblib.load("model_features.pkl")

# Nhập đặc trưng truy vấn
new_query = {
    'rows_examined': 15000,    # Số hàng được kiểm tra (cao = chậm)
    'uses_index': 0,           # Sử dụng index (0: không, 1: có)
    'has_like': 1,             # Có sử dụng toán tử LIKE (0: không, 1: có)
    'has_group': 1,            # Có sử dụng GROUP BY (0: không, 1: có)
    'has_join': 1,             # Có sử dụng JOIN (0: không, 1: có)
    'ALL': 1,                  # Phương pháp ALL - quét toàn bộ bảng (0: không, 1: có)
    'index': 0,                # Phương pháp index - quét index (0: không, 1: có)
    'ref': 0,                  # Phương pháp ref - truy cập qua index (0: không, 1: có)
    'const': 0,                # Phương pháp const - truy cập hằng số (0: không, 1: có)
    'eq_ref': 1                # Phương pháp eq_ref - truy cập unique index (0: không, 1: có)
}

# Tự thêm các đặc trưng bị thiếu
for col in model_features:
    if col not in new_query:
        new_query[col] = 0

# Sắp xếp đúng thứ tự
new_data = pd.DataFrame([new_query])[model_features]

# Dự đoán
result = model.predict(new_data)[0]
print("📢 Truy vấn này:", "CHẬM ❌" if result else "NHANH ✅")
