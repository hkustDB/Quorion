SELECT count(*)
FROM cCountryD, City, lPersonl, mForum_hasMember_PersonN, QForumQ, hPosth, dCommentd, eComment_hasTag_TagF, aTagB, cTagClassD
WHERE City.isPartOf_CountryId = cCountryD.CountryId 
	AND lPersonl.isLocatedIn_CityId = City.CityId
	AND mForum_hasMember_PersonN.PersonId = lPersonl.PersonId
	AND QForumQ.ForumId = mForum_hasMember_PersonN.ForumId
	AND hPosth.Forum_containerOfId = QForumQ.ForumId
	AND dCommentd.replyOf_PostId = hPosth.PostId
	AND eComment_hasTag_TagF.CommentId = dCommentd.CommentId
	AND aTagB.TagId = eComment_hasTag_TagF.TagId
	AND aTagB.hasType_TagClassId = cTagClassD.TagClassId