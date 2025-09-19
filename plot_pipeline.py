# plot_pipeline.py
# ✅ Vẽ pipeline trực quan cho hệ thống dự đoán & tối ưu truy vấn SQL

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import os   # 👈 thêm dòng này

fig, ax = plt.subplots(figsize=(13, 4))
ax.axis("off")

# Danh sách các bước pipeline
pipeline = [
    ("queries.sql", "Tập truy vấn SQL", "#81d4fa"),         # xanh dương nhạt (Input)
    ("log_queries.py", "Sinh log\n(query_log.csv)", "#a5d6a7"),  # xanh lá (Processing)
    ("analyze_log.py", "Phân tích log\n(Biểu đồ, thống kê)", "#a5d6a7"),
    ("train_model.py", "Huấn luyện XGBoost\n(model.pkl + features.pkl)", "#a5d6a7"),
    ("predict_demo.py", "Dự đoán truy vấn mới", "#ffe082"),   # vàng (Prediction)
    ("suggest_fix.py", "Gợi ý tối ưu hóa", "#ffab91")         # cam (Recommendation)
]

# Vẽ từng khối
x = 0.05
for fname, desc, color in pipeline:
    box = mpatches.FancyBboxPatch(
        (x, 0.3), 0.14, 0.3,
        boxstyle="round,pad=0.05", edgecolor="black", facecolor=color
    )
    ax.add_patch(box)
    ax.text(x + 0.07, 0.52, fname, ha="center", va="center", fontsize=9, weight="bold")
    ax.text(x + 0.07, 0.36, desc, ha="center", va="top", fontsize=8, wrap=True)
    
    # Mũi tên nối
    if x < 0.8:
        ax.annotate("", xy=(x+0.14, 0.45), xytext=(x+0.19, 0.45),
                    arrowprops=dict(arrowstyle="->", lw=1.5))
    x += 0.19

# Thêm tiêu đề
plt.title("Pipeline hệ thống dự đoán & tối ưu truy vấn SQL", fontsize=13, weight="bold", pad=20)

# Legend
input_patch = mpatches.Patch(color="#81d4fa", label="Input / Data")
proc_patch = mpatches.Patch(color="#a5d6a7", label="Processing")
pred_patch = mpatches.Patch(color="#ffe082", label="Prediction")
rec_patch = mpatches.Patch(color="#ffab91", label="Recommendation")

plt.legend(handles=[input_patch, proc_patch, pred_patch, rec_patch],
           loc="lower center", bbox_to_anchor=(0.5, -0.2), ncol=4, fontsize=8, frameon=False)

# Lưu hình
os.makedirs("figures", exist_ok=True)
plt.savefig("figures/pipeline_overview.png", bbox_inches="tight", dpi=150)
plt.close()
print("✅ Đã lưu sơ đồ pipeline vào figures/pipeline_overview.png")
