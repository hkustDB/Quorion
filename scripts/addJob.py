import pyarrow.parquet as pq
import pyarrow as pa
import pandas as pd
import csv
import sys

csv.field_size_limit(sys.maxsize)

# column has `_id`
trans_idx = {'aka_name': [1], 'aka_title': [1, 4, 7], 'cast_info': [1, 2, 3, 6], 
             'char_name': [3], 'comp_cast_type': [], 'company_name': [3],
             'company_type': [], 'complete_cast': [1, 2, 3], 'info_type': [],
             'keyword': [], 'kind_type': [], 'link_type': [], 'movie_companies': [1, 2, 3],
             'movie_info_idx': [1, 2], 'movie_keyword': [1, 2], 'movie_link': [1, 2, 3],
             'name': [3], 'role_type': [], 'title': [3, 5, 7], 'movie_info': [1, 2],
             'person_info': [1, 2]}

schema = {'aka_name': [('id', pa.int32()), ('person_id', pa.int32()), ('name', pa.string()), ('imdb_index', pa.string()), ('name_pcode_cf', pa.string()), ('name_pcode_nf', pa.string()), ('surname_pcode', pa.string()), ('md5sum', pa.string())], 
          'aka_title': [('id', pa.int32()), ('movie_id', pa.int32()), ('title', pa.string()), ('imdb_index', pa.string()), ('kind_id', pa.int32()), ('production_year', pa.int32()), ('phonetic_code', pa.string()), ('episode_of_id', pa.int32()), ('season_nr', pa.int32()), ('episode_nr', pa.int32()), ('note', pa.string()), ('md5sum', pa.string())],
          'cast_info': [('id', pa.int32()), ('person_id', pa.int32()), ('movie_id', pa.int32()), ('person_role_id', pa.int32()), ('note', pa.string()), ('nr_order', pa.int32()), ('role_id', pa.int32())],
          'char_name': [('id', pa.int32()), ('name', pa.string()), ('imdb_index', pa.string()), ('imdb_id', pa.int32()), ('name_pcode_nf', pa.string()), ('surname_pcode', pa.string()), ('md5sum', pa.string())], 
          'comp_cast_type': [('id', pa.int32()), ('kind', pa.string())], 
          'company_name': [('id', pa.int32()), ('name', pa.string()), ('country_code', pa.string()), ('imdb_id', pa.int32()), ('name_pcode_nf', pa.string()), ('name_pcode_sf', pa.string()), ('md5sum', pa.string())],
          'company_type': [('id', pa.int32()), ('kind', pa.string())], 
          'complete_cast': [('id', pa.int32()), ('movie_id', pa.int32()), ('subject_id', pa.int32()), ('status_id', pa.int32())], 
          'info_type': [('id', pa.int32()), ('info', pa.string())],
          'keyword': [('id', pa.int32()), ('keyword', pa.string()), ('phonetic_code', pa.string())], 
          'kind_type': [('id', pa.int32()), ('kind', pa.string())], 
          'link_type': [('id', pa.int32()), ('link', pa.string())], 
          'movie_companies': [('id', pa.int32()), ('movie_id', pa.int32()), ('company_id', pa.int32()), ('company_type_id', pa.int32()), ('note', pa.string())],
          'movie_info_idx': [('id', pa.int32()), ('movie_id', pa.int32()), ('info_type_id', pa.int32()), ('info', pa.string()), ('note', pa.string())], 
          'movie_keyword': [('id', pa.int32()), ('movie_id', pa.int32()), ('keyword_id', pa.int32())], 
          'movie_link': [('id', pa.int32()), ('movie_id', pa.int32()), ('linked_movie_id', pa.int32()), ('link_type_id', pa.int32())],
          'name': [('id', pa.int32()), ('name', pa.string()), ('imdb_index', pa.string()), ('imdb_id', pa.int32()), ('gender', pa.string()), ('name_pcode_cf', pa.string()), ('name_pcode_nf', pa.string()), ('surname_pcode', pa.string()), ('md5sum', pa.string())], 
          'role_type': [('id', pa.int32()), ('role', pa.string())], 
          'title': [('id', pa.int32()), ('title', pa.string()), ('imdb_index', pa.string()), ('kind_id', pa.int32()), ('production_year', pa.int32()), ('imdb_id', pa.int32()), ('phonetic_code', pa.string()), ('episode_of_id', pa.int32()), ('season_nr', pa.int32()), ('episode_nr', pa.int32()), ('series_years', pa.string()), ('md5sum', pa.string())], 
          'movie_info': [('id', pa.int32()), ('movie_id', pa.int32()), ('info_type_id', pa.int32()), ('info', pa.string()), ('note', pa.string())],
          'person_info': [('id', pa.int32()), ('person_id', pa.int32()), ('info_type_id', pa.int32()), ('info', pa.string()), ('note', pa.string())]}

import os
# Get the directory of the current script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Set data paths relative to the script path
PATH_CSV = os.path.join(SCRIPT_DIR, '../Data/job/')
PATH_PARQUET = os.path.join(SCRIPT_DIR, '../Data/job/')


def process(name: str, type: str = "csv", add: int = 36244400):
    if type == "parquet":
        new_gen = {}
        parquet_file = pq.ParquetFile(PATH_PARQUET + 'job_' + name + '.parquet')
        table = parquet_file.read()
        column_names = table.column_names
        for idx, col_name in enumerate(column_names):
            if idx == 0 or idx in trans_idx[name]:
                column_data = table.column(col_name).to_pylist()
                for idx, x in enumerate(column_data):
                    try:
                        column_data[idx] = x + add
                    except:
                        pass
                new_gen[col_name] = column_data
            else:
                column_data = table.column(col_name).to_pylist()
                new_gen[col_name] = column_data
        df = pd.DataFrame(new_gen)
        table1 = pa.Table.from_pandas(df, pa.schema(schema[name]))
        pq.write_table(table1, PATH_PARQUET + 'new/' + name + '_' + str(add//36244400) + '.parquet')
    
    elif type == "csv":
        new_gen = []
        with open(PATH_CSV + name + '.csv', newline='') as csvfile:
            spamreader = csv.reader(csvfile, delimiter=',')
            for row in spamreader:
                row[0] = str(int(row[0]) + add)
                for idx in trans_idx[name]:
                    try:
                        row[idx] = int(row[idx]) + add
                    except:
                        pass
                new_gen.append(row)
        with open(PATH_CSV + 'new/' + name + '_' + str(add//36244400) + '.csv', 'w') as csvfile:
            spamwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            spamwriter.writerows(new_gen)


if __name__ == '__main__':
    tables = ['aka_name', 'aka_title', 'cast_info', 'char_name', 'comp_cast_type', 'company_name', 'company_type', 'complete_cast', 'info_type', 'keyword', 'kind_type', 'link_type', 'movie_companies', 'movie_info_idx', 'movie_keyword', 'movie_link', 'name', 'role_type', 'title', 'movie_info', 'person_info']
    for iter in range(-50, 50):
        for table in tables:
            process(table, type="parquet", add=36244400*iter)
    