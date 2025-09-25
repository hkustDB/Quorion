-- aka_name
CREATE FOREIGN TABLE aka_name_ext (
    id integer,
    person_id integer,
    name varchar(512),
    imdb_index varchar(3),
    name_pcode_cf varchar(11),
    name_pcode_nf varchar(11),
    surname_pcode varchar(11),
    md5sum varchar(65)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/aka_name.parquet');

CREATE TABLE IF NOT EXISTS aka_name (
    id integer PRIMARY KEY,
    person_id integer,
    name varchar(512),
    imdb_index varchar(3),
    name_pcode_cf varchar(11),
    name_pcode_nf varchar(11),
    surname_pcode varchar(11),
    md5sum varchar(65)
);
INSERT INTO aka_name SELECT * FROM aka_name_ext;


-- aka_title
CREATE FOREIGN TABLE aka_title_ext (
    id integer,
    movie_id integer,
    title varchar(553),
    imdb_index varchar(12),
    kind_id integer,
    production_year real,
    phonetic_code varchar(5),
    episode_of_id real,
    season_nr real,
    episode_nr real,
    note varchar(72),
    md5sum varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/aka_title.parquet');

CREATE TABLE IF NOT EXISTS aka_title (
    id integer PRIMARY KEY,
    movie_id integer NOT NULL,
    title varchar(553) NOT NULL,
    imdb_index varchar(12),
    kind_id integer NOT NULL,
    production_year real,
    phonetic_code varchar(5),
    episode_of_id real,
    season_nr real,
    episode_nr real,
    note varchar(72),
    md5sum varchar(32)
);
INSERT INTO aka_title SELECT * FROM aka_title_ext;


-- cast_info
CREATE FOREIGN TABLE cast_info_ext (
    id integer,
    person_id integer,
    movie_id integer,
    person_role_id real,
    note text,
    nr_order real,
    role_id integer
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/cast_info.parquet');

CREATE TABLE IF NOT EXISTS cast_info (
    id integer PRIMARY KEY,
    person_id integer,
    movie_id integer,
    person_role_id real,
    note text,
    nr_order real,
    role_id integer
);
INSERT INTO cast_info SELECT * FROM cast_info_ext;


-- char_name
CREATE FOREIGN TABLE char_name_ext (
    id integer,
    name varchar(512),
    imdb_index varchar(2),
    imdb_id real,
    name_pcode_nf varchar(5),
    surname_pcode varchar(5),
    md5sum varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/char_name.parquet');

CREATE TABLE IF NOT EXISTS char_name (
    id integer PRIMARY KEY,
    name varchar(512),
    imdb_index varchar(2),
    imdb_id real,
    name_pcode_nf varchar(5),
    surname_pcode varchar(5),
    md5sum varchar(32)
);
INSERT INTO char_name SELECT * FROM char_name_ext;


-- comp_cast_type
CREATE FOREIGN TABLE comp_cast_type_ext (
    id integer,
    kind varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/comp_cast_type.parquet');

CREATE TABLE IF NOT EXISTS comp_cast_type (
    id integer PRIMARY KEY,
    kind varchar(32)
);
INSERT INTO comp_cast_type SELECT * FROM comp_cast_type_ext;


-- company_name
CREATE FOREIGN TABLE company_name_ext (
    id integer,
    name varchar(512),
    country_code varchar(6),
    imdb_id real,
    name_pcode_nf varchar(5),
    name_pcode_sf varchar(5),
    md5sum varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/company_name.parquet');

CREATE TABLE IF NOT EXISTS company_name (
    id integer PRIMARY KEY,
    name varchar(512),
    country_code varchar(6),
    imdb_id real,
    name_pcode_nf varchar(5),
    name_pcode_sf varchar(5),
    md5sum varchar(32)
);
INSERT INTO company_name SELECT * FROM company_name_ext;


-- company_type
CREATE FOREIGN TABLE company_type_ext (
    id integer,
    kind varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/company_type.parquet');

CREATE TABLE IF NOT EXISTS company_type (
    id integer PRIMARY KEY,
    kind varchar(32)
);
INSERT INTO company_type SELECT * FROM company_type_ext;


-- complete_cast
CREATE FOREIGN TABLE complete_cast_ext (
    id integer,
    movie_id integer,
    subject_id integer,
    status_id integer
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/complete_cast.parquet');

CREATE TABLE IF NOT EXISTS complete_cast (
    id integer PRIMARY KEY,
    movie_id integer,
    subject_id integer,
    status_id integer
);
INSERT INTO complete_cast SELECT * FROM complete_cast_ext;


-- info_type
CREATE FOREIGN TABLE info_type_ext (
    id integer,
    info varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/info_type.parquet');

CREATE TABLE IF NOT EXISTS info_type (
    id integer PRIMARY KEY,
    info varchar(32)
);
INSERT INTO info_type SELECT * FROM info_type_ext;


-- keyword
CREATE FOREIGN TABLE keyword_ext (
    id integer,
    keyword varchar(512),
    phonetic_code varchar(5)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/keyword.parquet');

CREATE TABLE IF NOT EXISTS keyword (
    id integer PRIMARY KEY,
    keyword varchar(512),
    phonetic_code varchar(5)
);
INSERT INTO keyword SELECT * FROM keyword_ext;


-- kind_type
CREATE FOREIGN TABLE kind_type_ext (
    id integer,
    kind varchar(15)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/kind_type.parquet');

CREATE TABLE IF NOT EXISTS kind_type (
    id integer PRIMARY KEY,
    kind varchar(15)
);
INSERT INTO kind_type SELECT * FROM kind_type_ext;


-- link_type
CREATE FOREIGN TABLE link_type_ext (
    id integer,
    link varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/link_type.parquet');

CREATE TABLE IF NOT EXISTS link_type (
    id integer PRIMARY KEY,
    link varchar(32)
);
INSERT INTO link_type SELECT * FROM link_type_ext;


-- movie_companies
CREATE FOREIGN TABLE movie_companies_ext (
    id integer,
    movie_id integer,
    company_id integer,
    company_type_id integer,
    note text
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/movie_companies.parquet');

CREATE TABLE IF NOT EXISTS movie_companies (
    id integer PRIMARY KEY,
    movie_id integer,
    company_id integer,
    company_type_id integer,
    note text
);
INSERT INTO movie_companies SELECT * FROM movie_companies_ext;


-- movie_info
CREATE FOREIGN TABLE movie_info_ext (
    id integer,
    movie_id integer,
    info_type_id integer,
    info text,
    note text
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/movie_info.parquet');

CREATE TABLE IF NOT EXISTS movie_info (
    id integer PRIMARY KEY,
    movie_id integer,
    info_type_id integer,
    info text,
    note text
);
INSERT INTO movie_info SELECT * FROM movie_info_ext;


-- movie_info_idx
CREATE FOREIGN TABLE movie_info_idx_ext (
    id integer,
    movie_id integer,
    info_type_id integer,
    info text,
    note text
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/movie_info_idx.parquet');

CREATE TABLE IF NOT EXISTS movie_info_idx (
    id integer PRIMARY KEY,
    movie_id integer,
    info_type_id integer,
    info text,
    note text
);
INSERT INTO movie_info_idx SELECT * FROM movie_info_idx_ext;


-- movie_keyword
CREATE FOREIGN TABLE movie_keyword_ext (
    id integer,
    movie_id integer,
    keyword_id integer
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/movie_keyword.parquet');

CREATE TABLE IF NOT EXISTS movie_keyword (
    id integer PRIMARY KEY,
    movie_id integer,
    keyword_id integer
);
INSERT INTO movie_keyword SELECT * FROM movie_keyword_ext;


-- movie_link
CREATE FOREIGN TABLE movie_link_ext (
    id integer,
    movie_id integer,
    linked_movie_id integer,
    link_type_id integer
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/movie_link.parquet');

CREATE TABLE IF NOT EXISTS movie_link (
    id integer PRIMARY KEY,
    movie_id integer,
    linked_movie_id integer,
    link_type_id integer
);
INSERT INTO movie_link SELECT * FROM movie_link_ext;


-- name
CREATE FOREIGN TABLE name_ext (
    id integer,
    name varchar(512),
    imdb_index varchar(9),
    imdb_id real,
    gender varchar(1),
    name_pcode_cf varchar(5),
    name_pcode_nf varchar(5),
    surname_pcode varchar(5),
    md5sum varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/name.parquet');

CREATE TABLE IF NOT EXISTS name (
    id integer PRIMARY KEY,
    name varchar(512),
    imdb_index varchar(9),
    imdb_id real,
    gender varchar(1),
    name_pcode_cf varchar(5),
    name_pcode_nf varchar(5),
    surname_pcode varchar(5),
    md5sum varchar(32)
);
INSERT INTO name SELECT * FROM name_ext;


-- role_type
CREATE FOREIGN TABLE role_type_ext (
    id integer,
    role varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/role_type.parquet');

CREATE TABLE IF NOT EXISTS role_type (
    id integer PRIMARY KEY,
    role varchar(32)
);
INSERT INTO role_type SELECT * FROM role_type_ext;


-- title
CREATE FOREIGN TABLE title_ext (
    id integer,
    title varchar(512),
    imdb_index varchar(5),
    kind_id integer,
    production_year real,
    imdb_id real,
    phonetic_code varchar(5),
    episode_of_id real,
    season_nr real,
    episode_nr real,
    series_years varchar(49),
    md5sum varchar(32)
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/title.parquet');

CREATE TABLE IF NOT EXISTS title (
    id integer PRIMARY KEY,
    title varchar(512),
    imdb_index varchar(5),
    kind_id integer,
    production_year real,
    imdb_id real,
    phonetic_code varchar(5),
    episode_of_id real,
    season_nr real,
    episode_nr real,
    series_years varchar(49),
    md5sum varchar(32)
);
INSERT INTO title SELECT * FROM title_ext;


-- person_info
CREATE FOREIGN TABLE person_info_ext (
    id integer,
    person_id integer,
    info_type_id integer,
    info text,
    note text
) SERVER parquet_srv OPTIONS (filename '/PATH_TO_JOB_DATA/person_info.parquet');

CREATE TABLE IF NOT EXISTS person_info (
    id integer PRIMARY KEY,
    person_id integer,
    info_type_id integer,
    info text,
    note text
);
INSERT INTO person_info SELECT * FROM person_info_ext;