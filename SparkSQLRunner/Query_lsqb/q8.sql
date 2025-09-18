CREATE TEMP VIEW uComment_replyOf_MessageV AS
  SELECT CommentId, replyOf_PostId AS ParentMessageId FROM dCommentd
  WHERE replyOf_PostId IS NOT NULL
  UNION ALL
  SELECT CommentId, replyOf_CommentId AS ParentMessageId FROM dCommentd
  WHERE replyOf_CommentId IS NOT NULL;
CREATE TEMP VIEW yMessage_hasTag_TagZ AS
  SELECT CommentId AS MessageId, TagId FROM eComment_hasTag_TagF
  UNION ALL
  SELECT PostId AS MessageId, TagId FROM gPost_hasTag_TagH;
SELECT count(*)
FROM yMessage_hasTag_TagZ, uComment_replyOf_MessageV, eComment_hasTag_TagF AS cht1, eComment_hasTag_TagF AS cht2
WHERE yMessage_hasTag_TagZ.MessageId = uComment_replyOf_MessageV.ParentMessageId
	AND yMessage_hasTag_TagZ.TagId = cht1.TagId
  AND uComment_replyOf_MessageV.CommentId = cht2.CommentId
  AND yMessage_hasTag_TagZ.TagId < cht2.TagId