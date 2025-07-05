import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
import xgboost as xgb
import joblib
import sys

# 1. Đọc dữ liệu từ file CSV
try:
    df = pd.read_csv("query_log.csv")
except FileNotFoundError:
    print("❌ Không tìm thấy file query_log.csv. Vui lòng đảm bảo file tồn tại trong thư mục.")
    sys.exit(1)

# 2. Kiểm tra nhãn có đủ 2 lớp không
unique_labels = df['is_slow'].unique()
if len(unique_labels) < 2:
    print("⚠️ Dữ liệu chỉ có 1 loại nhãn (chỉ toàn truy vấn nhanh hoặc chậm).")
    print("➡️ Vui lòng thêm thêm cả truy vấn nhanh và chậm vào query_log.csv.")
    sys.exit(1)

# 3. Xử lý cột 'types' bằng one-hot encoding
types_dummies = df['types'].str.get_dummies(sep=',')

# 4. Ghép tất cả đặc trưng đầu vào
X = pd.concat([
    df[['rows_examined', 'uses_index', 'has_like', 'has_group', 'has_join']],
    types_dummies
], axis=1)

y = df['is_slow']

# 5. Tách dữ liệu train/test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# 6. Huấn luyện mô hình XGBoost
model = xgb.XGBClassifier(
    objective="binary:logistic",
    eval_metric="logloss",
    max_depth=5,
    n_estimators=100,
    learning_rate=0.1,
    random_state=42
)
model.fit(X_train, y_train)

# 7. Dự đoán và đánh giá
y_pred = model.predict(X_test)

print("\n=== Confusion Matrix ===")
print(confusion_matrix(y_test, y_pred, labels=[0, 1]))

print("\n=== Classification Report ===")
print(classification_report(y_test, y_pred, labels=[0, 1]))

# 8. Lưu mô hình và đặc trưng
joblib.dump(model, "slow_query_model.pkl")
joblib.dump(X.columns.tolist(), "model_features.pkl")

print("\n✅ Mô hình đã được lưu vào slow_query_model.pkl")
print("✅ Danh sách đặc trưng đã lưu vào model_features.pkl")
