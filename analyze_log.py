# analyze_log.py
# ✅ Phân tích và trực quan hóa log truy vấn SQL - phục vụ môn Khai phá dữ liệu tiên tiến

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

# ==== 3b. Lưu mẫu dữ liệu log để chèn vào báo cáo ====
sample_path = "figures/sample_query_log.csv"
df.head(10).to_csv(sample_path, index=False)
print(f"📄 Đã lưu 10 dòng đầu của query_log.csv tại: {sample_path}")

# ==== 3c. Thống kê nhãn nhanh/chậm ====
label_dist_path = "figures/label_distribution.csv"
df["is_slow"].value_counts().to_csv(label_dist_path)
print(f"📄 Đã lưu phân phối nhãn nhanh/chậm tại: {label_dist_path}")

# ==== 4. Mô tả tổng quan ====
print("📊 Tổng số truy vấn hợp lệ:", len(df))
print("\n📌 Tổng quan dữ liệu số:")
print(df.describe(include='all'))

# ==== 5. Tạo thư mục lưu hình ảnh ====
os.makedirs("figures", exist_ok=True)

# ==== 6. Phân phối thời gian thực thi ====
plt.figure(figsize=(8, 4))
sns.histplot(df['exec_time_sec'], bins=20, kde=True, color='skyblue')
plt.title("Phân phối thời gian thực thi truy vấn")
plt.xlabel("Thời gian (giây)")
plt.ylabel("Số lượng truy vấn")
plt.tight_layout()
plt.savefig("figures/hist_exec_time.png")
plt.close()

# ==== 7. Phân phối số dòng được quét ====
plt.figure(figsize=(8, 4))
sns.histplot(df['rows_examined'], bins=30, kde=True, color='salmon')
plt.title("Phân phối số dòng được quét (rows_examined)")
plt.xlabel("rows_examined")
plt.ylabel("Số lượng truy vấn")
plt.tight_layout()
plt.savefig("figures/hist_rows_examined.png")
plt.close()

# ==== 8. Boxplot theo cú pháp SQL ====
syntax_cols = ['has_like', 'has_group', 'has_join', 'has_order', 'has_limit', 'has_distinct']
for col in syntax_cols:
    if col in df.columns:
        plt.figure(figsize=(6, 4))
        sns.boxplot(data=df, x=col, y='exec_time_sec', palette="Set2")
        plt.title(f"Ảnh hưởng của '{col}' đến thời gian truy vấn")
        plt.xlabel(col)
        plt.ylabel("Thời gian (giây)")
        plt.tight_layout()
        plt.savefig(f"figures/box_{col}.png")
        plt.close()

# ==== 9. Scatter plot: số dòng quét vs thời gian ====
plt.figure(figsize=(7, 5))
sns.scatterplot(data=df, x="rows_examined", y="exec_time_sec", hue="is_slow", palette="coolwarm")
plt.title("Mối quan hệ giữa rows_examined và exec_time_sec")
plt.xlabel("rows_examined")
plt.ylabel("exec_time_sec")
plt.tight_layout()
plt.savefig("figures/scatter_rows_vs_time.png")
plt.close()

# ==== 10. Heatmap tương quan các đặc trưng số ====
numeric_cols = ['exec_time_sec', 'rows_examined', 'uses_index', 'num_tables'] + [
    col for col in syntax_cols if col in df.columns
]
corr = df[numeric_cols].corr()

plt.figure(figsize=(10, 8))
sns.heatmap(corr, annot=True, cmap="coolwarm", fmt=".2f")
plt.title("🔍 Ma trận tương quan giữa các đặc trưng")
plt.tight_layout()
plt.savefig("figures/heatmap_correlation.png")
plt.close()

# ==== 11. Phân phối truy vấn nhanh / chậm ====
plt.figure(figsize=(5, 4))
sns.countplot(data=df, x="is_slow", palette="Set2")
plt.title("Tỉ lệ truy vấn nhanh và chậm")
plt.xlabel("is_slow (0 = nhanh, 1 = chậm)")
plt.ylabel("Số lượng truy vấn")
plt.tight_layout()
plt.savefig("figures/count_is_slow.png")
plt.close()

# ==== 11b. Pie chart phân bố nhanh/chậm ====
plt.figure(figsize=(5, 5))
df["is_slow"].value_counts().plot.pie(
    autopct="%.1f%%", labels=["Nhanh (0)", "Chậm (1)"], colors=["#8fd694", "#f28b82"]
)
plt.title("Tỉ lệ truy vấn nhanh và chậm")
plt.ylabel("")
plt.tight_layout()
plt.savefig("figures/pie_is_slow.png")
plt.close()
print("✅ Đã lưu pie chart phân bố nhanh/chậm vào figures/pie_is_slow.png")

# ==== 12. Boxplot theo loại truy cập EXPLAIN.types ====
if "types" in df.columns:
    top_types = df['types'].value_counts().nlargest(10).index.tolist()
    df_types = df[df['types'].isin(top_types)].copy()

    plt.figure(figsize=(10, 5))
    sns.boxplot(data=df_types, x="types", y="exec_time_sec", palette="pastel")
    plt.xticks(rotation=45)
    plt.title("⏱ Thời gian truy vấn theo types (EXPLAIN)")
    plt.tight_layout()
    plt.savefig("figures/box_types_exec_time.png")
    plt.close()

# ==== 13. Top 10 truy vấn chậm nhất ====
if "query_raw" in df.columns:
    print("\n📛 Top 10 truy vấn chậm nhất:")
    top10 = df.sort_values("exec_time_sec", ascending=False).head(10)
    for i, row in top10.iterrows():
        print(f"- ({row['exec_time_sec']:.2f}s) {row['query_raw'][:120]}...")

    # Xuất ra file CSV
    top10.to_csv("figures/top10_slow_queries.csv", index=False)
    print("📝 Đã lưu top 10 truy vấn chậm nhất vào: figures/top10_slow_queries.csv")
else:
    print("\n📛 Thiếu cột 'query_raw' để hiển thị truy vấn gốc.")

# ==== 13b. Biểu đồ Top 10 truy vấn chậm nhất ====
if "query_raw" in df.columns:
    plt.figure(figsize=(10, 6))
    sns.barplot(data=top10, x="exec_time_sec", y="query_raw", palette="Reds_r")
    plt.xlabel("Thời gian (giây)")
    plt.ylabel("Truy vấn (rút gọn)")
    plt.yticks(ticks=range(len(top10)), labels=[q[:50]+"..." for q in top10["query_raw"]])
    plt.title("Top 10 truy vấn chậm nhất")
    plt.tight_layout()
    plt.savefig("figures/bar_top10_slow_queries.png")
    plt.close()
    print("✅ Đã lưu bar chart top 10 truy vấn chậm nhất vào figures/bar_top10_slow_queries.png")

# ==== 14. Tần suất từ khóa SQL phổ biến (token từ query_raw) ====
if "query_raw" in df.columns:
    all_tokens = []
    for q in df["query_raw"]:
        tokens = re.findall(r'\b(select|from|join|where|group by|order by|limit|distinct|like)\b', q.lower())
        all_tokens.extend(tokens)

    keyword_counts = Counter(all_tokens).most_common(10)
    keywords, counts = zip(*keyword_counts)

    plt.figure(figsize=(8, 4))
    sns.barplot(x=list(keywords), y=list(counts), palette='viridis')
    plt.title("🔑 Top từ khóa SQL phổ biến nhất")
    plt.ylabel("Số lần xuất hiện")
    plt.xlabel("Từ khóa")
    plt.tight_layout()
    plt.savefig("figures/keyword_frequency.png")
    plt.close()

# ==== 15. Lưu file mô tả thống kê (CSV) ====
df.describe().to_csv("figures/statistics_summary.csv")
print("\n📄 Đã lưu thống kê mô tả tại: figures/statistics_summary.csv")

# ==== 16. Kết thúc ====
print("\n✅ Đã hoàn tất phân tích log truy vấn SQL. Biểu đồ lưu tại thư mục 'figures/'")
