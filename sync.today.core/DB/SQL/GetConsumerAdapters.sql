/* 
declare @adapterIdVal int = 1
declare @consumerIdVal int = 3
*/

declare @adapterId int = @adapterIdVal
declare @consumerId int = @consumerIdVal

SELECT * FROM ConsumerAdapters WHERE 
	AdapterId = ( CASE WHEN @adapterId = 0 THEN AdapterId ELSE @adapterId END ) AND
	ConsumerId = ( CASE WHEN @consumerId = 0 THEN ConsumerId ELSE @consumerId END )

