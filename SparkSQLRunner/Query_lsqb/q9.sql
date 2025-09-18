SELECT count(*)
FROM qPerson_knows_PersonR pkp1, qPerson_knows_PersonR pkp2, kPerson_hasInterest_TagM, qPerson_knows_PersonR pkp3
WHERE pkp1.Person2Id = pkp2.Person1Id
	AND pkp2.Person2Id = pkp3.Person1Id
	AND pkp1.Person1Id < pkp3.Person1Id
	AND pkp3.Person1Id = kPerson_hasInterest_TagM.PersonId
  