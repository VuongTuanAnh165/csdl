# train_model.py
# ✅ Huấn luyện mô hình XGBoost phân loại truy vấn SQL nhanh/chậm từ log đã khai phá
"""
Huấn luyện bộ phân loại XGBoost dự đoán truy vấn SQL chậm/nhanh từ `query_log.csv`.

Các bước chính:
- Đọc và lọc dữ liệu hợp lệ; loại outlier theo ngưỡng 99% và thêm `exec_time_log`.
- Bổ sung các cột cú pháp (has_...), one-hot cho `types` từ EXPLAIN.
- Chia train/test có stratify; tính `scale_pos_weight` để xử lý mất cân bằng.
- Huấn luyện XGBClassifier; đánh giá Accuracy/F1, lưu báo cáo và biểu đồ (CM, ROC, FI).
- Lưu model (`slow_query_model.pkl`) và danh sách feature (`model_features.pkl`).
"""

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    classification_report, confusion_matrix, accuracy_score,
    f1_score, ConfusionMatrixDisplay, roc_curve, auc
)
import xgboost as xgb
import matplotlib.pyplot as plt
import joblib
import os
import sys
import numpy as np

# ==== 1. Đọc dữ liệu log từ file ====
log_path = "query_log.csv"
if not os.path.exists(log_path):
    print("❌ Không tìm thấy file query_log.csv. Hãy chạy log_queries.py trước.")
    sys.exit(1)

df = pd.read_csv(log_path)
df = df[df['status'] == 'OK'].copy()  # Lọc bỏ truy vấn lỗi

# ==== 2. Loại bỏ truy vấn dị biệt (outliers) & log-transform ====
if len(df) < 50:
    print(f"⚠️ Dữ liệu chỉ có {len(df)} bản ghi → quá ít để huấn luyện. Hãy bổ sung query.")
    sys.exit(1)

q99 = df["exec_time_sec"].quantile(0.99)
# Loại bỏ outlier cực lớn (top 1%) để mô hình ổn định hơn
df = df[df["exec_time_sec"] <= q99]
# Biến đổi log giúp phân phối thời gian thực thi bớt lệch
df["exec_time_log"] = np.log1p(df["exec_time_sec"])
print(f"✅ Đã loại bỏ các truy vấn có exec_time_sec > {q99:.2f}s (top 1%) và thêm log-transform")

# ==== 3. Kiểm tra nhãn mục tiêu ====
if 'is_slow' not in df.columns or df['is_slow'].nunique() < 2:
    print("⚠️ Cần cả truy vấn nhanh và chậm. Hãy kiểm tra lại log.")
    sys.exit(1)

print("\n📊 Phân phối nhãn mục tiêu (is_slow):")
print(df['is_slow'].value_counts(normalize=True))

# ==== 4. Đặc trưng syntax (has_...) ====
syntax_cols = [
    'has_like', 'has_group', 'has_join',
    'has_order', 'has_limit', 'has_distinct',
    'has_function'
]
for col in syntax_cols:
    if col not in df.columns:
        df[col] = 0

# ==== 5. One-hot encoding cho cột 'types' ====
if 'types' in df.columns:
    types_dummies = df['types'].str.get_dummies(sep=',')
else:
    types_dummies = pd.DataFrame()
    print("⚠️ Cột 'types' không có trong dữ liệu. Bỏ qua one-hot.")

# ==== 6. Kết hợp đặc trưng đầu vào ====
# Danh sách đặc trưng đầu vào và ý nghĩa:
# - rows_examined: Tổng số dòng ước lượng đã quét (từ EXPLAIN) → độ nặng truy vấn.
# - uses_index: Có dùng chỉ mục ở bất kỳ bước nào (1/0) → thường giảm thời gian.
# - num_tables: Số bảng join → join nhiều thường tốn kém hơn.
# - num_predicates: Số điều kiện lọc (WHERE/AND/OR) → lọc nhiều có thể nặng (tuỳ index).
# - num_subqueries: Số subquery lồng nhau → subquery sâu thường chậm.
# - exec_time_log: log(1+exec_time_sec) → giúp phân phối thời gian bớt lệch.
base_features = [
    'rows_examined', 'uses_index', 'num_tables',
    'num_predicates', 'num_subqueries', 'exec_time_log'
] + syntax_cols

X = pd.concat([df[base_features], types_dummies], axis=1)
y = df['is_slow']

# ==== 7. Train/test split ====
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)

print("\n📊 Phân phối nhãn sau khi split:")
print("Train:", pd.Series(y_train).value_counts(normalize=True))
print("Test :", pd.Series(y_test).value_counts(normalize=True))

# ==== 8. Tính scale_pos_weight để xử lý imbalance ====
pos = sum(y_train == 1)
neg = sum(y_train == 0)
# Tỷ lệ mẫu âm/dương để cân bằng loss khi lớp CHẬM hiếm
scale_pos_weight = neg / pos if pos > 0 else 1

# ==== 9. Huấn luyện mô hình XGBoost ====
eval_set = [(X_train, y_train), (X_test, y_test)]

model = xgb.XGBClassifier(
    objective="binary:logistic",
    max_depth=6,
    n_estimators=300,
    learning_rate=0.05,
    subsample=0.8,
    colsample_bytree=0.8,
    reg_alpha=0.1,
    reg_lambda=1,
    scale_pos_weight=scale_pos_weight,
    random_state=42,
    eval_metric="logloss"   # ✅ đặt ở constructor
)

print(f"⚡ Đang dùng XGBoost {xgb.__version__}")

model.fit(
    X_train, y_train,
    eval_set=eval_set,
    verbose=False
)

if hasattr(model, "best_iteration") and model.best_iteration is not None:
    print(f"✅ Best iteration: {model.best_iteration}")

# ==== 10. Đánh giá ====
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)[:, 1]

acc = accuracy_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred, zero_division=0)

print("\n=== [Confusion Matrix] ===")
print(confusion_matrix(y_test, y_pred))

print("\n=== [Classification Report] ===")
report_dict = classification_report(y_test, y_pred, zero_division=0, output_dict=True)
print(classification_report(y_test, y_pred, zero_division=0))

print(f"\n✅ Accuracy: {acc:.4f} | F1-score: {f1:.4f}")

# ==== 11. Lưu kết quả & biểu đồ ====
os.makedirs("figures", exist_ok=True)

# Lưu classification report ra CSV
pd.DataFrame(report_dict).transpose().to_csv("figures/classification_report.csv")
print("✅ Đã lưu classification_report.csv")

# Confusion matrix
plt.figure(figsize=(5, 4))
disp = ConfusionMatrixDisplay(confusion_matrix(y_test, y_pred),
                              display_labels=["Nhanh (0)", "Chậm (1)"])
disp.plot(cmap="Blues", values_format="d")
plt.title("Confusion Matrix - XGBoost")
plt.tight_layout()
plt.savefig("figures/confusion_matrix.png")
plt.close()

# ROC
fpr, tpr, _ = roc_curve(y_test, y_proba)
roc_auc = auc(fpr, tpr)
plt.figure(figsize=(6, 5))
plt.plot(fpr, tpr, lw=2, label=f"AUC = {roc_auc:.2f}")
plt.plot([0, 1], [0, 1], linestyle="--", color="gray")
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
plt.title("ROC Curve - XGBoost")
plt.legend(loc="lower right")
plt.savefig("figures/roc_curve.png")
plt.close()

# Feature importance
if model.get_booster().get_score():
    xgb.plot_importance(model, importance_type="gain", height=0.5, show_values=False)
    plt.title("Feature Importance - Gain")
    plt.tight_layout()
    plt.savefig("figures/feature_importance.png")
    plt.close()
else:
    print("⚠️ Không có cây nào được xây dựng → Bỏ qua vẽ Feature Importance.")

# Lưu mô hình
joblib.dump(model, "slow_query_model.pkl")
joblib.dump(X.columns.tolist(), "model_features.pkl")
print("✅ Đã lưu mô hình và đặc trưng")
