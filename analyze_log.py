# analyze_log.py
# ✅ Phân tích và trực quan hóa log truy vấn SQL - bản mở rộng cho môn AI nâng cao
"""
Tập lệnh tạo bảng số liệu và biểu đồ từ `query_log.csv` để phục vụ báo cáo.

Chức năng chính:
- Lọc bản ghi hợp lệ (status = OK), kiểm tra cột bắt buộc.
- Lưu mẫu dữ liệu, phân phối nhãn, thống kê mô tả.
- Vẽ histogram, boxplot theo cú pháp SQL và đặc trưng số; scatter, heatmap tương quan.
- Xuất top 10 truy vấn chậm và tần suất từ khoá SQL phổ biến.

Đầu vào: `query_log.csv` (tạo bởi `log_queries.py`).
Đầu ra: file CSV/PNG trong thư mục `figures/`.
"""

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os
import warnings
from collections import Counter
import re

warnings.filterwarnings("ignore")

# ==== 1. Đọc dữ liệu truy vấn từ file ====
log_path = "query_log.csv"
if not os.path.exists(log_path):
    raise FileNotFoundError(f"❌ File {log_path} không tồn tại. Hãy chạy log_queries.py trước.")

df = pd.read_csv(log_path)

# ==== 2. Làm sạch dữ liệu ====
if 'status' in df.columns:
    df = df[df['status'] == 'OK'].copy()

# ==== 3. Kiểm tra cột bắt buộc ====
required_cols = ['exec_time_sec', 'rows_examined', 'uses_index', 'num_tables', 'is_slow']
missing_cols = [col for col in required_cols if col not in df.columns]
if missing_cols:
    raise ValueError(f"❌ Thiếu cột bắt buộc trong dữ liệu: {missing_cols}")

# 🔧 Đảm bảo thư mục lưu hình ảnh và file CSV tồn tại
os.makedirs("figures", exist_ok=True)

# ==== 3b. Lưu mẫu dữ liệu log để chèn vào báo cáo ====
df.head(10).to_csv("figures/sample_query_log.csv", index=False)

# ==== 3c. Phân phối nhãn nhanh/chậm ====
df["is_slow"].value_counts().to_csv("figures/label_distribution.csv")

# ==== 4. Thống kê tổng quan ====
df.describe(include='all').to_csv("figures/statistics_summary.csv")

# ==== 5. Biểu đồ phân phối thời gian thực thi ====
plt.figure(figsize=(8, 4))
sns.histplot(df['exec_time_sec'], bins=20, kde=True, color='skyblue')
plt.title("Phân phối thời gian thực thi truy vấn")
plt.savefig("figures/hist_exec_time.png")
plt.close()

# ==== 6. Phân phối số dòng được quét ====
plt.figure(figsize=(8, 4))
sns.histplot(df['rows_examined'], bins=30, kde=True, color='salmon')
plt.title("Phân phối số dòng được quét")
plt.savefig("figures/hist_rows_examined.png")
plt.close()

# ==== 7. Boxplot theo cú pháp SQL ====
# Các cột cú pháp và ý nghĩa (0/1):
# - has_like: dùng LIKE (đặc biệt '%...%') dễ gây full-scan
# - has_group: có GROUP BY
# - has_join: có JOIN (nhiều bảng)
# - has_order: có ORDER BY
# - has_limit: có LIMIT (thường giảm khối lượng kết quả)
# - has_distinct: có DISTINCT (loại trùng có thể tốn chi phí)
# - has_function: dùng hàm trên cột (YEAR/LOWER/...) có thể vô hiệu hoá index
syntax_cols = ['has_like', 'has_group', 'has_join', 'has_order', 'has_limit', 'has_distinct', 'has_function']
for col in syntax_cols:
    if col in df.columns:
        plt.figure(figsize=(6, 4))
        sns.boxplot(data=df, x=col, y='exec_time_sec', palette="Set2")
        plt.title(f"Ảnh hưởng của {col} đến thời gian truy vấn")
        plt.savefig(f"figures/box_{col}.png")
        plt.close()

# ==== 8. Phân tích feature mới ====
# Một vài đặc trưng số mở rộng và ý nghĩa:
# - num_predicates: số điều kiện WHERE/AND/OR → phức tạp lọc
# - num_subqueries: số subquery lồng → tăng chi phí
extra_numeric = ['num_predicates', 'num_subqueries']
for col in extra_numeric:
    if col in df.columns:
        plt.figure(figsize=(6, 4))
        sns.boxplot(data=df, x=col, y='exec_time_sec', palette="muted")
        plt.title(f"Ảnh hưởng của {col} đến thời gian truy vấn")
        plt.savefig(f"figures/box_{col}.png")
        plt.close()

# ==== 9. Scatter plot: số dòng quét vs thời gian ====
plt.figure(figsize=(7, 5))
sns.scatterplot(data=df, x="rows_examined", y="exec_time_sec", hue="is_slow", palette="coolwarm")
plt.title("Mối quan hệ giữa rows_examined và exec_time_sec")
plt.savefig("figures/scatter_rows_vs_time.png")
plt.close()

# ==== 10. Heatmap tương quan ====
numeric_cols = ['exec_time_sec', 'exec_time_log', 'rows_examined', 'uses_index', 
                'num_tables', 'num_predicates', 'num_subqueries'] + syntax_cols
numeric_cols = [c for c in numeric_cols if c in df.columns]

plt.figure(figsize=(12, 8))
sns.heatmap(df[numeric_cols].corr(), annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Ma trận tương quan giữa các đặc trưng")
plt.savefig("figures/heatmap_correlation.png")
plt.close()

# ==== 11. Biểu đồ phân bố nhanh/chậm ====
plt.figure(figsize=(5, 5))
df["is_slow"].value_counts().plot.pie(
    autopct="%.1f%%", labels=["Nhanh (0)", "Chậm (1)"], colors=["#8fd694", "#f28b82"]
)
plt.title("Tỉ lệ truy vấn nhanh và chậm")
plt.savefig("figures/pie_is_slow.png")
plt.close()

# ==== 12. Top 10 truy vấn chậm nhất ====
if "query_raw" in df.columns:
    top10 = df.sort_values("exec_time_sec", ascending=False).head(10)
    top10.to_csv("figures/top10_slow_queries.csv", index=False)

    plt.figure(figsize=(10, 6))
    sns.barplot(data=top10, x="exec_time_sec", y="query_raw", palette="Reds_r")
    plt.xlabel("Thời gian (giây)")
    plt.ylabel("Truy vấn (rút gọn)")
    plt.yticks(ticks=range(len(top10)), labels=[q[:50]+"..." for q in top10["query_raw"]])
    plt.title("Top 10 truy vấn chậm nhất")
    plt.savefig("figures/bar_top10_slow_queries.png")
    plt.close()

# ==== 13. Tần suất từ khóa SQL ====
if "query_raw" in df.columns:
    all_tokens = []
    for q in df["query_raw"]:
        tokens = re.findall(r'\b(select|from|join|where|group by|order by|limit|distinct|like)\b', q.lower())
        all_tokens.extend(tokens)

    keyword_counts = Counter(all_tokens).most_common(10)
    pd.DataFrame(keyword_counts, columns=["keyword", "count"]).to_csv("figures/keyword_frequency.csv", index=False)

    plt.figure(figsize=(8, 4))
    sns.barplot(x=[k for k, _ in keyword_counts], y=[c for _, c in keyword_counts], palette='viridis')
    plt.title("Top từ khóa SQL phổ biến nhất")
    plt.savefig("figures/keyword_frequency.png")
    plt.close()

print("\n✅ Đã hoàn tất phân tích log. Tất cả biểu đồ và bảng nằm trong thư mục figures/")
