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
create or replace TEMP view aggView6293996079660413682 as select ParentMessageId as v1, COUNT(*) as annot from uComment_replyOf_MessageV as uComment_replyOf_MessageV group by ParentMessageId;
create or replace TEMP view aggJoin6572177568480519788 as select MessageId as v1, annot from wMessage_hasCreator_PersonX as wMessage_hasCreator_PersonX, aggView6293996079660413682 where wMessage_hasCreator_PersonX.MessageId=aggView6293996079660413682.v1;
create or replace TEMP view aggView2728127958913269114 as select MessageId as v1, COUNT(*) as annot from yMessage_hasTag_TagZ as yMessage_hasTag_TagZ group by MessageId;
create or replace TEMP view aggJoin1473050505517514969 as select v1, aggJoin6572177568480519788.annot * aggView2728127958913269114.annot as annot from aggJoin6572177568480519788 join aggView2728127958913269114 using(v1);
create or replace TEMP view aggView5943644879001873230 as select v1, SUM(annot) as annot from aggJoin1473050505517514969 group by v1;
create or replace TEMP view aggJoin3277357768901936988 as select annot from pPerson_likes_Messagep as pPerson_likes_Messagep, aggView5943644879001873230 where pPerson_likes_Messagep.MessageId=aggView5943644879001873230.v1;
select SUM(annot) as v9 from aggJoin3277357768901936988;
