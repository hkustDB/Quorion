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
COPY aka_name FROM '/home/data/bchenba/Quorion/Data/job/job_aka_name.csv' WITH (FORMAT csv, HEADER true);


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
COPY aka_title FROM '/home/data/bchenba/Quorion/Data/job/job_aka_title.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS cast_info (
    id integer PRIMARY KEY,
    person_id integer,
    movie_id integer,
    person_role_id real,
    note text,
    nr_order real,
    role_id integer
);
COPY cast_info FROM '/home/data/bchenba/Quorion/Data/job/job_cast_info.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS char_name (
    id integer PRIMARY KEY,
    name varchar(512),
    imdb_index varchar(2),
    imdb_id real,
    name_pcode_nf varchar(5),
    surname_pcode varchar(5),
    md5sum varchar(32)
);
COPY char_name FROM '/home/data/bchenba/Quorion/Data/job/job_char_name.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS comp_cast_type (
    id integer PRIMARY KEY,
    kind varchar(32)
);
COPY comp_cast_type FROM '/home/data/bchenba/Quorion/Data/job/job_comp_cast_type.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS company_name (
    id integer PRIMARY KEY,
    name varchar(512),
    country_code varchar(6),
    imdb_id real,
    name_pcode_nf varchar(5),
    name_pcode_sf varchar(5),
    md5sum varchar(32)
);
COPY company_name FROM '/home/data/bchenba/Quorion/Data/job/job_company_name.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS company_type (
    id integer PRIMARY KEY,
    kind varchar(32)
);
COPY company_type FROM '/home/data/bchenba/Quorion/Data/job/job_company_type.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS complete_cast (
    id integer PRIMARY KEY,
    movie_id integer,
    subject_id integer,
    status_id integer
);
COPY complete_cast FROM '/home/data/bchenba/Quorion/Data/job/job_complete_cast.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS info_type (
    id integer PRIMARY KEY,
    info varchar(32)
);
COPY info_type FROM '/home/data/bchenba/Quorion/Data/job/job_info_type.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS keyword (
    id integer PRIMARY KEY,
    keyword varchar(512),
    phonetic_code varchar(5)
);
COPY keyword FROM '/home/data/bchenba/Quorion/Data/job/job_keyword.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS kind_type (
    id integer PRIMARY KEY,
    kind varchar(15)
);
COPY kind_type FROM '/home/data/bchenba/Quorion/Data/job/job_kind_type.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS link_type (
    id integer PRIMARY KEY,
    link varchar(32)
);
COPY link_type FROM '/home/data/bchenba/Quorion/Data/job/job_link_type.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS movie_companies (
    id integer PRIMARY KEY,
    movie_id integer,
    company_id integer,
    company_type_id integer,
    note text
);
COPY movie_companies FROM '/home/data/bchenba/Quorion/Data/job/job_movie_companies.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS movie_info (
    id integer PRIMARY KEY,
    movie_id integer,
    info_type_id integer,
    info text,
    note text
);
COPY movie_info FROM '/home/data/bchenba/Quorion/Data/job/job_movie_info.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS movie_info_idx (
    id integer PRIMARY KEY,
    movie_id integer,
    info_type_id integer,
    info text,
    note text
);
COPY movie_info_idx FROM '/home/data/bchenba/Quorion/Data/job/job_movie_info_idx.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS movie_keyword (
    id integer PRIMARY KEY,
    movie_id integer,
    keyword_id integer
);
COPY movie_keyword FROM '/home/data/bchenba/Quorion/Data/job/job_movie_keyword.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS movie_link (
    id integer PRIMARY KEY,
    movie_id integer,
    linked_movie_id integer,
    link_type_id integer
);
COPY movie_link FROM '/home/data/bchenba/Quorion/Data/job/job_movie_link.csv' WITH (FORMAT csv, HEADER true);


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
COPY name FROM '/home/data/bchenba/Quorion/Data/job/job_name.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS role_type (
    id integer PRIMARY KEY,
    role varchar(32)
);
COPY role_type FROM '/home/data/bchenba/Quorion/Data/job/job_role_type.csv' WITH (FORMAT csv, HEADER true);


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
COPY title FROM '/home/data/bchenba/Quorion/Data/job/job_title.csv' WITH (FORMAT csv, HEADER true);


CREATE TABLE IF NOT EXISTS person_info (
    id integer PRIMARY KEY,
    person_id integer,
    info_type_id integer,
    info text,
    note text
);
COPY person_info FROM '/home/data/bchenba/Quorion/Data/job/job_person_info.csv' WITH (FORMAT csv, HEADER true);