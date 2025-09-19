# predict_demo.py
# ✅ Dự đoán truy vấn SQL mới bằng mô hình XGBoost đã huấn luyện

import pandas as pd
import joblib
import os
import numpy as np

# ==== 1. Tải mô hình và đặc trưng ====
if not os.path.exists("slow_query_model.pkl") or not os.path.exists("model_features.pkl"):
    print("❌ Không tìm thấy mô hình. Hãy chạy train_model.py trước.")
    exit(1)

model = joblib.load("slow_query_model.pkl")
model_features = joblib.load("model_features.pkl")

# ==== 2. Cấu hình chế độ input ====
USE_BATCH_CSV = False  # 👈 Đổi thành True nếu muốn test nhiều truy vấn từ sample_queries.csv

if USE_BATCH_CSV and os.path.exists("sample_queries.csv"):
    df_input = pd.read_csv("sample_queries.csv")
    print(f"\n📄 Đang dự đoán {len(df_input)} truy vấn từ sample_queries.csv")
else:
    # === Truy vấn mẫu thủ công ===
    new_query = {
        'rows_examined': 25000,
        'uses_index': 0,
        'num_tables': 3,
        'num_predicates': 2,
        'num_subqueries': 1,
        'has_like': 1,
        'has_group': 1,
        'has_join': 1,
        'has_order': 1,
        'has_limit': 0,
        'has_distinct': 0,
        'has_function': 1,
        'exec_time_sec': 1.8,   # 👈 nếu biết thời gian thực thi, có thể nhập vào
        'ALL': 1, 'index': 0, 'ref': 0, 'const': 0, 'eq_ref': 0, 'range': 0
    }
    df_input = pd.DataFrame([new_query])

# ==== 3. Xử lý bổ sung feature ====
if "exec_time_sec" in df_input.columns:
    df_input["exec_time_log"] = np.log1p(df_input["exec_time_sec"])
else:
    # Nếu không có exec_time, gán mặc định log = 0
    df_input["exec_time_log"] = 0

# ==== 4. Đảm bảo đầy đủ cột ====
for col in model_features:
    if col not in df_input.columns:
        df_input[col] = 0

# Giữ đúng thứ tự feature
X_input = df_input[model_features]

# ==== 5. Dự đoán ====
preds = model.predict(X_input)
probas = model.predict_proba(X_input)[:, 1]

# Kết quả
df_result = df_input.copy()
df_result["prediction"] = preds
df_result["proba_slow"] = probas

# ==== 6. In kết quả ====
for i, row in df_result.iterrows():
    print(f"\n🔎 Truy vấn {i+1}:")
    print(row[model_features])
    print(f"📈 Xác suất bị chậm: {row['proba_slow']:.2%}")
    print("📢 Kết luận:", "❌ CHẬM" if row['prediction'] else "✅ NHANH")

# ==== 7. Lưu kết quả (tuỳ chọn) ====
os.makedirs("figures", exist_ok=True)
df_result.to_csv("figures/prediction_result.csv", index=False)
print("\n✅ Đã lưu kết quả dự đoán vào figures/prediction_result.csv")
