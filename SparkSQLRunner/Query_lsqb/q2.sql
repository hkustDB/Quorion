SELECT count(*)
FROM qPerson_knows_PersonR, dCommentd, hPosth
WHERE qPerson_knows_PersonR.Person1Id = dCommentd.hasCreator_PersonId
	AND qPerson_knows_PersonR.Person2Id = hPosth.hasCreator_PersonId
	AND dCommentd.replyOf_PostId = hPosth.PostId