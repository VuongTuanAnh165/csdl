# train_model.py
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from xgboost import XGBClassifier
import joblib

# 1. Đọc dữ liệu
df = pd.read_csv("query_log.csv")
df['is_slow'] = df['exec_time_sec'].apply(lambda x: 1 if x > 1.0 else 0)

# 2. One-hot cho type trong EXPLAIN
types_dummies = df['types'].str.get_dummies(sep=',')

# 3. Ghép đặc trưng
X = pd.concat([
    df[['rows_examined', 'uses_index']],
    types_dummies
], axis=1)
y = df['is_slow']

# 4. Train/Test Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 5. Huấn luyện mô hình
model = XGBClassifier(use_label_encoder=False, eval_metric='logloss')
model.fit(X_train, y_train)

# 6. Đánh giá
print("📊 Classification Report:")
print(classification_report(y_test, model.predict(X_test)))
print("🧱 Confusion Matrix:")
print(confusion_matrix(y_test, model.predict(X_test)))

# 7. Lưu mô hình và cột
joblib.dump(model, "slow_query_model.pkl")
joblib.dump(list(X.columns), "model_features.pkl")  # lưu danh sách cột
print("✅ Mô hình đã lưu thành công!")
