/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * FROM [Services] WHERE [Key] = ISNULL(@Key, [Key])
