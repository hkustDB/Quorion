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
create or replace TEMP view aggView8586365770525352939 as select MessageId as v1, COUNT(*) as annot from pPerson_likes_Messagep as pPerson_likes_Messagep group by MessageId;
create or replace TEMP view aggJoin9138834255299981955 as select MessageId as v1, annot from wMessage_hasCreator_PersonX as wMessage_hasCreator_PersonX, aggView8586365770525352939 where wMessage_hasCreator_PersonX.MessageId=aggView8586365770525352939.v1;
create or replace TEMP view aggView6248134116234837482 as select ParentMessageId as v1, COUNT(*) as annot from uComment_replyOf_MessageV as uComment_replyOf_MessageV group by ParentMessageId;
create or replace TEMP view aggJoin9004735239590972917 as select v1, aggJoin9138834255299981955.annot * aggView6248134116234837482.annot as annot from aggJoin9138834255299981955 join aggView6248134116234837482 using(v1);
create or replace TEMP view aggView7631399186619256712 as select v1, SUM(annot) as annot from aggJoin9004735239590972917 group by v1;
create or replace TEMP view aggJoin9065229041338222927 as select annot from yMessage_hasTag_TagZ as yMessage_hasTag_TagZ, aggView7631399186619256712 where yMessage_hasTag_TagZ.MessageId=aggView7631399186619256712.v1;
select SUM(annot) as v9 from aggJoin9065229041338222927;
