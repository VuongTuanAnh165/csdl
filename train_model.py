# train_model.py
# ✅ Huấn luyện mô hình XGBoost phân loại truy vấn SQL nhanh/chậm từ log đã khai phá

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
import xgboost as xgb
import matplotlib.pyplot as plt
import joblib
import os
import sys

# ==== 1. Đọc dữ liệu log từ file ====
log_path = "query_log.csv"
if not os.path.exists(log_path):
    print("❌ Không tìm thấy file query_log.csv. Hãy chạy log_queries.py trước.")
    sys.exit(1)

df = pd.read_csv(log_path)
df = df[df['status'] == 'OK'].copy()  # Lọc bỏ truy vấn lỗi

# ==== 2. Loại bỏ truy vấn dị biệt (outliers) ====
q95 = df["exec_time_sec"].quantile(0.95)
df = df[df["exec_time_sec"] <= q95]
print(f"✅ Đã loại bỏ các truy vấn có exec_time_sec > {q95:.2f}s (top 5%)")

# ==== 3. Kiểm tra nhãn mục tiêu ====
if 'is_slow' not in df.columns or df['is_slow'].nunique() < 2:
    print("⚠️ Cần cả truy vấn nhanh và chậm. Hãy kiểm tra lại log.")
    sys.exit(1)

print("\n📊 Phân phối nhãn mục tiêu (is_slow):")
print(df['is_slow'].value_counts(normalize=True))

# ==== 4. Xử lý đặc trưng syntax (has_...) ====
syntax_cols = ['has_like', 'has_group', 'has_join', 'has_order', 'has_limit', 'has_distinct']
for col in syntax_cols:
    if col not in df.columns:
        df[col] = 0  # Nếu thiếu cột, gán mặc định 0

# ==== 5. One-hot encoding cho cột 'types' ====
if 'types' in df.columns:
    types_dummies = df['types'].str.get_dummies(sep=',')
else:
    types_dummies = pd.DataFrame()
    print("⚠️ Cột 'types' không có trong dữ liệu. Bỏ qua one-hot.")

# ==== 6. Kết hợp đặc trưng đầu vào ====
base_features = ['rows_examined', 'uses_index', 'num_tables'] + syntax_cols
X = pd.concat([df[base_features], types_dummies], axis=1)
y = df['is_slow']

# ==== 7. Tách dữ liệu train/test ====
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)

# ==== 8. Huấn luyện mô hình XGBoost ====
model = xgb.XGBClassifier(
    objective="binary:logistic",
    eval_metric="logloss",
    max_depth=5,
    n_estimators=100,
    learning_rate=0.1,
    random_state=42,
    use_label_encoder=False
)
model.fit(X_train, y_train)

# ==== 9. Đánh giá mô hình ====
from sklearn.metrics import accuracy_score, f1_score

y_pred = model.predict(X_test)
acc = accuracy_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)

print("\n=== [Confusion Matrix] ===")
print(confusion_matrix(y_test, y_pred))
print("\n=== [Classification Report] ===")
print(classification_report(y_test, y_pred))
print(f"\n✅ Accuracy: {acc:.4f} | F1-score: {f1:.4f}")

# ==== 10. Lưu mô hình và thông tin liên quan ====
joblib.dump(model, "slow_query_model.pkl")
joblib.dump(X.columns.tolist(), "model_features.pkl")
print("✅ Đã lưu mô hình vào slow_query_model.pkl")
print("✅ Đã lưu đặc trưng đầu vào vào model_features.pkl")

# === 11. Lưu hình ảnh + biểu đồ ===
os.makedirs("figures", exist_ok=True)

plt.figure(figsize=(10, 6))
xgb.plot_importance(model, height=0.5, importance_type='gain', show_values=False)
plt.title("Tầm quan trọng của các đặc trưng")
plt.tight_layout()
plt.savefig("figures/feature_importance.png")
plt.close()
print("✅ Đã lưu biểu đồ tầm quan trọng vào figures/feature_importance.png")

# === 12. Lưu kết quả test vào file CSV ===
df_test = X_test.copy()
df_test["y_true"] = y_test.values
df_test["y_pred"] = y_pred
df_test.to_csv("figures/model_test_result.csv", index=False)
print("📝 Đã lưu kết quả dự đoán test vào figures/model_test_result.csv")

# === 13. Lưu log độ chính xác vào file (nếu cần dùng cho báo cáo) ===
with open("figures/metrics.txt", "w") as f:
    f.write(f"Accuracy: {acc:.4f}\n")
    f.write(f"F1-score: {f1:.4f}\n")
print("📝 Đã lưu chỉ số đánh giá vào figures/metrics.txt")

# Tạo thư mục lưu hình ảnh nếu chưa có
os.makedirs("figures", exist_ok=True)

# Lưu biểu đồ tầm quan trọng đặc trưng
plt.figure(figsize=(10, 6))
xgb.plot_importance(model, height=0.5, importance_type='gain', show_values=False)
plt.title("Tầm quan trọng của các đặc trưng")
plt.tight_layout()
plt.savefig("figures/feature_importance.png")
plt.close()
print("✅ Đã lưu biểu đồ tầm quan trọng vào figures/feature_importance.png")
