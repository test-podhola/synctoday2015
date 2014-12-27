USE [SyncToday2015]
GO
/****** Object:  Table [dbo].[sync.Adapters]    Script Date: 28. 12. 2014 0:50:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sync.Adapters](
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdapterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[sync.Adapters] ADD  DEFAULT (newid()) FOR [AdapterId]
GO
