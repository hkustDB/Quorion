import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter, MultipleLocator
from matplotlib.font_manager import FontProperties
import os

# List of graph names to iterate over
graph_names = ['graph', 'lsqb', 'tpch']

for graph_name in graph_names:
    print(f"Processing {graph_name}...")
    
    # 读取 Excel 文件的特定表单
    script_dir = os.path.dirname(os.path.abspath(__file__))
    primary_file = os.path.join(script_dir, '..', 'query', 'summary_' + graph_name + '_statistics.csv')
    fallback_file = os.path.join(script_dir, '..', 'query', 'summary_' + graph_name + '_statistics_default.csv')
    # sheet_name = 'draw-graph1'  # 替换为您想要读取的表单名称

    # 使用 pandas 读取 Excel 文件的特定表单
    try:
        df1 = pd.read_csv(primary_file, header=None).T
        print(f"Successfully loaded: {primary_file}")
    except FileNotFoundError:
        print(f"Successfully loaded: {fallback_file}")
        df1 = pd.read_csv(fallback_file, header=None).T

    df1.replace(['>24h', '>2h', '-1', 'X', 'OOM'], 0, inplace=True)
    for col in range(len(df1.columns)):
        df1.iloc[1:, col] = pd.to_numeric(df1.iloc[1:, col], errors='coerce').fillna(0)
    # threshold = 3600 * 2
    #num_queries = min(len(df1), 17)  # Use all available queries or 17, whichever is smaller

    # 替换大于阈值的浮点数值
    # df1 = df1.applymap(lambda x: 0 if isinstance(x, (int, float)) and x > threshold else x)

    print(df1.iloc[0].values)

    data = {
        'Graph': df1.iloc[0].values[1:19],
        'DuckDB native': df1.iloc[1].values[1:19],
        'DuckDB Yannakakis': df1.iloc[2].values[1:19],
        'DuckDB Yannakakis+': df1.iloc[3].values[1:19],
        'PostgreSQL native': df1.iloc[4].values[1:19],
        'PostgreSQL Yannakakis': df1.iloc[5].values[1:19],
        'PostgreSQL Yannakakis+': df1.iloc[6].values[1:19]
        # 'SparkSQL native': df1.iloc[7].values[1:10],
        # 'SparkSQL Yannakakis': df1.iloc[8].values[1:10],
        # 'SparkSQL Yannakakis+': df1.iloc[9].values[1:10]
    }

    # 在每个查询之间插入空值
    queries_with_gaps = []
    for query in data['Graph']:
        queries_with_gaps.append(query)
        # queries_with_gaps.append(' ')

    # 在数据列中插入 np.nan
    def add_gaps(values):
        values_with_gaps = []
        for value in values:
            values_with_gaps.append(value)
            # values_with_gaps.append(np.nan)
        return values_with_gaps

    data_with_gaps = {key: add_gaps(value) if key != 'Graph' else queries_with_gaps for key, value in data.items()}

    # 创建 DataFrame
    df = pd.DataFrame(data_with_gaps)

    # 设置柱状图的颜色
    # colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#FFB6C1', '#00ced1', '#deb887', '#87cefa', '#ff69b4']
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#a39e9b', '#00ced1', '#deb887', '#9467bd', '#bcbd22', '#FFB6C1', '#8dd3c7', '#fb8072', '#80b1d3']

    # 设置柱状图的花纹
    hatches = ['-', '\\', '||', '/', '++', 'x', '*', 'o', '.', '--', '///', '|||']
    hatch_linewidth = 0.2

    # 创建一个包含1个子图的图形
    fig, ax = plt.subplots(figsize=(50, 7))

    # 将数据组合成DataFrame
    db_data = df.set_index('Graph')

    # db_data.plot(kind='bar', ax=ax, color=colors, logy=True)

    # 绘制柱状图
    bar_width = 0.15
    indices = np.arange(len(db_data))

    bars = []
    for i, col in enumerate(db_data.columns):
        bar = ax.bar(indices + i * bar_width, db_data[col], bar_width, color=colors[i], hatch=hatches[i], label=col, edgecolor='#505050', linewidth=hatch_linewidth)
        bars.append(bar)

    ax.set_yscale('log')
    # ax.set_title('Graph Original vs Rewrite')
    ax.set_xlabel(graph_name, fontsize=25)
    ax.set_ylabel('Running Time (Sec)', fontsize=25)
    # ax.set_xlabel('Graph')
    ax.legend(['duckdb original', 'duckdb rewrite', 'adb original', 'adb rewrite', 'pg original', 'pg rewrite'], loc='upper right')

    # 设置横坐标的名称
    ax.set_xticks(indices + bar_width * (len(db_data.columns) - 1) / 2)
    ax.set_xticklabels(db_data.index, rotation=0)

    # 改小横坐标显示字体
    ax.tick_params(axis='x', labelsize=25)  # 将 10 替换为你需要的字体大小
    ax.tick_params(axis='y', labelsize=25)  # 将 10 替换为你需要的字体大小

    # 设置网格线
    ax.grid(True, which='major', linestyle='--', linewidth=0.5)

    # 设置纵坐标为科学记数法
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f'{x:.1e}'))
    # 设置图例字体属性
    font_properties = FontProperties()
    font_properties.set_size(23.5)  # 设置字体大小
    # font_properties.set_family('serif')  # 设置字体家族，例如 'serif', 'sans-serif', 'monospace' 等
    # font_properties.set_weight('bold')  # 设置字体粗细，例如 'normal', 'bold', 'light' 等
    # 先获取已有的句柄和标签
    handles, labels = ax.get_legend_handles_labels()


    # 自定义图例的顺序
    #custom_order = [
    #    'DuckDB native', 'PostgreSQL native', 'DuckDB Yannakakis', 'PostgreSQL Yannakakis', 'DuckDB Yannakakis+', 'PostgreSQL Yannakakis+', 'SparkSQL native', 'SparkSQL Yannakakis', 'SparkSQL Yannakakis+'
    #]
    custom_order = ['DuckDB native', 'DuckDB Yannakakis', 'DuckDB Yannakakis+', 'PostgreSQL native', 'PostgreSQL Yannakakis', 'PostgreSQL Yannakakis+']

    # 创建替换的图例标签，带上标的加号
    def format_label(label):
        if '+' in label:
            base_label = label.replace('+', '')
            return f'{base_label}$^+$'
        return label

    ordered_handles = [handles[labels.index(label)] for label in custom_order]
    ordered_labels = [format_label(label) for label in custom_order]

    # 添加图例（纵向优先）
    plt.legend(ordered_handles, ordered_labels, loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=6, frameon=False, prop=font_properties)

    # 获取数据中的最大值，并计算其上整的对数值
    max_y = df.iloc[:, 1:10].max().max()
    max_log_y = 10**4 # np.ceil(np.log10(max_y))

    # 设置纵坐标的范围
    plt.gca().set_ylim(top=max_log_y)

    # 调整布局
    plt.tight_layout()

    # 保存图像为高清PNG
    plt.savefig(os.path.join(script_dir, graph_name + '.pdf'), dpi=1200, bbox_inches='tight', format='pdf')
    plt.close()  # Close the figure to free memory

    print(f"Completed {graph_name}")
    print("---")

print("All graphs processed!")