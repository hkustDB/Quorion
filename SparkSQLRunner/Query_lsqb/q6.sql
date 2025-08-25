SELECT count(*)
FROM qPerson_knows_PersonR pkp1, qPerson_knows_PersonR pkp2, kPerson_hasInterest_TagM
WHERE pkp1.Person2Id = pkp2.Person1Id
	AND pkp1.Person1Id < pkp2.Person2Id
	AND kPerson_hasInterest_TagM.PersonId = pkp2.Person2Id