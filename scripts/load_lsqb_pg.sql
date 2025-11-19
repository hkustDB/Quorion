CREATE TABLE Company (
    CompanyId bigint,
    isLocatedIn_CountryId bigint,
    PRIMARY KEY (CompanyId)
);
COPY Company FROM '/home/data/bchenba/Quorion/Data/lsqb/Company.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE University (
    UniversityId bigint,
    isLocatedIn_CityId bigint,
    PRIMARY KEY (UniversityId)
);
COPY University FROM '/home/data/bchenba/Quorion/Data/lsqb/University.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Continent (
    ContinentId bigint,
    PRIMARY KEY (ContinentId)
);
COPY Continent FROM '/home/data/bchenba/Quorion/Data/lsqb/Continent.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Country (
    CountryId bigint,
    isPartOf_ContinentId bigint,
    PRIMARY KEY (CountryId)
);
COPY Country FROM '/home/data/bchenba/Quorion/Data/lsqb/Country.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE City (
    CityId bigint,
    isPartOf_CountryId bigint,
    PRIMARY KEY (CityId)
);
COPY City FROM '/home/data/bchenba/Quorion/Data/lsqb/City.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Tag (
    TagId bigint,
    hasType_TagClassId bigint,
    PRIMARY KEY (TagId)
);
COPY Tag FROM '/home/data/bchenba/Quorion/Data/lsqb/Tag.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE TagClass (
    TagClassId bigint,
    isSubclassOf_TagClassId bigint,
    PRIMARY KEY (TagClassId)
);
COPY TagClass FROM '/home/data/bchenba/Quorion/Data/lsqb/TagClass.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Forum (
    ForumId bigint,
    hasModerator_PersonId bigint,
    PRIMARY KEY (ForumId)
);
COPY Forum FROM '/home/data/bchenba/Quorion/Data/lsqb/Forum.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Comment (
    CommentId bigint,
    hasCreator_PersonId bigint,
    isLocatedIn_CountryId bigint,
    replyOf_PostId bigint,
    replyOf_CommentId bigint,
    PRIMARY KEY (CommentId)
);
COPY Comment FROM '/home/data/bchenba/Quorion/Data/lsqb/Comment.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Post (
    PostId bigint,
    hasCreator_PersonId bigint,
    Forum_containerOfId bigint,
    isLocatedIn_CountryId bigint,
    PRIMARY KEY (PostId)
);
COPY Post FROM '/home/data/bchenba/Quorion/Data/lsqb/Post.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person (
    PersonId bigint,
    isLocatedIn_CityId bigint,
    PRIMARY KEY (PersonId)
);
COPY Person FROM '/home/data/bchenba/Quorion/Data/lsqb/Person.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Comment_hasTag_Tag (
    CommentId bigint,
    TagId bigint,
    PRIMARY KEY (CommentId, TagId)
);
COPY Comment_hasTag_Tag FROM '/home/data/bchenba/Quorion/Data/lsqb/Comment_hasTag_Tag.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Post_hasTag_Tag (
    PostId bigint,
    TagId bigint,
    PRIMARY KEY (PostId, TagId)
);
COPY Post_hasTag_Tag FROM '/home/data/bchenba/Quorion/Data/lsqb/Post_hasTag_Tag.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Forum_hasMember_Person (
    ForumId bigint,
    PersonId bigint,
    PRIMARY KEY (ForumId, PersonId)
);
COPY Forum_hasMember_Person FROM '/home/data/bchenba/Quorion/Data/lsqb/Forum_hasMember_Person.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Forum_hasTag_Tag (
    ForumId bigint,
    TagId bigint,
    PRIMARY KEY (ForumId, TagId)
);
COPY Forum_hasTag_Tag FROM '/home/data/bchenba/Quorion/Data/lsqb/Forum_hasTag_Tag.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_hasInterest_Tag (
    PersonId bigint,
    TagId bigint,
    PRIMARY KEY (PersonId, TagId)
);
COPY Person_hasInterest_Tag FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_hasInterest_Tag.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_likes_Comment (
    PersonId bigint,
    CommentId bigint,
    PRIMARY KEY (PersonId, CommentId)
);
COPY Person_likes_Comment FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_likes_Comment.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_likes_Post (
    PersonId bigint,
    PostId bigint,
    PRIMARY KEY (PersonId, PostId)
);
COPY Person_likes_Post FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_likes_Post.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_studyAt_University (
    PersonId bigint,
    UniversityId bigint,
    PRIMARY KEY (PersonId)
);
COPY Person_studyAt_University FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_studyAt_University.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_workAt_Company (
    PersonId bigint,
    CompanyId bigint,
    PRIMARY KEY (PersonId, CompanyId)
);
COPY Person_workAt_Company FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_workAt_Company.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_knows_Person (
    Person1Id bigint,
    Person2Id bigint,
    PRIMARY KEY (Person1Id, Person2Id)
);
COPY Person_knows_Person FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_knows_Person.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

CREATE TABLE Person_knows_Person2 (
    Person1Id bigint,
    Person2Id bigint,
    PRIMARY KEY (Person1Id, Person2Id)
);
COPY Person_knows_Person2 FROM '/home/data/bchenba/Quorion/Data/lsqb/Person_knows_Person.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true);

INSERT INTO Person_knows_Person
SELECT Person2Id, Person1Id FROM Person_knows_Person2;

CREATE VIEW Message AS
  SELECT CommentId AS MessageId FROM Comment
  UNION ALL
  SELECT PostId AS MessageId FROM Post;

CREATE VIEW Comment_replyOf_Message AS
  SELECT CommentId, replyOf_PostId AS ParentMessageId FROM Comment
  WHERE replyOf_PostId IS NOT NULL
  UNION ALL
  SELECT CommentId, replyOf_CommentId AS ParentMessageId FROM Comment
  WHERE replyOf_CommentId IS NOT NULL;

CREATE VIEW Message_hasCreator_Person AS
  SELECT CommentId AS MessageId, hasCreator_PersonId FROM Comment
  UNION ALL
  SELECT PostId AS MessageId, hasCreator_PersonId FROM Post;

CREATE VIEW Message_hasTag_Tag AS
  SELECT CommentId AS MessageId, TagId FROM Comment_hasTag_Tag
  UNION ALL
  SELECT PostId AS MessageId, TagId FROM Post_hasTag_Tag;

CREATE VIEW Message_isLocatedIn_Country AS
  SELECT CommentId AS MessageId, isLocatedIn_CountryId FROM Comment
  UNION ALL
  SELECT PostId AS MessageId, isLocatedIn_CountryId FROM Post;

CREATE VIEW Person_likes_Message AS
  SELECT PersonId, CommentId AS MessageId FROM Person_likes_Comment
  UNION ALL
  SELECT PersonId, PostId AS MessageId FROM Person_likes_Post;