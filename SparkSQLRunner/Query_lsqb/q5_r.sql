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
create or replace TEMP view aggJoin7088370141002342232 as select CommentId as v3, TagId as v2 from uComment_replyOf_MessageV as uComment_replyOf_MessageV, yMessage_hasTag_TagZ where uComment_replyOf_MessageV.ParentMessageId=yMessage_hasTag_TagZ.MessageId;
create or replace TEMP view aggView6137422278504846137 as select v3, COUNT(*) as annot, v2 from aggJoin7088370141002342232 group by v3,v2;
select SUM(annot) from eComment_hasTag_TagF as cht, aggView6137422278504846137 where cht.CommentId=aggView6137422278504846137.v3 and v2<TagId;
