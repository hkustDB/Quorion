import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter
import numpy as np
from matplotlib.font_manager import FontProperties
import os

thread_names = ['1', '2']

for thread_name in thread_names:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    primary_file = os.path.join(script_dir, '..', 'query', 'summary_thread_' + thread_name + '_statistics.csv')
    fallback_file = os.path.join(script_dir, '..', 'query', 'summary_thread_' + thread_name + '_statistics_default.csv')

    # 使用 pandas 读取 Excel 文件的特定表单
    try:
        df = pd.read_csv(primary_file)  # Remove header=None to read column names
        print(f"Successfully loaded: {primary_file}")
    except FileNotFoundError:
        print(f"Successfully loaded: {fallback_file}")
        df = pd.read_csv(fallback_file)  # Remove header=None to read column names

    # 检查数据是否正确读取
    print(df.head())
    print("Column names:", df.columns.tolist())

    if thread_name == '2':
        columns_to_plot = ['LSQB SparkSQL native', 'LSQB SparkSQL Yannakakis+']
    elif thread_name == '1':
        columns_to_plot = ['SGPB SparkSQL native', 'SGPB SparkSQL Yannakakis+']
    else:
        # Default or fallback
        columns_to_plot = ['SGPB SparkSQL native', 'SGPB SparkSQL Yannakakis+']

    # 更新图例标签，将 Yannakakis+ 的右上角添加加号
    updated_labels = {column: column.replace('Yannakakis+', r'Yannakakis$^{+}$') for column in columns_to_plot}

    # 设置不同的标志和颜色（扩展到长度为8）
    markers = ['o', 's', 'd', '|']
    colors = ['#2E8B57', '#6A5ACD', '#DAA520', '#8B4513']

    # 绘制折线图并设置对数坐标
    plt.figure(figsize=(9, 4.5))

    # 绘制需要显示在图例中的数据系列
    for i, column in enumerate(columns_to_plot):
        plt.plot(df['thread'], df[column], marker=markers[i % len(markers) + 2], color=colors[i % len(colors) + 2], label=updated_labels[column], markerfacecolor='none', clip_on=False, markersize=10)

    i = 0
    # 绘制不需要显示在图例中的数据系列
    for column in df.columns[1:]:
        if column not in columns_to_plot:
            plt.plot(df['thread'], df[column], marker=markers[i], color=colors[i], label='_nolegend_', markerfacecolor='none', clip_on=False, markersize=10)
            i = i + 1
    # 设置对数坐标
    plt.yscale('log')

    # 设置轴标签和标题
    plt.xlabel('Parallelism', fontsize=16)
    plt.ylabel('Running Time (Sec)', fontsize=16)
    # plt.title('Performance Comparison of Different Databases')

    # 只显示对应点的横坐标，并转换为百分比格式
    thread = df['thread']
    plt.xticks(df['thread'], [f'{x}' for x in thread])

    # 显示图例
    plt.legend()

    # 显示网格
    plt.grid(True, which="major", ls="--")

    # 设置图例字体属性
    font_properties = FontProperties()
    font_properties.set_size(16)  # 设置字体大小

    # 添加图例
    plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=4, frameon=False, prop=font_properties)

    # 纵坐标数据不使用指数表示，全部显示，并从1开始
    plt.gca().yaxis.set_major_formatter(ScalarFormatter())
    plt.gca().yaxis.get_major_formatter().set_useOffset(False)

    # 获取数据中的最大值，并计算其上整的对数值
    max_y = df.iloc[:, 1:].max().max()
    max_log_y = 10**np.ceil(np.log10(max_y))

    # 改小横坐标显示字体
    plt.tick_params(axis='x', labelsize=16)  # 将 10 替换为你需要的字体大小
    plt.tick_params(axis='y', labelsize=16)  # 将 10 替换为你需要的字体大小

    # 设置纵坐标的范围
    plt.gca().set_xlim(left=df['thread'].iloc[0], right=df['thread'].iloc[-1])
    plt.gca().set_ylim(bottom=1, top=max_log_y)

    # 调整布局
    plt.tight_layout()

    # Save with thread_name in filename
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(script_dir, f'thread{thread_name}.pdf')
    plt.savefig(output_file, dpi=1200, bbox_inches='tight', format='pdf')
    plt.close()  # Close figure to free memory
    
    print(f"Completed thread graph for {thread_name}")
    print("---")

print("All thread graphs processed!")
