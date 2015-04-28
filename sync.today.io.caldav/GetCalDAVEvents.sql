/* 
declare @IsNewVal char(1) = NULL
declare @WasJustUpdatedVal char(1) = '0'
*/

declare @IsNew char(1) = @IsNewVal
declare @WasJustUpdated char(1) = @WasJustUpdatedVal

SELECT Id
      ,InternalId
      ,ExternalId
      ,[Description]
      ,Start
      ,[End]
      ,LastModified
      ,Location
      ,Summary
      ,CategoriesJSON
      ,ServiceAccountId
      ,Upload
      ,Tag
      ,IsNew
      ,WasJustUpdated
      ,LastDLError
      ,LastUPError
  FROM CalDavEvents
  where 
		IsNew = ( CASE WHEN @IsNew = '' THEN IsNew ELSE ISNULL( @IsNew, IsNew ) END ) AND
		WasJustUpdated = ( CASE WHEN @WasJustUpdated = '' THEN WasJustUpdated ELSE ISNULL( @WasJustUpdated, WasJustUpdated ) END )

