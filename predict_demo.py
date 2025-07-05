import pandas as pd
import joblib

# Load mô hình và danh sách đặc trưng
model = joblib.load("slow_query_model.pkl")
model_features = joblib.load("model_features.pkl")

# Nhập đặc trưng truy vấn
new_query = {
    'rows_examined': 15000,
    'uses_index': 0,
    'has_like': 1,
    'has_group': 1,
    'has_join': 1,
    'ALL': 1,
    'index': 0,
    'ref': 0,
    'const': 0,
    'eq_ref': 1
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
