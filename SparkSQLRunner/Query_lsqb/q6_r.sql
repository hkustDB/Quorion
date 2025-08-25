create or replace TEMP view aggView7636794185634025680 as select Person2Id as v2, COUNT(*) as annot, Person1Id as v1 from qPerson_knows_PersonR as pkp1 group by Person2Id,Person1Id;
create or replace TEMP view aggJoin1819473858348798039 as select Person2Id as v5, v1, annot from qPerson_knows_PersonR as pkp2, aggView7636794185634025680 where pkp2.Person1Id=aggView7636794185634025680.v2 and v1<Person2Id;
create or replace TEMP view aggView6742926062927419114 as select v5, SUM(annot) as annot from aggJoin1819473858348798039 group by v5;
create or replace TEMP view aggJoin4505350917981501734 as select PersonId as v5, annot from kPerson_hasInterest_TagM as kPerson_hasInterest_TagM, aggView6742926062927419114 where kPerson_hasInterest_TagM.PersonId=aggView6742926062927419114.v5;
select SUM(annot) as v7 from aggJoin4505350917981501734;
