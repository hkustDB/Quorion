import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator, LogFormatter
from matplotlib.font_manager import FontProperties
import re
import numpy as np
import os

# 设置界限
threshold = 16
down_threshold = 1/16
top_value = threshold * 1.3  # 设置顶部的值
down_value = down_threshold  # 设置底部的值

# 绘制散点图
plt.figure(figsize=(28, 5))

colors = {
    'DuckDB optimal speedup': '#3399FF',  # 鲜艳的亮蓝色
    'DuckDB selection speedup': '#66C76B',  # 鲜艳的亮绿色
    'DuckDB yannakakis speedup': '#A9A7A4',  # 深灰蓝
    'PostgreSQL optimal speedup': '#FFC8D9',  # 鲜艳的亮粉红色
    'PostgreSQL selection speedup': '#CDD23D',  # 鲜艳的亮黄绿色
    'PostgreSQL yannakakis speedup': '#6699CC',  # 鲜艳的深蓝色
    #'SparkSQL optimal speedup': '#FF9076',  # 鲜艳的亮红色
    #'SparkSQL selection speedup': '#66E3B2',  # 鲜艳的亮紫色
    #'SparkSQL yannakakis speedup': '#A768C1'  # 鲜艳的亮绿
}

colors_fixed = ['#FF9076', '#66E3B2', '#A768C1']


def drawEach(db_name: str, db_columns: list):
    # 读取 Excel 文件的特定表单
    script_dir = os.path.dirname(os.path.abspath(__file__))
    primary_file = os.path.join(script_dir, '..', 'query', 'summary_job_statistics.csv')
    fallback_file = os.path.join(script_dir, '..', 'query', 'summary_job_statistics_default.csv')

    # 使用 pandas 读取 Excel 文件的特定表单
    try:
        df = pd.read_csv(primary_file)  # Remove header=None to read with headers
        print(f"Successfully loaded: {primary_file}")
        
        # Check if data contains zeros (missing data) - skip header row
        data_columns = df.columns[1:]  # Skip JOB column
        has_zeros = (df[data_columns] == 0).any().any()
        
        if has_zeros:
            print(f"Warning: Primary file contains zero values, falling back to default file")
            df = pd.read_csv(fallback_file)  # Remove header=None
            print(f"Loaded fallback file: {fallback_file}")
            
    except FileNotFoundError:
        print(f"Primary file not found: {primary_file}")
        print(f"Loading fallback file: {fallback_file}")
        df = pd.read_csv(fallback_file)  # Remove header=None

    # Convert all columns except the first one (JOB column) to numeric
    for col in range(1, len(df.columns)):
        df.iloc[:, col] = pd.to_numeric(df.iloc[:, col], errors='coerce').fillna(0)
    df.replace(0, -1, inplace=True)  # 将 0 替换为 -1

    # 自定义比例函数
    def custom_scale(x, pos):
        if x < 5:
            return f'{x:.1f}'
        else:
            return f'{x:.0f}'

    marked_points = set()
    if db_name == 'DuckDB':
        custom_labels = ['Yannakakis$^+$ speedup', 'Yannakakis speedup']
    elif db_name == 'PostgreSQL':
        custom_labels = ['Yannakakis$^+$ speedup', 'Yannakakis speedup']
    else:
        custom_labels = [f'Column {i+1}' for i in range(len(db_columns))]

    # 只绘制指定的列
    for idx, column_idx in enumerate(db_columns):
        column = df.columns[column_idx]
        # 创建副本以避免修改原始数据
        plot_data = df[column].copy()
    
        # 将超过阈值的点设为顶部值
        plot_data[plot_data > threshold] = np.nan
    
        # 保持原始顺序绘制数据
        mk = 'o' if idx == 0 else 's'
        plt.scatter(df[df.columns[0]], plot_data, color=colors_fixed[idx], marker=mk, s=90, label=custom_labels[idx], alpha=1)
    
        def extract_number(s):
            match = re.search(r'\d+', s)
            if match:
                return int(match.group())
            return None
    
        # 为部分超过阈值的点添加特殊标注
        above_threshold = df[df[column] > threshold]
        if not above_threshold.empty:
            max_speedup = above_threshold[column].max()
            max_job = above_threshold[above_threshold[column] == max_speedup][df.columns[0]].values[0]
    
            # 使用集合来跟踪已经标记的点
            for _, row in above_threshold.iterrows():
                job = row[df.columns[0]]
                speedup = row[column]
        
                # 如果点已经标记过，则跳过
                if job in marked_points:
                    continue
            
                plt.scatter(job, (threshold + top_value) / 2, color=colors_fixed[idx], label=custom_labels[idx], s=90, marker='^', edgecolor=None, linewidth=1)

                job_number = extract_number(job)
            
                formatted_speedup = f'{speedup:.1f}'
                # plt.text(job, (threshold + top_value) / 2 - 2, f'{formatted_speedup}', fontsize=10, ha='center', va='top', color='red')

                # 将点加入已标记集合
                marked_points.add(job_number)
    
    plt.xticks(range(0, len(df[df.columns[0]]), 5), df[df.columns[0]][::5], rotation=0)
    
    # 设置图例字体属性
    font_properties = FontProperties()
    font_properties.set_size(22.5)  # 设置字体大小

    # 获取已有的句柄和标签
    handles, labels = plt.gca().get_legend_handles_labels()

    # 自定义图例顺序
    # custom_order = ['Yannakakis+ speedup', 'Yannakakis speedup', 'Yannakakis+ speedup exceeds 16']

    # 创建单独的图例元素来解释三角形的意义
    triangle_explanation = plt.Line2D([], [], color='#FF9076', marker='^', linestyle='None', markersize=10, label='Yannakakis+ speedup exceeds 16')

    # 添加解释三角形的图例
    handles.append(triangle_explanation)
    labels.append('Yannakakis+ speedup exceeds 16')

    # Clean up duplicate labels (remove duplicates from triangle markers)
    unique_handles = []
    unique_labels = []
    seen_labels = set()
    
    for handle, label in zip(handles, labels):
        if label not in seen_labels:
            unique_handles.append(handle)
            unique_labels.append(label)
            seen_labels.add(label)

    # Add triangle explanation
    triangle_explanation = plt.Line2D([], [], color='#FF9076', marker='^', linestyle='None', markersize=8, label='Exceeds threshold (16)')
    plt.legend(unique_handles, unique_labels, loc='upper center', bbox_to_anchor=(0.5, 1.25), ncol=3, frameon=False, prop=font_properties)
    plt.xlabel(db_name, fontsize=22.5)
    plt.ylabel('Speedup', fontsize=22.5)


# Database configurations
db_configs = {
    'DuckDB': [1, 2],      # First 2 columns (1, 2) after the first column
    'PostgreSQL': [3, 4]   # Next 2 columns (3, 4) after the first column
}

# Draw graphs for both databases
for db_name, db_columns in db_configs.items():
    print(f"Processing {db_name}...")
    
    # Create new figure for each database
    plt.figure(figsize=(28, 5))
    
    # Draw the graph for current database
    drawEach(db_name, db_columns)

    # 添加纵坐标值为1的标准线，颜色设置为明显的黑色
    plt.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='Speedup = 1')

    # 设置对数刻度
    plt.yscale('log')

    # 自定义刻度和标签
    custom_ticks = [1/16, 1/4, 1/2, 1, 2, 4, 16]  # 自定义刻度值
    custom_labels = ['1/16', '1/4', '1/2', '1', '2', '4', '16']  # 自定义标签

    plt.gca().yaxis.set_major_locator(LogLocator(base=2, subs=[1], numticks=len(custom_ticks)))
    plt.gca().yaxis.set_major_formatter(LogFormatter(base=2))
    plt.gca().set_yticks(custom_ticks)  # 设置自定义刻度
    plt.gca().set_yticklabels(custom_labels)  # 设置自定义标签

    # 添加网格线
    plt.grid(True, which='major', axis='y', linestyle='--', color='gray', alpha=0.4, linewidth=1.2)  # 启用网格线
    plt.grid(True, which='major', axis='x', linestyle='--', color='gray', alpha=0.4, linewidth=1.2)  # 启用网格线

    # 设置纵坐标的范围
    plt.gca().set_ylim(top=top_value, bottom=down_value)

    # 改小横坐标显示字体
    plt.tick_params(axis='x', labelsize=22)  # 将 10 替换为你需要的字体大小
    plt.tick_params(axis='y', labelsize=22)  # 将 10 替换为你需要的字体大小

    # plt.figtext(0.5, -0.1, 'Triangles indicate values that exceed the threshold of 16.', wrap=True, horizontalalignment='center', fontsize=12)

    plt.tight_layout()

    # Save with database name
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(script_dir, f'job_{db_name.lower()}.pdf')
    plt.savefig(output_file, dpi=1200, bbox_inches='tight', format='pdf')
    plt.close()  # Close figure to free memory
    
    print(f"Saved {db_name} graph to {output_file}")
    print("---")

print("All job graphs processed!")
 