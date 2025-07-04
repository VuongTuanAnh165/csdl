# predict_demo.py
import pandas as pd
import joblib

# 1. Load mô hình và danh sách cột
model = joblib.load("slow_query_model.pkl")
model_features = joblib.load("model_features.pkl")

# 2. Nhập đặc trưng truy vấn cần dự đoán
# ⚠️ CHỈ SỬA GIÁ TRỊ BÊN DƯỚI (phải đủ cột giống lúc train)
new_query = {
    'rows_examined': 25000,   # Số lượng dòng được quét (càng lớn càng có khả năng truy vấn chậm)
    'uses_index': 0,          # Có sử dụng index không? (1: Có, 0: Không)
    'ALL': 1,                 # Sử dụng kiểu truy xuất ALL (full table scan)? (1: Có, 0: Không)
    'ref': 0,                 # Sử dụng kiểu truy xuất ref? (1: Có, 0: Không)
    'const': 0,               # Sử dụng kiểu truy xuất const? (1: Có, 0: Không)
    'index': 0,               # Sử dụng kiểu truy xuất index? (1: Có, 0: Không)
    'range': 0                # Sử dụng kiểu truy xuất range? (1: Có, 0: Không)
}

# 3. Đưa về DataFrame đúng định dạng
new_data = pd.DataFrame([new_query], columns=model_features)

# 4. Dự đoán
result = model.predict(new_data)[0]
print("📢 Truy vấn này:", "CHẬM ❌" if result else "NHANH ✅")
