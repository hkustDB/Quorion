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
create or replace TEMP view aggView3224023057782437398 as select CommentId as v3, TagId as v8 from eComment_hasTag_TagF as cht2;
create or replace TEMP view aggJoin2619926474122071689 as select ParentMessageId as v1, v8 from uComment_replyOf_MessageV as uComment_replyOf_MessageV, aggView3224023057782437398 where uComment_replyOf_MessageV.CommentId=aggView3224023057782437398.v3;
create or replace TEMP view aggView6798124248633932693 as select v1, COUNT(*) as annot, v8 from aggJoin2619926474122071689 group by v1,v8;
create or replace TEMP view aggJoin3867128414820336311 as select TagId as v2, v8, annot from yMessage_hasTag_TagZ as yMessage_hasTag_TagZ, aggView6798124248633932693 where yMessage_hasTag_TagZ.MessageId=aggView6798124248633932693.v1 and TagId<v8;
create or replace TEMP view aggView4861162616933587969 as select v2, SUM(annot) as annot from aggJoin3867128414820336311 group by v2;
create or replace TEMP view aggJoin5290146489873307442 as select annot from eComment_hasTag_TagF as cht1, aggView4861162616933587969 where cht1.TagId=aggView4861162616933587969.v2;
select SUM(annot) as v9 from aggJoin5290146489873307442;
