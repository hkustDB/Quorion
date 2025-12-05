CREATE TEMP VIEW uComment_replyOf_MessageV AS
  SELECT CommentId, replyOf_PostId AS ParentMessageId FROM dCommentd
  WHERE replyOf_PostId IS NOT NULL
  UNION ALL
  SELECT CommentId, replyOf_CommentId AS ParentMessageId FROM dCommentd
  WHERE replyOf_CommentId IS NOT NULL;
CREATE TEMP VIEW wMessage_hasCreator_PersonX AS
  SELECT CommentId AS MessageId, hasCreator_PersonId FROM dCommentd
  UNION ALL
  SELECT PostId AS MessageId, hasCreator_PersonId FROM hPosth;
CREATE TEMP VIEW yMessage_hasTag_TagZ AS
  SELECT CommentId AS MessageId, TagId FROM eComment_hasTag_TagF
  UNION ALL
  SELECT PostId AS MessageId, TagId FROM gPost_hasTag_TagH;
CREATE TEMP VIEW pPerson_likes_Messagep AS
  SELECT PersonId, CommentId AS MessageId FROM APerson_likes_CommentC
  UNION ALL
  SELECT PersonId, PostId AS MessageId FROM oPerson_likes_PostP;
SELECT count(*)
FROM yMessage_hasTag_TagZ, wMessage_hasCreator_PersonX, uComment_replyOf_MessageV, pPerson_likes_Messagep
WHERE yMessage_hasTag_TagZ.MessageId = wMessage_hasCreator_PersonX.MessageId
	AND uComment_replyOf_MessageV.ParentMessageId = yMessage_hasTag_TagZ.MessageId
	AND pPerson_likes_Messagep.MessageId = yMessage_hasTag_TagZ.MessageId