# csdl

## 1. Yêu cầu môi trường

- Python 3.7+
- MySQL server (có database `employees`)
- Các thư viện Python cần cài đặt:
  - pandas
  - scikit-learn
  - xgboost
  - joblib
  - pymysql

Cài đặt các thư viện bằng lệnh:
```bash
pip install pandas scikit-learn xgboost joblib pymysql
```

## 2. Ý nghĩa các file

- **log_queries.py**: Thực thi các truy vấn trong `queries.sql` trên database MySQL, đo thời gian thực thi, trích xuất đặc trưng từ EXPLAIN, và ghi log vào file `query_log.csv`.
- **train_model.py**: Huấn luyện mô hình máy học để phân loại truy vấn SQL nhanh/chậm dựa trên log đã thu thập, lưu mô hình và đặc trưng.
- **predict_demo.py**: Demo dự đoán một truy vấn SQL (dưới dạng đặc trưng) là nhanh hay chậm bằng mô hình đã huấn luyện.
- **queries.sql**: Danh sách các truy vấn SQL để kiểm thử.

## 3. Hướng dẫn từng bước

### Bước 1: Chuẩn bị database

- Đảm bảo MySQL server đang chạy và có database `employees`.
- Tài khoản MySQL: user `root`, password rỗng (có thể chỉnh lại trong file `log_queries.py` nếu khác).

### Bước 2: Chạy log_queries.py

Chạy script để thực thi các truy vấn và ghi log:
```bash
python log_queries.py
```
Kết quả sẽ tạo file `query_log.csv` chứa log đặc trưng và thời gian thực thi từng truy vấn.

### Bước 3: Huấn luyện mô hình

Chạy script huấn luyện:
```bash
python train_model.py
```
Kết quả sẽ tạo ra 2 file:
- `slow_query_model.pkl`: file mô hình đã huấn luyện
- `model_features.pkl`: danh sách các đặc trưng đầu vào

### Bước 4: Dự đoán thử

Chạy demo dự đoán:
```bash
python predict_demo.py
```
Bạn có thể chỉnh sửa biến `new_query` trong file này để thử các đặc trưng khác nhau.

---

## 4. Lưu ý

- Nếu thay đổi cấu trúc database hoặc truy vấn, cần chạy lại từ bước 2.
- Nếu gặp lỗi kết nối MySQL, kiểm tra lại thông tin kết nối trong file `log_queries.py`.