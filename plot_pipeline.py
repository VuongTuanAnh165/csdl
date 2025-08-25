import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, ax = plt.subplots(figsize=(12, 4))
ax.axis("off")

pipeline = [
    ("queries.sql", "Tập truy vấn SQL"),
    ("log_queries.py", "Sinh log\n(query_log.csv)"),
    ("analyze_log.py", "Phân tích log\n(Biểu đồ, thống kê)"),
    ("train_model.py", "Huấn luyện XGBoost\n(model.pkl + features.pkl)"),
    ("predict_demo.py", "Dự đoán truy vấn mới"),
    ("suggest_fix.py", "Gợi ý tối ưu hóa")
]

x = 0.05
for fname, desc in pipeline:
    box = mpatches.FancyBboxPatch(
        (x, 0.3), 0.12, 0.3,
        boxstyle="round,pad=0.05", edgecolor="black", facecolor="#a5d6a7"
    )
    ax.add_patch(box)
    ax.text(x + 0.06, 0.45, fname, ha="center", va="center", fontsize=9, weight="bold")
    ax.text(x + 0.06, 0.35, desc, ha="center", va="top", fontsize=8, wrap=True)
    if x < 0.8:
        ax.annotate("", xy=(x+0.12, 0.45), xytext=(x+0.17, 0.45),
                    arrowprops=dict(arrowstyle="->", lw=1.5))
    x += 0.17

plt.title("Pipeline hệ thống dự đoán & tối ưu truy vấn SQL", fontsize=12, weight="bold")
plt.savefig("figures/pipeline_overview.png", bbox_inches="tight")
plt.close()
print("✅ Đã lưu sơ đồ pipeline vào figures/pipeline_overview.png")
