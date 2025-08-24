import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator, ScalarFormatter, FixedLocator, MultipleLocator, NullLocator
import numpy as np
from matplotlib.font_manager import FontProperties
from matplotlib.lines import Line2D  # 导入 Line2D 用于创建虚拟图例项
import os


script_dir = os.path.dirname(os.path.abspath(__file__))
primary_file1 = os.path.join(script_dir, '..', 'query', 'summary_selectivity_statistics.csv')
fallback_file1 = os.path.join(script_dir, '..', 'query', 'summary_selectivity_statistics_default.csv')
primary_file2 = os.path.join(script_dir, '..', 'query', 'summary_scale_statistics.csv')
fallback_file2 = os.path.join(script_dir, '..', 'query', 'summary_scale_statistics_default.csv')
    
try:
    df1 = pd.read_csv(primary_file1)
    print(f"Successfully loaded: {primary_file1}")
except FileNotFoundError:
    print(f"Successfully loaded: {fallback_file1}")
    df1 = pd.read_csv(fallback_file1)

try:
    df2 = pd.read_csv(primary_file2)
    print(f"Successfully loaded: {primary_file2}")
except FileNotFoundError:
    print(f"Successfully loaded: {fallback_file2}")
    df2 = pd.read_csv(fallback_file2)

# 检查数据是否正确读取
print(df1.head())
print(df2.head())

for col in range(1, len(df1.columns)):  # Skip first column (thread)
    df1.iloc[1:, col] = pd.to_numeric(df1.iloc[1:, col], errors='coerce').fillna(0)
for col in range(1, len(df2.columns)):  # Skip first column (thread) 
    df2.iloc[1:, col] = pd.to_numeric(df2.iloc[1:, col], errors='coerce').fillna(0)


# 更新图例标签，将 'Y+' 替换为 LaTeX 格式的 'Y$^{+}$'
updated_labels = ['DuckDB native', 'DuckDB Yannakakis$^{+}$', 'PostgreSQL native', 'PostgreSQL Yannakakis$^{+}$']

# 分别提取 LSQB 和 TPCH 数据
df1_lsqb = df1.iloc[:6]  # 前 6 行是 LSQB 数据
df1_tpch = df1.iloc[6:]  # 后 6 行是 TPCH 数据
df2_lsqb = df2.iloc[:5]  # 前 5 行是 LSQB 数据
df2_tpch = df2.iloc[5:]  # 后 5 行是 JOB 数据

# 替换数据中小于等于 0 的值为最小值（避免对数刻度中出现非法值）
min_value = 1e-3  # 对数坐标的最小值下限
df1.iloc[:, 1:] = df1.iloc[:, 1:].applymap(lambda x: x if x > min_value else min_value)
df2.iloc[:, 1:] = df2.iloc[:, 1:].applymap(lambda x: x if x > min_value else min_value)

# 计算全局最小值和最大值
y_min1 = df1.iloc[:, 1:].min().min()
y_max1 = df1.iloc[:, 1:].max().max()
y_min2 = df2.iloc[:, 1:].min().min()
y_max2 = df2.iloc[:, 1:].max().max()

# 创建图形和子图
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 5), sharey=True)

# 设置颜色和标记样式
colors_lsqb = ['#2E8B57', '#6A5ACD', '#708090', '#FFD700']
colors_tpch = ['#20B2AA', '#FF6347', '#8B008B', '#FFA500']
colors_job = ['#FFA07A', '#87CEEB', '#1e90ff', '#FF69B4']
markers = ['o', 's', 'h', 'p', 'v', '<', '>', 'x', '*', '^', 'D', '+']

# 绘制第一个子图（Selectivity）
for i, column in enumerate(df1.columns[1:]):
    ax1.plot(
        df1_lsqb['thread'], df1_lsqb[column],
        marker=markers[i % len(markers)],
        linestyle='-',  # LSQB 统一使用实线
        color=colors_lsqb[i % len(colors_lsqb)],
        label=f"LSQB {updated_labels[i]}",
        markerfacecolor='none',
        clip_on=False, 
        markersize=8
    )
    ax1.plot(
        df1_tpch['thread'], df1_tpch[column],
        marker=markers[i % len(markers) + 4],
        linestyle='--',  # TPCH 统一使用虚线
        color=colors_tpch[i % len(colors_tpch)],
        label=f"TPCH {updated_labels[i]}",
        markerfacecolor='none',
        clip_on=False, 
        markersize=8
    )

# 绘制第二个子图（Scale）
for i, column in enumerate(df2.columns[1:]):
    ax2.plot(
        df2_lsqb['thread'], df2_lsqb[column],
        marker=markers[i % len(markers)],
        linestyle='-',  # LSQB 统一使用实线
        color=colors_lsqb[i % len(colors_lsqb)],
        label=f"LSQB {updated_labels[i]}",
        markerfacecolor='none',
        clip_on=False, 
        markersize=8
    )
    ax2.plot(
        df2_tpch['thread'], df2_tpch[column],
        marker=markers[i % len(markers) + 8],
        linestyle='-.',  # JOB 统一使用点划线
        color=colors_job[i % len(colors_job)],
        label=f"JOB {updated_labels[i]}",
        markerfacecolor='none',
        clip_on=False, 
        markersize=8
    )

# 设置横纵坐标为对数刻度
ax1.set_yscale('log')
ax2.set_yscale('log')
ax2.set_xscale('log')

# 设置坐标轴范围
ax1.set_xlim(left=0.05, right=df1['thread'].max() * 1.01)
ax2.set_xlim(left=0.1, right=df2['thread'].max() * 1.01)
ax1.set_ylim(bottom=min(y_min1, y_min2), top=max(y_max1, y_max2) * 1.01)

# 设置自定义的纵轴刻度
y_ticks = [1e-3, 1e-2, 1e-1, 1, 10, 100, 1000]
ax1.yaxis.set_major_locator(FixedLocator(y_ticks))
ax2.yaxis.set_major_locator(FixedLocator(y_ticks))
ax1.yaxis.set_minor_locator(NullLocator())
ax2.yaxis.set_minor_locator(NullLocator())

# 使用 ScalarFormatter 格式化刻度标签
ax1.xaxis.set_major_formatter(ScalarFormatter())
ax2.xaxis.set_major_formatter(ScalarFormatter())
ax1.yaxis.set_major_formatter(ScalarFormatter())

# 设置刻度标签的字体大小
ax1.tick_params(axis='both', which='major', labelsize=14)
ax2.tick_params(axis='both', which='major', labelsize=14)
ax1.tick_params(axis='both', which='minor', labelsize=10)
ax2.tick_params(axis='both', which='minor', labelsize=10)

# 设置横纵坐标标签
ax1.set_ylabel('Running Time (Sec)', fontsize=14)
ax1.set_xlabel('(a) Selectivity', fontsize=14)
ax2.set_xlabel('(b) Scale', fontsize=14)

# 设置网格
ax1.grid(True, which="both", ls="--", lw=0.5)
ax2.grid(True, which="both", ls="--", lw=0.5)

# 获取现有的图例句柄和标签
handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax2.get_legend_handles_labels()

# 创建虚拟的图例项用于 JOB 数据
job_legend_handles = [
    Line2D([0], [0], marker=markers[i % len(markers) + 8], color=colors_job[i % len(colors_job)], label=f"JOB {updated_labels[i]}", 
           markerfacecolor='none', markersize=8, linestyle='-.')
    for i in range(len(updated_labels))
]

# 自定义图例的顺序
custom_order = [
    'LSQB DuckDB native', 'TPCH DuckDB native', 'JOB DuckDB native', 
    'LSQB DuckDB Yannakakis$^{+}$', 'TPCH DuckDB Yannakakis$^{+}$', 'JOB DuckDB Yannakakis$^{+}$', 
    'LSQB PostgreSQL native', 'TPCH PostgreSQL native', 'JOB PostgreSQL native', 
    'LSQB PostgreSQL Yannakakis$^{+}$', 'TPCH PostgreSQL Yannakakis$^{+}$', 'JOB PostgreSQL Yannakakis$^{+}$'
]

# 创建替换的图例标签，带上标的加号
def format_label(label):
    if '+' in label:
        base_label = label.replace('+', '')
        return f'{base_label}$^+$'
    return label

# 将所有图例句柄和标签合并，去除重复的
unique_labels = {}
for handle, label in zip(handles1 + handles2 + job_legend_handles, labels1 + labels2 + [f"JOB {label}" for label in updated_labels]):
    if label not in unique_labels:
        unique_labels[label] = handle

# 重新排列图例句柄和标签
ordered_handles = [unique_labels[label] for label in custom_order if label in unique_labels]
ordered_labels = [format_label(label) for label in custom_order if label in unique_labels]

# 设置图例
font_properties = FontProperties()
font_properties.set_size(14)  # 图例字体大小

# 添加图例（纵向优先）
# plt.legend(ordered_handles, ordered_labels, loc='upper center', bbox_to_anchor=(-0.02, 1.34), ncol=4, frameon=False, prop=font_properties)
plt.legend(ordered_handles, ordered_labels, loc='upper center', bbox_to_anchor=(-0.02, 1.4), ncol=4, frameon=False, prop=font_properties)

# 调整布局
plt.tight_layout()
plt.subplots_adjust(wspace=0.05)

# 保存图表
plt.savefig(os.path.join(script_dir, 'selectivity_scale.pdf'), dpi=1200, bbox_inches='tight', format='pdf')
