USE [master]
GO
/****** Object:  Database [SyncToday2015]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE DATABASE [SyncToday2015]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SyncToday2015', FILENAME = N'C:\Users\david.podhola\SyncToday2015new.mdf' , SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'SyncToday2015_log', FILENAME = N'C:\Users\david.podhola\SyncToday2015new.ldf' , SIZE = 13632KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SyncToday2015].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SyncToday2015] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SyncToday2015] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SyncToday2015] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SyncToday2015] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SyncToday2015] SET ARITHABORT OFF 
GO
ALTER DATABASE [SyncToday2015] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SyncToday2015] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SyncToday2015] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SyncToday2015] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SyncToday2015] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SyncToday2015] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SyncToday2015] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SyncToday2015] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SyncToday2015] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SyncToday2015] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SyncToday2015] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SyncToday2015] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SyncToday2015] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SyncToday2015] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SyncToday2015] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SyncToday2015] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SyncToday2015] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SyncToday2015] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SyncToday2015] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SyncToday2015] SET  MULTI_USER 
GO
ALTER DATABASE [SyncToday2015] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SyncToday2015] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SyncToday2015] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SyncToday2015] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [SyncToday2015]
GO
/****** Object:  StoredProcedure [dbo].[actions.Accounts.create.mscrm.proc]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[actions.Accounts.create.mscrm.proc] as 

delete [actions.Accounts.create] where [AdapterId] = '3A7E2EAC-3664-4404-9001-E40BA1CDFCC0'
INSERT INTO [dbo].[actions.Accounts.create]
           ([AccountId]
           ,[ChangedOn]
           ,[ExternalId]
           ,[AdapterId]
           ,[Name]
           ,[IC]
           ,[DIC]
           ,[Email]
           ,[PrimaryPhonenumber]
           ,[City]
           ,[Street]
           ,[Region]
           ,[Postcode]
           ,[Country]
           ,[FormattedAddress]
           ,[Note])

SELECT 
           [AccountId]
           ,[ChangedOn]
           ,[ExternalId]
           ,'3A7E2EAC-3664-4404-9001-E40BA1CDFCC0'
           ,[Name]
           ,[IC]
           ,[DIC]
           ,[Email]
           ,[PrimaryPhonenumber]
           ,[City]
           ,[Street]
           ,[Region]
           ,[Postcode]
           ,[Country]
           ,[FormattedAddress]
		              ,[Note]
  FROM [dbo].[entities.Accounts]
  WHERE ExternalId IN
  (
  SELECT ExternalId
  FROM [entities.Accounts] A
except (
select cast([PartialAccountId] as nvarchar(max))from [dbo].[adapters.mscrm.PartialAccounts]
union
select A.ExternalId from [dbo].[entities.Accounts] A
inner join [dbo].[adapters.mscrm.PartialAccounts] PA on PA.AccountId = A.AccountId
)
  )


GO
/****** Object:  StoredProcedure [dbo].[adapters.google.Accounts.proc]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[adapters.google.Accounts.proc] as
begin
merge [dbo].[adapters.google.PartialAccounts] as Target
	using [dbo].[adapters.google.Contacts.changes] as Source
		on Target.[ExternalId] = Source.[ExternalId]
		and Target.[AdapterId] = Source.AdapterId
		and [TransformTag]='FO'
	when matched 
 then update set
		[Name] = RTRIM(LTRIM(ISNULL(source.GivenName, '') + ' ' + ISNULL(source.FamilyName, '' ))),
		[ChangedOn] = Source.[ChangedOn] ,
		Email = (select top 1 [Address] from [adapters.google.Emails] E where 
	       E.ContactId = Source.ContactId and len(address)>0 order by [Address]),
		[PrimaryPhonenumber] = (select top 1 Value from [adapters.google.PhoneNumbers] E where 
	       E.ContactId = Source.ContactId and len(Value)>0 order by [Value]),
		City = (select top 1 City from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Street = (select top 1 Street from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Region = (select top 1 Region from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Postcode = (select top 1 Postcode from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Country = (select top 1 Country from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		FormattedAddress = (select top 1 FormattedAddress from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Note = Source.Content
	when not matched then
	insert ([ExternalId], ChangedOn, Name, [TransformTag], [AdapterId], Email, [PrimaryPhonenumber],  City,
	Street, Region, Postcode, Country, FormattedAddress, Note)
	values (Source.[ExternalId], Source.ChangedOn, RTRIM(LTRIM(ISNULL(source.GivenName, '') + ' ' + ISNULL(source.FamilyName, '' ))),'FO', Source.[AdapterId],
	(select top 1 [Address] from [adapters.google.Emails] E where 
	    E.ContactId = Source.ContactId and len(address)>0 order by [Address]),
	(select top 1 Value from [adapters.google.PhoneNumbers] E where 
	    E.ContactId = Source.ContactId and len(Value)>0 order by [Value]),
	(select top 1 City from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		(select top 1 Street from [adapters.google.Addresses] E where 
	    E.ContactId = Source.ContactId order by AddressId),
(select top 1 Region from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
 (select top 1 Postcode from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
(select top 1 Country from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
			Source.postalAddressFormattedAddress, 
		   Source.Content
	)
;

merge [dbo].[adapters.google.PartialAccounts] as Target
	using [dbo].[adapters.google.Contacts.changes] as Source
		on Target.[ExternalId] = Source.[ExternalId]
		and Target.[AdapterId] = Source.AdapterId
		and [TransformTag]='PO'
	when matched 
 then update set
		[Name] = RTRIM(LTRIM(ISNULL(source.GivenName, '') + ' ' + ISNULL(source.FamilyName, '' ))),
		[ChangedOn] = Source.[ChangedOn] ,
		Email = (select top 1 [Address] from [adapters.google.Emails] E where 
	       E.ContactId = Source.ContactId and len(address)>0 order by [Address]),
		[PrimaryPhonenumber] = (select top 1 Value from [adapters.google.PhoneNumbers] E where 
	       E.ContactId = Source.ContactId and len(Value)>0 order by [Value]),
		City = (select top 1 City from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Street = (select top 1 Street from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Region = (select top 1 Region from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Postcode = (select top 1 Postcode from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Country = (select top 1 Country from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		FormattedAddress = (select top 1 FormattedAddress from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		Note = Source.Content
	when not matched then
	insert ([ExternalId], ChangedOn, Name, [TransformTag], [AdapterId], Email, [PrimaryPhonenumber],  City,
	Street, Region, Postcode, Country, FormattedAddress, Note)
	values (Source.[ExternalId], Source.ChangedOn, Source.OrgName,'PO', Source.[AdapterId],
	(select top 1 [Address] from [adapters.google.Emails] E where 
	    E.ContactId = Source.ContactId and len(address)>0 order by [Address]),
	(select top 1 Value from [adapters.google.PhoneNumbers] E where 
	    E.ContactId = Source.ContactId and len(Value)>0 order by [Value]),
	(select top 1 City from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
		(select top 1 Street from [adapters.google.Addresses] E where 
	    E.ContactId = Source.ContactId order by AddressId),
(select top 1 Region from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
 (select top 1 Postcode from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
(select top 1 Country from [adapters.google.Addresses] E where 
	       E.ContactId = Source.ContactId order by AddressId),
			Source.postalAddressFormattedAddress, 
		   Source.Content
	)
;

delete from [adapters.google.PartialAccounts] where len(name)=0 or name is null

end
GO
/****** Object:  StoredProcedure [dbo].[adapters.google.Contacts.changes.proc]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[adapters.google.Contacts.changes.proc] as
delete [adapters.google.Contacts.changes]
INSERT INTO [dbo].[adapters.google.Contacts.changes]
           ([ContactId]
           ,[ChangedOn]
           ,[ExternalId]
           ,[AdapterId]
           ,[Content]
           ,[Title]
           ,[Email]
           ,[GivenName]
           ,[FamilyName]
           ,[OrgDepartment]
           ,[OrgJobDescription]
           ,[OrgName]
           ,[OrgTitle]
           ,[PrimaryPhonenumber]
           ,[postalAddressCity]
           ,[postalAddressStreet]
           ,[postalAddressRegion]
           ,[postalAddressPostcode]
           ,[postalAddressCountry]
           ,[postalAddressFormattedAddress])
select T.* from (
select * from [dbo].[adapters.google.Contacts]
except
select * from [dbo].[adapters.google.Contacts.old]
) T
inner join [dbo].[adapters.google.GroupMemberships] GM on T.ContactId = GM.ContactId 
inner join [dbo].[adapters.google.Groups] G on G.GroupId = GM.GroupId
where G.Title = 'CERIA'

GO
/****** Object:  StoredProcedure [dbo].[adapters.google.Contacts.old.proc]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[adapters.google.Contacts.old.proc] as
INSERT INTO [dbo].[adapters.google.Contacts.old]
           ([ContactId]
           ,[ChangedOn]
           ,[ExternalId]
           ,[AdapterId]
           ,[Content]
           ,[Title]
           ,[Email]
           ,[GivenName]
           ,[FamilyName]
           ,[OrgDepartment]
           ,[OrgJobDescription]
           ,[OrgName]
           ,[OrgTitle]
           ,[PrimaryPhonenumber]
           ,[postalAddressCity]
           ,[postalAddressStreet]
           ,[postalAddressRegion]
           ,[postalAddressPostcode]
           ,[postalAddressCountry]
           ,[postalAddressFormattedAddress])
select * from [adapters.google.Contacts]
GO
/****** Object:  StoredProcedure [dbo].[entities.Accounts.google.proc]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[entities.Accounts.google.proc] as 

INSERT INTO [dbo].[entities.Accounts]
           ([AccountId]
           ,[ChangedOn]
           ,[ExternalId]
           ,[AdapterId]
           ,[Name]
           ,[IC]
           ,[DIC]
           ,[Email]
           ,[PrimaryPhonenumber]
           ,[City]
           ,[Street]
           ,[Region]
           ,[Postcode]
           ,[Country]
           ,[FormattedAddress]
           ,[Note])

SELECT [PartialAccountId]
      ,[ChangedOn]
      ,[ExternalId]
      ,[AdapterId]
      ,[Name]
      ,[IC]
      ,[DIC]
      ,[Email]
      ,[PrimaryPhonenumber]
      ,[City]
      ,[Street]
      ,[Region]
      ,[Postcode]
      ,[Country]
      ,[FormattedAddress]
      ,[Note]
  FROM [dbo].[adapters.google.PartialAccounts]
  WHERE ExternalId IN
  (
  SELECT PA.ExternalId
  FROM [adapters.google.PartialAccounts] PA
inner join [adapters.google.Contacts.changes] C on C.ExternalId = PA.ExternalId
except (
select ExternalId from [dbo].[entities.Accounts]
union
select A.ExternalId from [dbo].[entities.Accounts] A
inner join [dbo].[adapters.google.PartialAccounts] PA on PA.AccountId = A.AccountId
)
  )


GO
/****** Object:  StoredProcedure [dbo].[entities.Accounts.mscrm.proc]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[entities.Accounts.mscrm.proc] as 

INSERT INTO [dbo].[entities.Accounts]
           ([AccountId]
           ,[ChangedOn]
           ,[ExternalId]
           ,[AdapterId]
           ,[Name]
           ,[IC]
           ,[DIC]
           ,[Email]
           ,[PrimaryPhonenumber]
           ,[City]
           ,[Street]
           ,[Region]
           ,[Postcode]
           ,[Country]
           ,[FormattedAddress]
           ,[Note])

SELECT [PartialAccountId]
      ,[ModifiedOn]
      ,[PartialAccountId]
      ,[AdapterId]
      ,[Name]
      ,[new_ic]
      ,[new_dic]
      ,[EMailAddress1]
      ,[Telephone1]
      ,address1_city
      ,address1_line1
      ,NULL
      ,address1_postalcode
      ,address1_country
      ,NULL
      ,Description
  FROM [dbo].[adapters.mscrm.PartialAccounts]
  WHERE PartialAccountId IN
  (
  SELECT cast( PA.PartialAccountId as nvarchar(max))
  FROM [adapters.mscrm.PartialAccounts] PA
except (
select ExternalId from [dbo].[entities.Accounts]
union
select A.ExternalId from [dbo].[entities.Accounts] A
inner join [dbo].[adapters.mscrm.PartialAccounts] PA on PA.AccountId = A.AccountId
)
  )


GO
/****** Object:  Table [dbo].[actions.Accounts.create]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[actions.Accounts.create](
	[CreateAccountId] [uniqueidentifier] NOT NULL,
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](800) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[IC] [nvarchar](max) NULL,
	[DIC] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[PrimaryPhonenumber] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[Street] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Postcode] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[FormattedAddress] [nvarchar](max) NULL,
	[Note] [nvarchar](max) NULL,
	[AccountId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CreateAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.Addresses]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.Addresses](
	[AddressId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[City] [nvarchar](max) NULL,
	[Street] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Postcode] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[Formatted] [nvarchar](max) NULL,
	[Label] [nvarchar](max) NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Usage] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.Contacts]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.Contacts](
	[ContactId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](800) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Content] [nvarchar](max) NULL,
	[Title] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[GivenName] [nvarchar](max) NULL,
	[FamilyName] [nvarchar](max) NULL,
	[OrgDepartment] [nvarchar](max) NULL,
	[OrgJobDescription] [nvarchar](max) NULL,
	[OrgName] [nvarchar](max) NULL,
	[OrgTitle] [nvarchar](max) NULL,
	[PrimaryPhonenumber] [nvarchar](max) NULL,
	[postalAddressCity] [nvarchar](max) NULL,
	[postalAddressStreet] [nvarchar](max) NULL,
	[postalAddressRegion] [nvarchar](max) NULL,
	[postalAddressPostcode] [nvarchar](max) NULL,
	[postalAddressCountry] [nvarchar](max) NULL,
	[postalAddressFormattedAddress] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.Contacts.changes]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.Contacts.changes](
	[ContactId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](800) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Content] [nvarchar](max) NULL,
	[Title] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[GivenName] [nvarchar](max) NULL,
	[FamilyName] [nvarchar](max) NULL,
	[OrgDepartment] [nvarchar](max) NULL,
	[OrgJobDescription] [nvarchar](max) NULL,
	[OrgName] [nvarchar](max) NULL,
	[OrgTitle] [nvarchar](max) NULL,
	[PrimaryPhonenumber] [nvarchar](max) NULL,
	[postalAddressCity] [nvarchar](max) NULL,
	[postalAddressStreet] [nvarchar](max) NULL,
	[postalAddressRegion] [nvarchar](max) NULL,
	[postalAddressPostcode] [nvarchar](max) NULL,
	[postalAddressCountry] [nvarchar](max) NULL,
	[postalAddressFormattedAddress] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.Contacts.old]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.Contacts.old](
	[ContactId] [uniqueidentifier] NOT NULL,
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](800) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Content] [nvarchar](max) NULL,
	[Title] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[GivenName] [nvarchar](max) NULL,
	[FamilyName] [nvarchar](max) NULL,
	[OrgDepartment] [nvarchar](max) NULL,
	[OrgJobDescription] [nvarchar](max) NULL,
	[OrgName] [nvarchar](max) NULL,
	[OrgTitle] [nvarchar](max) NULL,
	[PrimaryPhonenumber] [nvarchar](max) NULL,
	[postalAddressCity] [nvarchar](max) NULL,
	[postalAddressStreet] [nvarchar](max) NULL,
	[postalAddressRegion] [nvarchar](max) NULL,
	[postalAddressPostcode] [nvarchar](max) NULL,
	[postalAddressCountry] [nvarchar](max) NULL,
	[postalAddressFormattedAddress] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.Emails]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.Emails](
	[EmailId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[Address] [nvarchar](max) NULL,
	[Label] [nvarchar](max) NULL,
	[Home] [bit] NULL,
	[Other] [bit] NULL,
	[Work] [bit] NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.GroupMemberships]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.GroupMemberships](
	[ContactId] [uniqueidentifier] NOT NULL,
	[GroupId] [uniqueidentifier] NOT NULL,
	[GroupMembershipId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
PRIMARY KEY CLUSTERED 
(
	[GroupMembershipId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.Groups]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.Groups](
	[GroupId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](max) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Title] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[GroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.PartialAccounts]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.PartialAccounts](
	[PartialAccountId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](800) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[IC] [nvarchar](max) NULL,
	[DIC] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[PrimaryPhonenumber] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[Street] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Postcode] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[FormattedAddress] [nvarchar](max) NULL,
	[Note] [nvarchar](max) NULL,
	[TransformTag] [nvarchar](100) NULL,
	[AccountId] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[PartialAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.google.PhoneNumbers]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.google.PhoneNumbers](
	[PhoneNumberId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[Value] [nvarchar](max) NULL,
	[Label] [nvarchar](max) NULL,
	[Home] [bit] NULL,
	[Other] [bit] NULL,
	[Work] [bit] NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PhoneNumberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[adapters.mscrm.PartialAccounts]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adapters.mscrm.PartialAccounts](
	[PartialAccountId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[AccountCategoryCode] [int] NULL,
	[TerritoryId] [uniqueidentifier] NULL,
	[DefaultPriceLevelId] [uniqueidentifier] NULL,
	[CustomerSizeCode] [int] NULL,
	[PreferredContactMethodCode] [int] NULL,
	[CustomerTypeCode] [int] NULL,
	[AccountRatingCode] [int] NULL,
	[IndustryCode] [int] NULL,
	[TerritoryCode] [int] NULL,
	[AccountClassificationCode] [int] NULL,
	[BusinessTypeCode] [int] NULL,
	[OwningBusinessUnit] [uniqueidentifier] NULL,
	[OriginatingLeadId] [uniqueidentifier] NULL,
	[PaymentTermsCode] [int] NULL,
	[ShippingMethodCode] [int] NULL,
	[PrimaryContactId] [uniqueidentifier] NULL,
	[Name] [nvarchar](160) NULL,
	[AccountNumber] [nvarchar](20) NULL,
	[Revenue] [money] NULL,
	[NumberOfEmployees] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[SIC] [nvarchar](20) NULL,
	[OwnershipCode] [int] NULL,
	[MarketCap] [money] NULL,
	[SharesOutstanding] [int] NULL,
	[TickerSymbol] [nvarchar](10) NULL,
	[StockExchange] [nvarchar](20) NULL,
	[WebSiteURL] [nvarchar](200) NULL,
	[FtpSiteURL] [nvarchar](200) NULL,
	[EMailAddress1] [nvarchar](100) NULL,
	[EMailAddress2] [nvarchar](100) NULL,
	[EMailAddress3] [nvarchar](100) NULL,
	[DoNotPhone] [bit] NULL CONSTRAINT [DF_AccountBase_DoNotPhone]  DEFAULT ((0)),
	[DoNotFax] [bit] NULL CONSTRAINT [DF_AccountBase_DoNotFax]  DEFAULT ((0)),
	[Telephone1] [nvarchar](50) NULL,
	[DoNotEMail] [bit] NULL CONSTRAINT [DF_AccountBase_DoNotEMail]  DEFAULT ((0)),
	[Telephone2] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[Telephone3] [nvarchar](50) NULL,
	[DoNotPostalMail] [bit] NULL CONSTRAINT [DF_AccountBase_DoNotPostalMail]  DEFAULT ((0)),
	[DoNotBulkEMail] [bit] NULL CONSTRAINT [DF_AccountBase_DoNotBulkEMail]  DEFAULT ((0)),
	[DoNotBulkPostalMail] [bit] NULL CONSTRAINT [DF_AccountBase_DoNotBulkPostalMail]  DEFAULT ((0)),
	[CreditLimit] [money] NULL,
	[CreditOnHold] [bit] NULL,
	[IsPrivate] [bit] NULL CONSTRAINT [Set_To_Zero94]  DEFAULT ((0)),
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[VersionNumber] [timestamp] NULL,
	[ParentAccountId] [uniqueidentifier] NULL,
	[Aging30] [money] NULL,
	[StateCode] [int] NOT NULL,
	[Aging60] [money] NULL,
	[StatusCode] [int] NULL,
	[Aging90] [money] NULL,
	[PreferredAppointmentDayCode] [int] NULL,
	[PreferredSystemUserId] [uniqueidentifier] NULL,
	[PreferredAppointmentTimeCode] [int] NULL,
	[Merged] [bit] NULL,
	[DoNotSendMM] [bit] NULL,
	[MasterId] [uniqueidentifier] NULL,
	[LastUsedInCampaign] [datetime] NULL,
	[PreferredServiceId] [uniqueidentifier] NULL,
	[PreferredEquipmentId] [uniqueidentifier] NULL,
	[ExchangeRate] [decimal](23, 10) NULL,
	[UTCConversionTimeZoneCode] [int] NULL,
	[OverriddenCreatedOn] [datetime] NULL,
	[TimeZoneRuleVersionNumber] [int] NULL,
	[ImportSequenceNumber] [int] NULL,
	[TransactionCurrencyId] [uniqueidentifier] NULL,
	[CreditLimit_Base] [money] NULL,
	[Aging30_Base] [money] NULL,
	[Revenue_Base] [money] NULL,
	[Aging90_Base] [money] NULL,
	[MarketCap_Base] [money] NULL,
	[Aging60_Base] [money] NULL,
	[YomiName] [nvarchar](160) NULL,
	[OwnerId] [uniqueidentifier] NOT NULL,
	[ModifiedOnBehalfBy] [uniqueidentifier] NULL,
	[CreatedOnBehalfBy] [uniqueidentifier] NULL,
	[OwnerIdType] [int] NOT NULL,
	[StageId] [uniqueidentifier] NULL,
	[ProcessId] [uniqueidentifier] NULL,
	[EntityImageId] [uniqueidentifier] NULL,
	[new_dic] [nvarchar](100) NULL,
	[new_ic] [nvarchar](10) NULL,
	[AccountId] [uniqueidentifier] NULL,
	[address1_city] [nvarchar](max) NULL,
	[address1_country] [nvarchar](max) NULL,
	[address1_line1] [nvarchar](max) NULL,
	[address1_postalcode] [nvarchar](max) NULL,
	[address1_telephone1] [nvarchar](max) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PartialAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[entities.Accounts]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entities.Accounts](
	[AccountId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[ChangedOn] [datetimeoffset](7) NULL,
	[ExternalId] [nvarchar](800) NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[IC] [nvarchar](max) NULL,
	[DIC] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[PrimaryPhonenumber] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[Street] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Postcode] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[FormattedAddress] [nvarchar](max) NULL,
	[Note] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[AccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sync.Adapters]    Script Date: 27. 12. 2014 0:42:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sync.Adapters](
	[AdapterId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[Name] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdapterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ExternalId]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ExternalId] ON [dbo].[adapters.google.Contacts]
(
	[ExternalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Title]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE NONCLUSTERED INDEX [IX_Title] ON [dbo].[adapters.google.Contacts]
(
	[ContactId] ASC
)
INCLUDE ( 	[Title]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PK]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PK] ON [dbo].[adapters.google.GroupMemberships]
(
	[ContactId] ASC,
	[GroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ExternalId]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE NONCLUSTERED INDEX [IX_ExternalId] ON [dbo].[adapters.google.Groups]
(
	[GroupId] ASC
)
INCLUDE ( 	[ExternalId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ExternalId]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ExternalId] ON [dbo].[adapters.google.PartialAccounts]
(
	[ExternalId] ASC,
	[TransformTag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Name]    Script Date: 27. 12. 2014 0:42:35 ******/
CREATE NONCLUSTERED INDEX [IX_Name] ON [dbo].[adapters.google.PartialAccounts]
(
	[PartialAccountId] ASC
)
INCLUDE ( 	[Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[actions.Accounts.create] ADD  DEFAULT (newid()) FOR [CreateAccountId]
GO
ALTER TABLE [dbo].[actions.Accounts.create]  WITH CHECK ADD FOREIGN KEY([AccountId])
REFERENCES [dbo].[entities.Accounts] ([AccountId])
GO
ALTER TABLE [dbo].[adapters.google.Addresses]  WITH CHECK ADD FOREIGN KEY([ContactId])
REFERENCES [dbo].[adapters.google.Contacts] ([ContactId])
GO
ALTER TABLE [dbo].[adapters.google.Contacts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[adapters.google.Contacts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[adapters.google.Emails]  WITH CHECK ADD FOREIGN KEY([ContactId])
REFERENCES [dbo].[adapters.google.Contacts] ([ContactId])
GO
ALTER TABLE [dbo].[adapters.google.GroupMemberships]  WITH CHECK ADD FOREIGN KEY([ContactId])
REFERENCES [dbo].[adapters.google.Contacts] ([ContactId])
GO
ALTER TABLE [dbo].[adapters.google.GroupMemberships]  WITH CHECK ADD FOREIGN KEY([GroupId])
REFERENCES [dbo].[adapters.google.Groups] ([GroupId])
GO
ALTER TABLE [dbo].[adapters.google.Groups]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[adapters.google.PartialAccounts]  WITH CHECK ADD FOREIGN KEY([AccountId])
REFERENCES [dbo].[entities.Accounts] ([AccountId])
GO
ALTER TABLE [dbo].[adapters.google.PartialAccounts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[adapters.google.PhoneNumbers]  WITH CHECK ADD FOREIGN KEY([ContactId])
REFERENCES [dbo].[adapters.google.Contacts] ([ContactId])
GO
ALTER TABLE [dbo].[adapters.mscrm.PartialAccounts]  WITH CHECK ADD FOREIGN KEY([AccountId])
REFERENCES [dbo].[entities.Accounts] ([AccountId])
GO
ALTER TABLE [dbo].[adapters.mscrm.PartialAccounts]  WITH CHECK ADD FOREIGN KEY([AccountId])
REFERENCES [dbo].[entities.Accounts] ([AccountId])
GO
ALTER TABLE [dbo].[adapters.mscrm.PartialAccounts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[entities.Accounts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[entities.Accounts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
ALTER TABLE [dbo].[entities.Accounts]  WITH CHECK ADD FOREIGN KEY([AdapterId])
REFERENCES [dbo].[sync.Adapters] ([AdapterId])
GO
USE [master]
GO
ALTER DATABASE [SyncToday2015] SET  READ_WRITE 
GO
