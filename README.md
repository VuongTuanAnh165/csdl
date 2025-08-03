# 🔍 Dự đoán và Tối ưu Truy vấn SQL bằng Khai phá Log và XGBoost

## 📌 Giới thiệu

Dự án này tập trung vào **khai phá log truy vấn SQL** để phát hiện và dự đoán các truy vấn có nguy cơ gây **suy giảm hiệu năng** trên hệ quản trị MySQL. Bằng cách sử dụng log từ truy vấn thực tế, hệ thống sẽ:

- Trích xuất đặc trưng từ EXPLAIN
- Làm sạch và phân tích dữ liệu log
- Huấn luyện mô hình phân loại (XGBoost)
- Dự đoán truy vấn nhanh/chậm
- Đưa ra **gợi ý tối ưu hóa truy vấn SQL**

---

## ⚙️ 1. Yêu cầu môi trường

- Python 3.7+
- MySQL server (đã import CSDL `employees`) từ [https://github.com/datacharmer/test_db](https://github.com/datacharmer/test_db)
- Các thư viện Python:
  - pandas
  - scikit-learn
  - xgboost
  - matplotlib
  - joblib
  - pymysql

Cài đặt:
```bash
pip install pandas scikit-learn xgboost matplotlib seaborn joblib pymysql
```

---

## 📁 2. Ý nghĩa các file

| File | Chức năng |
|------|-----------|
| `queries.sql` | Danh sách truy vấn SQL để kiểm thử |
| `log_queries.py` | Thực thi truy vấn, đo thời gian, EXPLAIN và ghi log vào `query_log.csv` |
| `analyze_log.py` | Phân tích và trực quan hóa log (EDA, biểu đồ, tương quan) |
| `train_model.py` | Làm sạch log, chọn đặc trưng, huấn luyện mô hình XGBoost, xuất `slow_query_model.pkl` |
| `predict_demo.py` | Dự đoán truy vấn (nhập đặc trưng thủ công) |
| `suggest_fix.py` | Gợi ý tối ưu hóa truy vấn nếu bị dự đoán là chậm |

---

## 🚀 3. Hướng dẫn sử dụng

### 🧱 Bước 1: Chuẩn bị database

- Đảm bảo MySQL đang chạy và đã import database mẫu `employees`
- Mặc định user: `root`, password rỗng (sửa trong `log_queries.py` nếu khác)

### 🧪 Bước 2: Thực thi truy vấn và ghi log
```bash
python log_queries.py
```
➡️ Tạo file `query_log.csv` chứa đặc trưng và thời gian thực thi truy vấn.

### 📊 Bước 3: Phân tích log
```bash
python analyze_log.py
```
➡️ Hiển thị biểu đồ thống kê, tương quan, phân bố thời gian, giúp hiểu dữ liệu hơn.

### 🤖 Bước 4: Huấn luyện mô hình
```bash
python train_model.py
```
➡️ Kết quả:
- `slow_query_model.pkl`: mô hình phân loại
- `model_features.pkl`: danh sách đặc trưng đã chọn
- `figures/feature_importance.png`: biểu đồ tầm quan trọng đặc trưng

### 🔍 Bước 5: Dự đoán truy vấn mới
```bash
python predict_demo.py
```
➡️ Sửa giá trị trong `new_query = {...}` để mô phỏng đặc trưng truy vấn mới.

### 💡 Bước 6: Gợi ý cải tiến truy vấn (nếu chậm)
```bash
python suggest_fix.py
```
➡️ Nếu truy vấn bị dự đoán là chậm, chương trình sẽ đưa ra các **gợi ý tối ưu hóa**.

---

## 📝 4. Lưu ý

- Nếu sửa nội dung `queries.sql`, hãy chạy lại `log_queries.py` và `train_model.py`
- Các file mô hình (`*.pkl`) cần đồng bộ với đặc trưng mới nếu thay đổi
- Tập trung vào khai phá và xử lý log, học máy chỉ là bước hỗ trợ ra quyết định
