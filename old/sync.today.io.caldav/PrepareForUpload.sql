UPDATE CalDavEvents SET Upload=1 WHERE Upload=0 and (ExternalID IS NULL OR LEN(ExternalID)=0) AND ServiceAccountId = @ServiceAccountId