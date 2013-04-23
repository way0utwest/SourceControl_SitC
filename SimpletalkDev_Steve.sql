-- Articles Development

IF @@trancount > 0 BEGIN ROLLBACK END
USE tempdb
go
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'SimpleTalkDev_Steve')
BEGIN
	ALTER DATABASE [SimpleTalkDev_Steve] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE SimpleTalkDev_Steve
    END

--Create the databases and structure
CREATE DATABASE SimpleTalkDev_Steve
GO
USE SimpleTalkDev_Steve
GO
/* required to ensure that if the DB was created with a windows login the trustworthy doesn't fail*/
ALTER AUTHORIZATION ON DATABASE::SimpleTalkDev_Steve TO sa
GO
ALTER DATABASE SimpleTalkDev_Steve SET TRUSTWORTHY ON -- For tSQLt also need:EXEC sp_configure 'clr enabled', 1
GO
RECONFIGURE

GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
CREATE TABLE [dbo].[Contacts] (
 [ID] [int] IDENTITY (1, 1) NOT NULL ,
 [ContactFullName] [nvarchar](100) NOT NULL ,
 [PhoneWork] [nvarchar](25) NULL ,
 [PhoneMobile] [nvarchar](25) NULL ,
 [Address1] [nvarchar](128) NULL ,
 [Address2] [nvarchar](128) NULL ,
 [Address3] [nvarchar](128) NULL ,
 [JoiningDate] [datetime] NULL CONSTRAINT DF_const_join_date DEFAULT (GETDATE()),
 [ModifiedDate] [datetime] NULL,
 [Email] [nvarchar](256) NULL
)
GO
ALTER TABLE [dbo].[Contacts] WITH NOCHECK ADD
 CONSTRAINT [PK_Contacts] PRIMARY KEY CLUSTERED
 ( [ID] )
GO


CREATE TABLE Articles
	(
	  ArticleID INT IDENTITY (1,1) PRIMARY KEY,
	  AuthorID INT ,
	  Title VARCHAR(MAX),
	  [Description] VARCHAR(MAX) ,
	  [Date] DATE ,
	  [ModifiedDate] DATETIME ,
	  URL VARCHAR(MAX)
	)

GO


ALTER TABLE Articles
ADD CONSTRAINT FK_Author FOREIGN KEY(AuthorID)
REFERENCES dbo.Contacts(ID)

GO
CREATE TABLE RSSFeeds (RSSFeedID INT IDENTITY (1,1) PRIMARY KEY, FeedName VARCHAR(MAX), Checked bit)
GO
INSERT INTO RSSFeeds (FeedName, Checked) 
VALUES
('SQL', 1),
('.NET', 1),
('SysAdmin', 1),
('Opinion', 1) 


GO
CREATE TABLE [dbo].[ArticlesDescriptions] (
 [ArticlesID] [int] IDENTITY (1,1) NOT NULL ,
  [ShortDescription] NVARCHAR(2000) NULL ,
 [Description] [text] ,
 [ArticlesName] [varchar] (50) NULL,
 [Picture] [image] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[ArticlesPrices] (
 [RecordID] [int] IDENTITY (1, 1) NOT NULL ,
 [ArticlesID] [int] NULL ,
 [Price] [money] NULL ,
 [ValidFrom] [datetime] NULL ,
 [ValidTo] [datetime] NULL ,
 [Active] [char] (1) NULL 
) ON [PRIMARY]
GO
 
CREATE TABLE [dbo].[ArticlesReferences] (
 [ArticlesID] [int] IDENTITY NOT NULL ,
 [Reference] [varchar] (50) NULL 
) ON [PRIMARY]
GO
 
CREATE TABLE [dbo].[Blogs] (
 [RecordID] [int] IDENTITY (1, 1) NOT NULL ,
 [Description] [varchar] (50) NULL ,
 [SKU] [varchar] (20) NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ArticlesPurchases] (
 [PurchaseID] [int] IDENTITY (1, 1) NOT NULL ,
 [ArticlesPriceID] [int] NOT NULL ,
 [Quantity] [int] NOT NULL DEFAULT (1) ,
 [InvoiceNumber] [nvarchar](20) NULL ,
 [Date] [datetime] NOT NULL DEFAULT (GETDATE())
)
GO



ALTER TABLE [dbo].[ArticlesDescriptions] WITH NOCHECK ADD 
 CONSTRAINT [PK_ArticlesDescriptions] PRIMARY KEY  CLUSTERED 
 (
  [ArticlesID]
 )  ON [PRIMARY] 
GO
 
ALTER TABLE [dbo].[ArticlesPrices] WITH NOCHECK ADD 
 CONSTRAINT [DF_ArticlesPrices_ValidFrom] DEFAULT (GETDATE()) FOR [ValidFrom],
 CONSTRAINT [DF_ArticlesPrices_Active] DEFAULT ('N') FOR [Active],
 CONSTRAINT [PK_ArticlesPrices] PRIMARY KEY  NONCLUSTERED 
 (
  [RecordID]
 )  ON [PRIMARY] 
GO
 
ALTER TABLE [dbo].[ArticlesReferences] WITH NOCHECK ADD 
 CONSTRAINT [PK_ArticlesReferences] PRIMARY KEY  NONCLUSTERED 
 (
  [ArticlesID]
 )  ON [PRIMARY] 
GO
 
ALTER TABLE [dbo].[Blogs] WITH NOCHECK ADD 
 CONSTRAINT [PK_Blogs] PRIMARY KEY  NONCLUSTERED 
 (
  [RecordID]
 )  ON [PRIMARY] 
GO



 CREATE  INDEX [IX_ArticlesPrices] ON [dbo].[ArticlesPrices]([ArticlesID]) ON [PRIMARY]
GO
 
 CREATE  INDEX [IX_ArticlesPrices_1] ON [dbo].[ArticlesPrices]([ValidFrom]) ON [PRIMARY]
GO
 
 CREATE  INDEX [IX_ArticlesPrices_2] ON [dbo].[ArticlesPrices]([ValidTo]) ON [PRIMARY]
GO

 CREATE UNIQUE CLUSTERED INDEX [IX_ArticlesPurchases] ON [dbo].[ArticlesPurchases]([PurchaseID]) ON [PRIMARY]
GO

-- Create indexed view

CREATE VIEW dbo.ArticlesPriceList
WITH SCHEMABINDING 
AS
SELECT     dbo.Blogs.RecordID, dbo.Blogs.Description AS Articles, dbo.ArticlesPrices.Price
FROM       dbo.Blogs INNER JOIN
           dbo.ArticlesPrices ON dbo.Blogs.RecordID = dbo.ArticlesPrices.RecordID
GO

CREATE UNIQUE CLUSTERED INDEX [IX_ArticlesPriceList] ON [dbo].[ArticlesPriceList] ([RecordID])
GO


CREATE TABLE [dbo].[CountryCodes]
(
[CountryName] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[CountryCode] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL
)
GO
-- Constraints and Indexes

ALTER TABLE [dbo].[CountryCodes] ADD CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED  ([CountryCode])
GO

-- **************************************** Insert data ****************************************


SET IDENTITY_INSERT [dbo].[Blogs] ON
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (1, 'Red Articles', 'RW')
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (2, 'Extended Articles2', 'EW')
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (4, 'Grow-your-own Articles', 'GW')
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (5, 'Articles access kit', 'AW')
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (6, 'Test kit', 'TK')
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (7, 'Exploded Articles diagram', 'ED')
INSERT INTO [dbo].[Blogs] ([RecordID], [Description], [SKU]) VALUES (8, 'New Articles', 'NW')
SET IDENTITY_INSERT [dbo].[Blogs] OFF


INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AE', N'UNITED ARAB EMIRATES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AF', N'AFGHANISTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AG', N'ANTIGUA AND BARBUDA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AI', N'ANGUILLA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AL', N'ALBANIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AM', N'ARMENIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AO', N'ANGOLA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AQ', N'ANTARCTICA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AR', N'ARGENTINA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AS', N'AMERICAN SAMOA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AT', N'AUSTRIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AU', N'AUSTRALIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AW', N'ARUBA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AX', N'ÅLAND ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'AZ', N'AZERBAIJAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BA', N'BOSNIA AND HERZEGOVINA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BB', N'BARBADOS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BD', N'BANGLADESH')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BE', N'BELGIUM')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BF', N'BURKINA FASO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BG', N'BULGARIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BH', N'BAHRAIN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BI', N'BURUNDI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BJ', N'BENIN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BL', N'SAINT BARTHÉLEMY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BM', N'BERMUDA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BN', N'BRUNEI DARUSSALAM')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BO', N'BOLIVIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BQ', N'BONAIRE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BR', N'BRAZIL')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BS', N'BAHAMAS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BT', N'BHUTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BV', N'BOUVET ISLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BW', N'BOTSWANA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BY', N'BELARUS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'BZ', N'BELIZE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CA', N'CANADA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CC', N'COCOS (KEELING) ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CD', N'CONGO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CF', N'CENTRAL AFRICAN REPUBLIC')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CG', N'CONGO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CH', N'SWITZERLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CI', N'CÔTE D''IVOIRE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CK', N'COOK ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CL', N'CHILE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CM', N'CAMEROON')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CN', N'CHINA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CO', N'COLOMBIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CR', N'COSTA RICA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CU', N'CUBA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CV', N'CAPE VERDE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CW', N'CURAÇAO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CX', N'CHRISTMAS ISLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CY', N'CYPRUS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'CZ', N'CZECH REPUBLIC')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DA', N'ANDORRA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DE', N'GERMANY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DJ', N'DJIBOUTI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DK', N'DENMARK')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DM', N'DOMINICA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DO', N'DOMINICAN REPUBLIC')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'DZ', N'ALGERIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'EC', N'ECUADOR')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'EE', N'ESTONIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'EG', N'EGYPT')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'EH', N'WESTERN SAHARA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ER', N'ERITREA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ES', N'SPAIN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ET', N'ETHIOPIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'FI', N'FINLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'FJ', N'FIJI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'FK', N'FALKLAND ISLANDS (MALVINAS)')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'FM', N'MICRONESIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'FO', N'FAROE ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'FR', N'FRANCE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GA', N'GABON')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GB', N'UNITED KINGDOM')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GD', N'GRENADA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GE', N'GEORGIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GF', N'FRENCH GUIANA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GG', N'GUERNSEY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GH', N'GHANA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GI', N'GIBRALTAR')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GL', N'GREENLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GM', N'GAMBIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GN', N'GUINEA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GP', N'GUADELOUPE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GQ', N'EQUATORIAL GUINEA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GR', N'GREECE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GS', N'SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GT', N'GUATEMALA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GU', N'GUAM')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GW', N'GUINEA-BISSAU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'GY', N'GUYANA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'HK', N'HONG KONG')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'HM', N'HEARD ISLAND AND MCDONALD ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'HN', N'HONDURAS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'HR', N'CROATIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'HT', N'HAITI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'HU', N'HUNGARY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ID', N'INDONESIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IE', N'IRELAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IL', N'ISRAEL')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IM', N'ISLE OF MAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IN', N'INDIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IO', N'BRITISH INDIAN OCEAN TERRITORY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IQ', N'IRAQ')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IR', N'IRAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IS', N'ICELAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'IT', N'ITALY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'JE', N'JERSEY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'JM', N'JAMAICA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'JO', N'JORDAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'JP', N'JAPAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KE', N'KENYA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KG', N'KYRGYZSTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KH', N'CAMBODIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KI', N'KIRIBATI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KM', N'COMOROS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KN', N'SAINT KITTS AND NEVIS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KP', N'KOREA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KR', N'KOREA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KW', N'KUWAIT')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KY', N'CAYMAN ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'KZ', N'KAZAKHSTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LA', N'LAO PEOPLE''S DEMOCRATIC REPUBLIC')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LB', N'LEBANON')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LC', N'SAINT LUCIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LI', N'LIECHTENSTEIN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LK', N'SRI LANKA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LR', N'LIBERIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LS', N'LESOTHO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LT', N'LITHUANIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LU', N'LUXEMBOURG')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LV', N'LATVIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'LY', N'LIBYA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MA', N'MOROCCO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MC', N'MONACO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MD', N'MOLDOVA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ME', N'MONTENEGRO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MF', N'SAINT MARTIN (FRENCH PART)')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MG', N'MADAGASCAR')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MH', N'MARSHALL ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MK', N'MACEDONIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ML', N'MALI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MM', N'MYANMAR')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MN', N'MONGOLIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MO', N'MACAO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MP', N'NORTHERN MARIANA ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MQ', N'MARTINIQUE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MR', N'MAURITANIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MS', N'MONTSERRAT')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MT', N'MALTA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MU', N'MAURITIUS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MV', N'MALDIVES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MW', N'MALAWI')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MX', N'MEXICO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MY', N'MALAYSIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'MZ', N'MOZAMBIQUE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NA', N'NAMIBIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NC', N'NEW CALEDONIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NE', N'NIGER')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NF', N'NORFOLK ISLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NG', N'NIGERIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NI', N'NICARAGUA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NL', N'NETHERLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NO', N'NORWAY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NP', N'NEPAL')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NR', N'NAURU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NU', N'NIUE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'NZ', N'NEW ZEALAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'OM', N'OMAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PA', N'PANAMA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PE', N'PERU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PF', N'FRENCH POLYNESIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PG', N'PAPUA NEW GUINEA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PH', N'PHILIPPINES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PK', N'PAKISTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PL', N'POLAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PM', N'SAINT PIERRE AND MIQUELON')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PN', N'PITCAIRN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PR', N'PUERTO RICO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PS', N'PALESTINIAN TERRITORY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PT', N'PORTUGAL')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PW', N'PALAU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'PY', N'PARAGUAY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'QA', N'QATAR')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'RE', N'RÉUNION')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'RO', N'ROMANIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'RS', N'SERBIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'RU', N'RUSSIAN FEDERATION')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'RW', N'RWANDA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SA', N'SAUDI ARABIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SB', N'SOLOMON ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SC', N'SEYCHELLES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SD', N'SUDAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SE', N'SWEDEN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SG', N'SINGAPORE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SH', N'SAINT HELENA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SI', N'SLOVENIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SJ', N'SVALBARD AND JAN MAYEN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SK', N'SLOVAKIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SL', N'SIERRA LEONE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SM', N'SAN MARINO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SN', N'SENEGAL')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SO', N'SOMALIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SR', N'SURINAME')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SS', N'SOUTH SUDAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ST', N'SAO TOME AND PRINCIPE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SV', N'EL SALVADOR')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SX', N'SINT MAARTEN (DUTCH PART)')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SY', N'SYRIAN ARAB REPUBLIC')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'SZ', N'SWAZILAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TC', N'TURKS AND CAICOS ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TD', N'CHAD')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TF', N'FRENCH SOUTHERN TERRITORIES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TG', N'TOGO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TH', N'THAILAND')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TJ', N'TAJIKISTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TK', N'TOKELAU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TL', N'TIMOR-LESTE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TM', N'TURKMENISTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TN', N'TUNISIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TO', N'TONGA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TR', N'TURKEY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TT', N'TRINIDAD AND TOBAGO')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TV', N'TUVALU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TW', N'TAIWAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'TZ', N'TANZANIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'UA', N'UKRAINE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'UG', N'UGANDA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'UM', N'UNITED STATES MINOR OUTLYING ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'US', N'UNITED STATES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'UY', N'URUGUAY')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'UZ', N'UZBEKISTAN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VA', N'HOLY SEE (VATICAN CITY STATE)')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VC', N'SAINT VINCENT AND THE GRENADINES')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VE', N'VENEZUELA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VG', N'VIRGIN ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VI', N'VIRGIN ISLANDS')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VN', N'VIET NAM')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'VU', N'VANUATU')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'WF', N'WALLIS AND FUTUNA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'WS', N'SAMOA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'YE', N'YEMEN')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'YT', N'MAYOTTE')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ZA', N'SOUTH AFRICA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ZM', N'ZAMBIA')
INSERT INTO [dbo].[CountryCodes] ([CountryCode], [CountryName]) VALUES (N'ZW', N'ZIMBABWE')

-- Populate Contacts
SET IDENTITY_INSERT [dbo].[Contacts] ON
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (1, N'Louis Davidson', N'01446 175923', N'07634 717173', N'17 High Street', N'Darlington', N'Cheshire', '20070914 16:09:21.383', N'Christopher.Martin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (2, N'Adam Machanic', N'01147 771824', N'07956 758471', N'37 Green Lane', N'Portsmouth', N'County Durham', '20070914 16:09:21.400', N'Joseph.Bennett@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (3, N'Francis Hanlon', N'01940 919059', N'07331 757163', N'33 George Street', N'Llandudno', N'County Durham', '20070914 16:09:21.400', N'Joshua.Scott@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (4, N'Dino Esposito', N'01659 216066', N'07272 134093', N'93 North Street', N'Newport', N'Cheshire', '20070914 16:09:21.417', N'Daniel.Powell@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (5, N'Grant Fritchey', N'01502 976179', N'07225 483640', N'43 The Grove', N'Hull', N'Berkshire', '20070914 16:09:21.430', N'Jennifer.Washington@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (6, N'Steve Jones', N'01200 660059', N'07696 849723', N'97 Stanley Road', N'Newport', N'Berkshire', '20070914 16:09:21.430', N'Anthony.Lee@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (7, N'Rebecca Foster', N'01340 503829', N'07960 669272', N'79 Springfield Road', N'Salisbury', N'Licolnshire', '20070914 16:09:21.447', N'Rebecca.Foster@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (8, N'Ava Walker', N'01978 657197', N'07610 445571', N'29 North Street', N'Southall', N'Oxfordshire', '20070914 16:09:21.463', N'Ava.Walker@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (9, N'Matthew Ward', N'01324 940147', N'07903 833764', N'71 Kingsway', N'London EC', N'Staffordshire', '20070914 16:09:21.477', N'Matthew.Ward@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (10, N'Matthew Mitchell', N'01661 434756', N'07822 453924', N'70 King Street', N'Worcester', N'Rutland', '20070914 16:09:21.477', N'Matthew.Mitchell@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (11, N'Megan Stewart', N'01653 610021', N'07363 920914', N'59 Broadway', N'Chelmsford', N'Berkshire', '20070914 16:09:21.493', N'Megan.Stewart@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (12, N'Mia Robinson', N'01594 360107', N'07295 889232', N'22 The Avenue', N'Wigan', N'Norfolk', '20070914 16:09:21.510', N'Mia.Robinson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (13, N'Cameron Davis', N'01594 360107', N'07295 889232', N'35 Windsor Road', N'Watford', N'Rutland', '20070914 16:09:21.523', N'Cameron.Davis@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (14, N'Emma Howard', N'01788 915553', N'07736 274237', N'43 Park Avenue', N'Wigan', N'Derbyshire', '20070914 16:09:21.540', N'Emma.Howard@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (15, N'Liam Taylor', N'01286 103534', N'07939 391131', N'47 York Road', N'Harrow', N'Shropshire', '20070914 16:09:21.540', N'Liam.Taylor@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (16, N'Ross Ramirez', N'01945 464335', N'07126 593543', N'33 Kingsway', N'London WC', N'Herefordshire', '20070914 16:09:21.557', N'Ross.Ramirez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (17, N'Sarah Lewis', N'01287 924924', N'07149 593067', N'91 George Street', N'Bristol', N'Cumberland', '20070914 16:09:21.570', N'Sarah.Lewis@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (18, N'Emma Taylor', N'01287 924924', N'07149 593067', N'92 Queen Street', N'Dundee', N'Kent', '20070914 16:09:21.587', N'Emma.Taylor@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (19, N'Anthony Rivera', N'01788 915553', N'07736 274237', N'97 Church Road', N'Southampton', N'Huntingdonshire', '20070914 16:09:21.587', N'Anthony.Rivera@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (20, N'Ellie King', N'01945 464335', N'07126 593543', N'29 George Street', N'Lincoln', N'Lancashire', '20070914 16:09:21.603', N'Ellie.King@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (21, N'Megan Barnes', N'01469 486350', N'07759 520189', N'92 West Street', N'York', N'Surrey', '20070914 16:09:21.620', N'Megan.Barnes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (22, N'Scott Watson', N'01630 240971', N'07886 967048', N'91 Mill Road', N'Chester', N'Norfolk', '20070914 16:09:21.633', N'Scott.Watson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (23, N'Emily Anderson', N'01487 403649', N'07449 889487', N'100 George Street', N'Dorchester', N'Hertfordshire', '20070914 16:09:21.633', N'Emily.Anderson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (24, N'Nicole Martin', N'01721 599988', N'07525 825680', N'62 Kingsway', N'Colchester', N'Hertfordshire', '20070914 16:09:21.650', N'Nicole.Martin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (25, N'David Perry', N'01212 359994', N'07270 368607', N'59 Queen Street', N'London N', N'Cheshire', '20070914 16:09:21.667', N'David.Perry@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (26, N'Abbie Rogers', N'01120 243659', N'07237 275885', N'62 Manchester Road', N'Kirkcaldy', N'Cornwall', '20070914 16:09:21.680', N'Abbie.Rogers@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (27, N'Liam Kelly', N'01140 882420', N'07354 721715', N'88 St. John''s Road', N'Manchester', N'Northamptonshire', '20070914 16:09:21.680', N'Liam.Kelly@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (28, N'Christopher Walker', N'01889 655242', N'07332 289915', N'73 North Street', N'Paisley', N'Yorkshire', '20070914 16:09:21.697', N'Christopher.Walker@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (29, N'Matthew Collins', N'01305 665775', N'07352 869339', N'60 York Road', N'Outer Hebrides', N'Staffordshire', '20070914 16:09:21.713', N'Matthew.Collins@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (30, N'Elidh Peterson', N'01183 454781', N'07295 215265', N'59 Albert Road', N'Norwich', N'Cheshire', '20070914 16:09:21.727', N'Elidh.Peterson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (31, N'Jamie Price', N'01624 725814', N'07773 220491', N'40 Manor Road', N'Kingston upon Thames', N'Rutland', '20070914 16:09:21.743', N'Jamie.Price@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (32, N'Katie Sanchez', N'01192 635557', N'07695 694205', N'50 New Street', N'Hemel Hempstead', N'Cornwall', '20070914 16:09:21.743', N'Katie.Sanchez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (33, N'Erin Rodriguez', N'01701 154719', N'07699 485122', N'8 York Road', N'Swindon', N'Derbyshire', '20070914 16:09:21.760', N'Erin.Rodriguez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (34, N'Abbie Brooks', N'01287 924924', N'07149 593067', N'73 Springfield Road', N'Ipswich', N'County Durham', '20070914 16:09:21.773', N'Abbie.Brooks@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (35, N'Lauren Simmons', N'01442 337633', N'07986 644216', N'98 London Road', N'London E', N'Cheshire', '20070914 16:09:21.790', N'Lauren.Simmons@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (36, N'Emily Bennett', N'01907 200803', N'07636 884168', N'90 West Street', N'Salisbury', N'Herefordshire', '20070914 16:09:21.790', N'Emily.Bennett@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (37, N'Christopher Flores', N'01198 529461', N'07207 549127', N'74 Queens Road', N'Crewe', N'Cheshire', '20070914 16:09:21.807', N'Christopher.Flores@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (38, N'Alexander Rivera', N'01120 243659', N'07237 275885', N'25 Grange Road', N'Dudley', N'Huntingdonshire', '20070914 16:09:21.820', N'Alexander.Rivera@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (39, N'Rachel Williams', N'01512 965727', N'07889 215998', N'62 Victoria Road', N'Dundee', N'Hampshire', '20070914 16:09:21.837', N'Rachel.Williams@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (40, N'Olvia Howard', N'01547 693549', N'07341 808038', N'17 Kings Road', N'Guildford', N'Warwickshire', '20070914 16:09:21.837', N'Olvia.Howard@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (41, N'Elizabeth Flores', N'01231 471798', N'07493 384582', N'64 The Green', N'Bournemouth', N'Staffordshire', '20070914 16:09:21.853', N'Elizabeth.Flores@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (42, N'Kyle Griffin', N'01558 179557', N'07522 904690', N'21 Manchester Road', N'Kirkcaldy', N'Hampshire', '20070914 16:09:21.870', N'Kyle.Griffin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (43, N'Laura Evan', N'01495 153619', N'07390 958114', N'68 Station Road', N'St Albans', N'Berkshire', '20070914 16:09:21.883', N'Laura.Evan@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (44, N'Katie Martinez', N'01285 948244', N'07424 397578', N'99 Windsor Road', N'Lerwick', N'Oxfordshire', '20070914 16:09:21.883', N'Katie.Martinez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (45, N'Sophie Griffin', N'01965 513379', N'07605 294144', N'10 The Green', N'Sheffield', N'Surrey', '20070914 16:09:21.900', N'Sophie.Griffin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (46, N'Elidh Wood', N'01198 529461', N'07207 549127', N'88 North Road', N'Northampton', N'Essex', '20070914 16:09:21.917', N'Elidh.Wood@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (47, N'Abigail Hill', N'01555 443077', N'07439 738948', N'86 The Drive', N'Sunderland', N'Hampshire', '20070914 16:09:21.930', N'Abigail.Hill@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (48, N'Scott Bell', N'01469 486350', N'07759 520189', N'25 Park Avenue', N'Harrogate', N'Surrey', '20070914 16:09:21.930', N'Scott.Bell@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (49, N'Chloe Martin', N'01329 343662', N'07783 161081', N'33 New Street', N'Telford', N'Dorset', '20070914 16:09:21.947', N'Chloe.Martin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (50, N'Lauren Bryant', N'01752 908316', N'07676 584363', N'70 School Lane', N'Swindon', N'Middlesex', '20070914 16:09:21.963', N'Lauren.Bryant@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (51, N'Lucy Rivera', N'01287 924924', N'07149 593067', N'31 The Grove', N'Rochester', N'Cumberland', '20070914 16:09:21.977', N'Lucy.Rivera@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (52, N'Chloe Davis', N'01346 526218', N'07291 685237', N'99 The Crescent', N'Coventry', N'Shropshire', '20070914 16:09:21.977', N'Chloe.Davis@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (53, N'Joseph Thompson', N'01237 661433', N'07302 871821', N'75 Grove road', N'Truro', N'Northumberland', '20070914 16:09:21.993', N'Joseph.Thompson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (54, N'William Wright', N'01417 502667', N'07177 363555', N'57 Station Road', N'Romford', N'Middlesex', '20070914 16:09:22.010', N'William.Wright@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (55, N'William Hughes', N'01407 629329', N'07309 884547', N'34 High Street', N'Torquay', N'Dorset', '20070914 16:09:22.023', N'William.Hughes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (56, N'Samantha Miller', N'01333 824728', N'07634 606994', N'60 Park Lane', N'Cardiff', N'Surrey', '20070914 16:09:22.040', N'Samantha.Miller@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (57, N'William Ramirez', N'01626 530682', N'07768 951632', N'95 Grange Road', N'Cardiff', N'Berkshire', '20070914 16:09:22.040', N'William.Ramirez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (58, N'Lauren Green', N'01811 269842', N'07316 264705', N'28 Main Street', N'Huddersfield', N'Somerset', '20070914 16:09:22.057', N'Lauren.Green@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (59, N'Jordan Henderson', N'01624 725814', N'07773 220491', N'67 The Drive', N'Tonbridge', N'Surrey', '20070914 16:09:22.070', N'Jordan.Henderson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (60, N'Michael Richardson', N'01346 526218', N'07291 685237', N'76 Highfield Road', N'Kilmarnock', N'County Durham', '20070914 16:09:22.087', N'Michael.Richardson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (61, N'Caitlin Washington', N'01291 914147', N'07913 286110', N'55 School Lane', N'Peterborough', N'Licolnshire', '20070914 16:09:22.103', N'Caitlin.Washington@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (62, N'Anna Long', N'01131 669331', N'07113 804523', N'41 The Avenue', N'Stevenage', N'Cornwall', '20070914 16:09:22.103', N'Anna.Long@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (63, N'Ethan Parker', N'01940 919059', N'07331 757163', N'76 York Road', N'Blackpool', N'Middlesex', '20070914 16:09:22.120', N'Ethan.Parker@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (64, N'Lauren Ramirez', N'01417 502667', N'07177 363555', N'74 Albert Road', N'Crewe', N'Kent', '20070914 16:09:22.133', N'Lauren.Ramirez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (65, N'Joshua Price', N'01404 421474', N'07720 314778', N'24 The Green', N'Southend on Sea', N'Yorkshire', '20070914 16:09:22.150', N'Joshua.Price@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (66, N'Kyle Hall', N'01291 914147', N'07913 286110', N'25 Kingsway', N'Aberdeen', N'Lancashire', '20070914 16:09:22.150', N'Kyle.Hall@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (67, N'Bethany Hughes', N'01210 611735', N'07709 761071', N'6 New Street', N'Stevenage', N'Buckinghamshire', '20070914 16:09:22.167', N'Bethany.Hughes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (68, N'Kyle Smith', N'01555 443077', N'07439 738948', N'90 Main Street', N'Cardiff', N'Buckinghamshire', '20070914 16:09:22.180', N'Kyle.Smith@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (69, N'Caitlin Griffin', N'01469 486350', N'07759 520189', N'100 Mill Road', N'Oxford', N'Sussex', '20070914 16:09:22.197', N'Caitlin.Griffin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (70, N'Jamie Perez', N'01572 459202', N'07858 711874', N'86 Queens Road', N'Nottingham', N'Staffordshire', '20070914 16:09:22.213', N'Jamie.Perez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (71, N'Jennifer Turner', N'01192 635557', N'07695 694205', N'46 London Road', N'Brighton', N'Derbyshire', '20070914 16:09:22.213', N'Jennifer.Turner@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (72, N'Alexander Barnes', N'01281 554917', N'07800 642581', N'78 North Street', N'London W', N'Lancashire', '20070914 16:09:22.227', N'Alexander.Barnes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (73, N'Megan Campbell', N'01205 396727', N'07198 312473', N'20 Park Avenue', N'Blackburn', N'Suffolk', '20070914 16:09:22.243', N'Megan.Campbell@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (74, N'Lewis Collins', N'01237 661433', N'07302 871821', N'10 Victoria Road', N'Southall', N'Norfolk', '20070914 16:09:22.260', N'Lewis.Collins@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (75, N'Bethany Peterson', N'01784 976829', N'07885 861269', N'43 The Crescent', N'Worcester', N'Surrey', '20070914 16:09:22.260', N'Bethany.Peterson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (76, N'Erin Martin', N'01428 428418', N'07377 251946', N'39 The Avenue', N'Milton Keynes', N'Suffolk', '20070914 16:09:22.273', N'Erin.Martin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (77, N'Joseph Coleman', N'01788 915553', N'07736 274237', N'95 Park Avenue', N'Wolverhampton', N'Leicestershire', '20070914 16:09:22.290', N'Joseph.Coleman@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (78, N'Jordan Scott', N'01500 424473', N'07824 778422', N'12 Stanley Road', N'Galashiels', N'Cambridgeshire', '20070914 16:09:22.307', N'Jordan.Scott@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (79, N'Kieran Kelly', N'01633 392324', N'07960 870808', N'91 London Road', N'Twickenham', N'Northumberland', '20070914 16:09:22.320', N'Kieran.Kelly@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (80, N'Anthony Brown', N'01231 471798', N'07493 384582', N'41 Queensway', N'Falkirk', N'Berkshire', '20070914 16:09:22.337', N'Anthony.Brown@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (81, N'Joshua Sanders', N'01902 365096', N'07414 740869', N'12 Albert Road', N'Dundee', N'Hampshire', '20070914 16:09:22.353', N'Joshua.Sanders@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (82, N'Bethany Rivera', N'01784 976829', N'07885 861269', N'54 Church Street', N'London E', N'Northumberland', '20070914 16:09:22.353', N'Bethany.Rivera@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (83, N'Laura Hayes', N'01982 956405', N'07109 544766', N'56 Station Road', N'Brighton', N'Devon', '20070914 16:09:22.370', N'Laura.Hayes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (84, N'Anna Griffin', N'01231 471798', N'07493 384582', N'40 Windsor Road', N'Guildford', N'Cornwall', '20070914 16:09:22.383', N'Anna.Griffin@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (85, N'Samantha Jackson', N'01231 471798', N'07493 384582', N'14 New Street', N'Llandudno', N'County Durham', '20070914 16:09:22.400', N'Samantha.Jackson@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (86, N'Kyle Sanchez', N'01978 657197', N'07610 445571', N'3 Windsor Road', N'Bromley', N'Oxfordshire', '20070914 16:09:22.400', N'Kyle.Sanchez@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (87, N'Shannon King', N'01624 725814', N'07773 220491', N'56 King Street', N'Paisley', N'Gloucestershire', '20070914 16:09:22.417', N'Shannon.King@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (88, N'Joseph Gray', N'01211 864653', N'07375 760438', N'56 South Street', N'London E', N'Gloucestershire', '20070914 16:09:22.430', N'Joseph.Gray@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (89, N'Courtney Perry', N'01210 611735', N'07709 761071', N'13 St. John''s Road', N'York', N'Berkshire', '20070914 16:09:22.447', N'Courtney.Perry@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (90, N'Matthew Campbell', N'01743 360803', N'07394 612512', N'68 Queen Street', N'Romford', N'Essex', '20070914 16:09:22.463', N'Matthew.Campbell@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (91, N'Alexis Cook', N'01624 725814', N'07773 220491', N'36 Queen Street', N'Falkirk', N'Norfolk', '20070914 16:09:22.463', N'Alexis.Cook@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (92, N'Jamie Mitchell', N'01776 202627', N'07185 505540', N'90 High Street', N'Kingston upon Thames', N'Warwickshire', '20070914 16:09:22.477', N'Jamie.Mitchell@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (93, N'Chloe Morris', N'01725 222331', N'07526 574605', N'97 Main Street', N'Bradford', N'Cambridgeshire', '20070914 16:09:22.493', N'Chloe.Morris@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (94, N'Lauren Morris', N'01914 784723', N'07264 945002', N'44 Church Street', N'Durham', N'Warwickshire', '20070914 16:09:22.510', N'Lauren.Morris@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (95, N'Olvia Barnes', N'01811 269842', N'07316 264705', N'78 Stanley Road', N'Lincoln', N'Herefordshire', '20070914 16:09:22.510', N'Olvia.Barnes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (96, N'Olvia Hall', N'01571 657822', N'07694 711784', N'14 Windsor Road', N'Coventry', N'Middlesex', '20070914 16:09:22.523', N'Olvia.Hall@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (97, N'Scott Turner', N'01555 443077', N'07439 738948', N'87 Station Road', N'Salisbury', N'Surrey', '20070914 16:09:22.540', N'Scott.Turner@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (98, N'Rebecca Hayes', N'01802 342584', N'07296 315860', N'94 George Street', N'Bournemouth', N'Somerset', '20070914 16:09:22.557', N'Rebecca.Hayes@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (99, N'Kyle Perry', N'01653 610021', N'07363 920914', N'82 The Grove', N'Derby', N'Gloucestershire', '20070914 16:09:22.570', N'Kyle.Perry@example.com')
INSERT INTO [dbo].[Contacts] ([ID], [ContactFullName], [PhoneWork], [PhoneMobile], [Address1], [Address2], [Address3], [JoiningDate], [Email]) VALUES (100, N'Kieran Patterson', N'01389 465402', N'07266 836025', N'3 St. John''s Road', N'Bolton', N'County Durham', '20070914 16:09:22.570', N'Kieran.Patterson@example.com')
SET IDENTITY_INSERT [dbo].[Contacts] OFF


GO

/* here we add some default articles - we should make these relevant to the session, ideally with a bit of humor */
INSERT INTO dbo.Articles (AuthorID , Title, [Description], [Date] , ModifiedDate, URL)
VALUES	
	( 1 , 'What Counts For a DBA: Bravery' , 'As a DBA, you have the opportunity to act like a firefighter. In fact the term ''fire-fighting'' is very often used to describe those tasks needed to find the root cause of a system outage because there are a lot of similarities.' , '2013-01-23' ,'2013-01-10', 'https://www.simple-talk.com/blogs/2013/04/19/what-counts-for-a-dba-bravery/' )
,	( 2 , 'The Ten Commandments of SQL Server Monitoring' , 'It is easy to get database monitoring wrong. There are several common-sense rules that can make all the difference between a monitoring system that works for you and helps to avoid database problems, and one that just creates a distraction. Adam Machanic spells out the rules, based on his considerable experience with database monitoring' , '2012-08-21' , '2012-01-20 00:00:00.000', 'https://www.simple-talk.com/sql/database-administration/the-ten-commandments-of-sql-server-monitoring/' )
,	( 3 , 'Monitoring Transactional Replication in SQL Server' , 'If you are using replication in SQL Server, you can monitor it in SSMS, but it makes sense to monitor distribution jobs automatically, especially if you can set up alerts or even set up first-line remedial action when a problem is detected. Francis shows how to do it in TSQL as an agent job.' , '2013-01-27' , '2013-02-25 00:00:00.000','https://www.simple-talk.com/sql/database-administration/monitoring-transactional-replication-in-sql-server/' )
,	( 4 , 'ASP.NET MVC: Annotated for Input' , 'With an ASP.NET MVC application of any size, there comes a time when you are faced with creating utility forms where you don''t need a special form layout. One of the best ways of doing this is by using data annotations. Despite a quirk or two, it can save a lot of time.' , '2013-02-18' ,'2013-02-03', 'https://www.simple-talk.com/dotnet/asp.net/asp.net-mvc-annotated-for-input/' )
,	( 5 , 'SQL Server Statistics Questions We Were Too Shy to Ask' , 'If you need to optimise SQL Server performance, it pays to understand SQL Server Statistics. Grant Fritchey answers some frequently-asked questions about SQL Server Statistics: the ones we somehow feel silly asking in public, and think twice about doing so.' , '2013-06-12' , '2013-06-12', 'https://www.simple-talk.com/sql/performance/sql-server-statistics-questions-we-were-too-shy-to-ask/' )

GO

-- Populate ArticlesPurchases with lots of data
DECLARE @purchaseCount INT
SET @purchaseCount = 0
SET NOCOUNT ON
DECLARE @temp FLOAT
-- First the base set which will be common with ArticlesLive
SET @temp = RAND(1)
WHILE (@purchaseCount < 314) BEGIN
	INSERT INTO [dbo].[ArticlesPurchases] ([ArticlesPriceID], [Quantity], [InvoiceNumber], [Date]) VALUES (
		CONVERT (INT, RAND() * 3) + 1, -- ArticlesPriceID
		CONVERT (INT, RAND() * 100) + 1, -- Quantity 
		'WIDG' + CONVERT (NVARCHAR(10), CONVERT (INT, RAND() * 10000) + 1), -- InvoiceNumber
		CONVERT (DATETIME, -- Date
			CONVERT (NVARCHAR (50), 
				'2007-' + 
				CONVERT (NVARCHAR (2), CONVERT (INT, RAND() * 11) + 1) + '-' + 
				CONVERT (NVARCHAR (2), CONVERT (INT, RAND () * 27) + 1)
			)
		)
	)
	SET @purchaseCount = @purchaseCount + 1
END
-- Now some more, which won't be, to simulate "development" data entry
SET @temp = RAND(314159)
SET @purchaseCount = 0
WHILE (@purchaseCount < 854) BEGIN
	INSERT INTO [dbo].[ArticlesPurchases] ([ArticlesPriceID], [Quantity], [InvoiceNumber], [Date]) VALUES (
		CONVERT (INT, RAND() * 3) + 1, -- ArticlesPriceID
		CONVERT (INT, RAND() * 100) + 1, -- Quantity 
		'WIDG' + CONVERT (NVARCHAR(10), CONVERT (INT, RAND() * 10000) + 1), -- InvoiceNumber
		CONVERT (DATETIME, -- Date
			CONVERT (NVARCHAR (50), 
				'2007-' + 
				CONVERT (NVARCHAR (2), CONVERT (INT, RAND() * 11) + 1) + '-' + 
				CONVERT (NVARCHAR (2), CONVERT (INT, RAND () * 27) + 1)
			)
		)
	)
	SET @purchaseCount = @purchaseCount + 1
END

-- Add 10 rows to [dbo].[ArticlesPrices]
SET IDENTITY_INSERT [dbo].[ArticlesPrices] ON
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price], [ValidFrom], [ValidTo], [Active]) VALUES (1, 1, 100, '2000-01-01 00:00:00.000', '2002-01-01 00:00:00.000', 'Y')
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price], [ValidFrom], [ValidTo], [Active]) VALUES (2, 2, 50, '2000-01-01 00:00:00.000', '2002-01-01 00:00:00.000', 'Y')
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price], [ValidFrom], [ValidTo], [Active]) VALUES (3, 4, 25, '2000-01-01 00:00:00.000', '2002-01-01 00:00:00.000', 'Y')
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price], [ValidFrom], [ValidTo], [Active]) VALUES (4, 1, 110, '2002-01-01 00:00:00.000', '2003-01-01 00:00:00.000', 'N')
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price], [ValidFrom], [ValidTo], [Active]) VALUES (5, 2, 55, '2002-01-01 00:00:00.000', '2003-01-01 00:00:00.000', 'N')
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price], [ValidFrom], [ValidTo], [Active]) VALUES (6, 4, 30, '2002-01-01 00:00:00.000', '2003-01-01 00:00:00.000', 'N')
/*
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (1, 9, 698.1374)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (2, 6, 325.4914)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (3, 6, 693.4032)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (4, 5, 116.1689)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (5, 3, 751.7997)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (6, 5, 49.3884)
*/
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (7, 5, 422.2571)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (8, 1, 895.2037)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (9, 10, 596.7856)
INSERT INTO [dbo].[ArticlesPrices] ([RecordID], [ArticlesID], [Price]) VALUES (10, 4, 213.4546)
SET IDENTITY_INSERT [dbo].[ArticlesPrices] OFF


-- Add 10 rows to [dbo].[ArticlesReferences]
SET IDENTITY_INSERT [dbo].[ArticlesReferences] ON
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (1, 'HRGM1S45G9L67Z6M9V74RCKV0ZQCYOW01OXJMLTMGB0')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (2, '0ULCDFPYJID56LL11R7RDK5J1MZN1KNFBGV6EDYIYYHJA')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (3, 'D10RLP49QF')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (4, '1AQF2WZUXTPQENN')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (5, 'OTE3L899YN')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (6, 'YYB2QGHC283V2IODYNAL3XWFFCB3S1GGFL0V')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (7, 'RZAWBKKLYCLXVAMN1612')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (8, 'NE4EJ')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (9, 'RMGGHTR7N0ORCCUHZQ6XQUSDFZTP4L5ISJTYHW3443YNCEOQ1')
INSERT INTO [dbo].[ArticlesReferences] ([ArticlesID], [Reference]) VALUES (10, 'ED8LAXU20IZ122V6ZTIVZ3M1SMV500B3NY6R968W4E')
SET IDENTITY_INSERT [dbo].[ArticlesReferences] OFF


-- Add 10 rows to [dbo].[ArticlesDescriptions]
SET IDENTITY_INSERT [dbo].[ArticlesDescriptions] ON
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [ShortDescription], [Description], [Picture]) VALUES (1, N'A Articles', N'<description xmlns="http://www.red-gate.com/Blogs/ArticlesDescriptionSchema">
  <descriptiveText>A cunning Articles</descriptiveText>
  <manufacturer>Acme Inc</manufacturer>
  <countryOfOrigin>UK</countryOfOrigin>
  <size length="12" width="4" height="7" />
</description>', 0x474946383961db00d800e64300000000698495465863cccccc010f1b003366000b14333333666666999999ffffff032d51808080021e3600333334424aafafaf01162884a5bae0e0e07b9aae586e7c1116186699991a21252020201f1f1f4f4f4fb0b0b0dfdfdf4f636f7f7f7f6079883d4d57505050021a2f00003303294ac6d8e399cccc84a9c1b7cedc739bb61e517de9f0f494b5cad4e1ea336699e2ebf15a85a5517d9f7b878d365165144876b0c9d8333366afb3b613395a0916204d5d678fa3af2d4252bed3df7f8386d0dae3cddce68db1c7ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021f90401000043002c00000000db00d8000007ff804382838485868788898a8b8c8d8e8f430907080390969798999a9b9c9d9e890900a20019081c9fa8a9aaabacad8708a21a1aa3a222090aaeb9babbbcabb000070a0a031f07b4c00913bdcbcccdce0a22a21bc2d40a1d091bc7a595cedddedf9a0ac60008d5e6c209bfb4a6b8e0eeeff0e2a2e5e7f5c308b3b4b6caf0fdfebb0346ddb2477098a463071870fbc7b0e1a680a206169c782d1bad52a71c6adca888c3280813439a83a06e14825b1c536e0c256a80c897e606e043984ca54d782c01b884c9b3dab571a3262dbc49b4d7af603d939ec3a6cd54d1a7ae8e2a9d5a8f643e5107a06afd248f1cd5aff5208ada4a36dc387a60d30a030aa0ac5b4813ffceaa552b76c482b66ff32a122b712ed59c0e0adcd54bd8105fbf60d515583c3891020efc0a13cdb913f1548b061633c67b48ec819a925352b64c751c09cd9b1189a5f53972e87f0cb05626cdb32eead4863cb62449d3f56b7052692785302af0ed020e380f1a4d8d376bd0bfbb0517ce33e782e3c8c915627ece7950e8d17775454bfda562ecc913149a5ed03b56f0e1578d2fcff35766ec1100a827c45ea47b64bec5d7c9001988f2017d308d13017605e4b79f200afc32cd54ffb526e08002212852070a32e82021f3a555217c173a729886138965dc711f0e12a25f2306582222dca1688f8a0c92a01321038cd3976531ce08ca28b3d9b8d4280c1660c0ff8e839c485f90420e72540746129453924b0ee5248a5096d85f95d55cc9609684d4586585198517215660dac3d27dd81970c05066b6a9807bf1bd6827356f26094c3b82b0a441917bf23956747a16da27837ff2c766a1f6e070682f1c5808508690a2230a9cc7352ae5a3999a03440e93eab2e677327eb2a5a29bfa198ca37f865acd003fd4709772aef4184b6faae8060048a142c4e96d5eb92897acd40494d9adbbe4444f979bd469670748a2a79db1f3209b2c00f731eb0a341f755712809a486be7380c26870088c76aabac66deb24220a8f640dbc897ac02b0226aeaf258a07eda0af32ebca5a6129b8130d98b08be851a4380b5eb3689a9bbdcde162fff2a71c542a87fe35a6a48a2a18a52c271e9f13831b203a376b127be4ef815b420870cc075a8b52888581b439ab2ca0573a2ce8f60c598b157010b234a0335eb57269145efcc33ae9ae80a4cce228e7b72c0bf186773244c07ecf4d39e38aba17b40070c948e0f72a00ed57b7e0df626e08a02ac8d107cc036b2161dc3dadd6dbafd7626f3024365d1eee6fd1ce17eff7d494e0712eef80090433e78d315274930d48e98ebf8e65e576ef9669837121b527c736e7adf9e7f2e58cf8e8cde020ff3cc7dfaec76268eddca8f8c2e841012547056e9b4073f97edb7b32e3a30bb274f81071800a00125c2474f1bf1c587ce88eec9674f410816389fc0e4d2873f15fff5d567827df6e85fc03d32e08bef7e8aa9abae3824e7a36f3f080f4853f6fbfc0f13bffc97cb044bec47c0ece14f1ab2eb9ffbc89724dc994814058ce0ee7a7796042a30780c6ca0f1180111097a907715681e398077c160fd0f80f37b44073ff8c1e535ef7925345d062de7c046ac90852cbc40f3f617c34ccd90861b5cc40d71e8c10a10ad879d1b160acb87892112b180f9e32112db76c2255a2c887b81e0132318c52926d18aaaab2107b5b845fb75d18b28ab221853f8400094117d12681e09d188a01f02508c4224e31be3a8133acaca8e77c462229cf8440a6060507e34a112d7c8203c66d18d6fbc40ac12a9333532f28ad6cb2324b72849a450b2ff50805ca22307a9471c0660929fac9d252f8949c095f28346244f2ac1144a2b8e5235af94602c6749c545b25283997c24113d0080c6f19296abfc652b9b984b029ef19855aae51a6fd99966a2ef99d0b49134a729485c02e002129480312c984dfa6c939bc15484280210413eceb19c6939273a35b1ce02ba139eda4ca6321bd94d44d4d37e3a9c133e51244f4652f310ffcc5e27076aa30f706b5ffb44e1410d91d0dd2d94a174fb0509201a5120a633111505c111316a24e79060641df5283d01c0cedded92a47b620a002280d2942e1313ff7c294c217510008cc0a66c74443d4300b09dcaea27a2f8a94d275a887562d3a87f9c8901387a49a612421433ff282a5411679f9a56b59f8669c956677710655a7508be6a1fa43a50b70f24e09dbc7401ef00803456e6e7a3dbe95ab00c370a63c254aebb130000ec3a0f4b080aaed4c989dee406d314644f0274656472aef50886d949b18b652c431d8b3ec1ae71b2afaa2cbd3285d9cc8a82a127202064a9fa39363d22663135ed62a548c9d44271b04b24d26bdb152a87ca566f7ee5250b5a20410ae80b854b62522386264b4859edb75ae55c2836405b9ec080b81ecc1f0093fba03146445bcffdad2739e7d008fc0e2c806de1713f77d7ee6a32ba990aef6f67078bc0484002cc73de07d42a92203c51bb96bb6bc41aa1b936f115ba62355d7d0b400001244f7dddfb0cff4f384b44e3b2363b94654481c1c41604279873c6d04c83ef973f7290d31c3678238049e65a026b4c5b1df63062ab1462113b58b5be731ef4ea61db325a183b2d668465cfe5e163cc589b0718d6888b2b8008f785053d56316e51a3db7b8db69245a6c59109fabf257ff00225a6ee70dfa8bdf52e26b943710c6f7d98652dcbf0845ec6618e01400132676fc5dc6d046c55d9e60f3b2e140bc24e9c8928010b3cc0ceca9b59832262c3710497a77df633e1009da44113d1887546b4100e4000013bc247da2aad8c151cd94adff88d86d6b4102ed0bd0c2fc218cdcd579fb7aca1055bced24414293811ad021d78aa11c6d8010c6425dfdfd21a41b6bef5a9dfff788003f09ac1006000248ce16013c437d27d04f1943f876b229eb2a5658cc1620810ed6903e0c62770c19e8a2ddb63d3a7c6f2eb36119bfd461988b8dc8fa076f64e606d1a63dbddd41980067cc920799b92a55b7c016ac82ded7c9fdb7ea7dcc0892d13e3516fee8706c721bd718802852f1cdf9f7e38fa4e190b04f0772e154730c0851390875931e32cfc360b51b082e330dcdccbde1dc90f8798d5b479e5b4a1341861cec28d4b500535b739c8812df2eced5c6f3b068bcfb30c74d2087de83927b3244170f44a2f9d11fa1eb978ab5b90a917b9ea964936d655bdbb0758208217b8f5d75fddf4e43d5db60898b895b09d6dc7a97ded6c376e0508286effb9373ce459bffb6f35b0df9788dae28ecbc6850148741cbadd7e1e373cce211e690917c4b791d67ba6e0cdcacab350f0d9cbbce61d9e78be8fb01eec962dd9f744fad2671dd1971702cd293f774584dde9ae7f4f35626fdad9a38ee080f72005022001f55660f7bc3f3cd35b1f7c934020e508363e32919ffc0282a0d5c0c874040fd08397f73e11bfb77bf5d70f5f6d11e734293578fe025d8225edba8007a82b0a6fce7aceb3dff5da572557d751f2664410a523cd877ffa177d9b2776ff876d016824034880b737574a452c87a680e6277d6057773af78091168136f277145840c4942e74a6814bc47f88e77f20586422882224588204840117d8291ea0ff82fb777e88907e1ff8821ee63245630c5e0554b8065934831fce4640f9b7810d087c40586451272bb507540c767ba76439c9a1830cd87f0e188545a601df93291cb26d56386eb7674440c485f1c68387e08342a078608860d4d54b676873b727002ec74f6ca83a2c387d2e38877d36851a5250f196866678457dc86d6e680870288782188663882013788768484059982425b049e8d3842bd88885f08891587d75985833658982767bc6653923b084f6e3893bc88174477da3587d84a816a17083a868630564010b482c21b088abd7825f588bd5278627971433b88bdd4654fc747f9df88b7e088a84208ac6f880a54815cbc88c15f86336e78aaf288d8c28ff8bbee78171788d40788b22610c49b88b7818419e751bf9018dd1e8845e0885e8f882c8982089e88e0b57816d67663a3278e3278ec30888c5988f2f286613010bfea86c1e2458a360015c2741b0d885c4888f0a1985ec740227e00326109229e09142a0870f696a1f2401015001e0669106e975e4887ee608891bc97e2d4940267992a9c876d973916d18933d389335098637693f39a993b7617a1af79205478d83608d43f98245d9597b8894bcc893bbe393d308946f28945129951159955679855899954c29684e290850f995ff478f46299656a9944577964ac7958ee8956cf97f1f749463499665a995e3f884ea97977a19967d79955809984932597619ff8a784998d5b79770899472f9418a692dbf86901a0999ae074bfda89395e941978949a1758f83c999c1f741997898a1e99200340aa9528eb4889a7ca79a9f7992ad5990f2536596b096b41969b6799897f89774c99bbdf998bfd967c1299cb9298c9a81669ae09bc99965cb79980b207e3c399a79169dc8399d45569d8759966689258cb609d2e99d08069e56991c0f5091d969903aa2349c709ee8f95beaa99393350aedc97680e9699d409ff599596fe741ab899477d56cc7f0006ef9445ae99fffd99d016a5ae05840057a92078a0b13c000ff220a1610020b6a99bf380285f509001aa108719fee78a18520131b0a001dfaa15c085aa950a2261a14288aff8a2aaa1a08d0a22f3a979a015a80e209345aa3c843a0b779860e2a443b4a0b18e001d8198e8b01a4aa30a4353aa19878a44095a48ea036c7d0a44f3a9e05200a1910a4240aa144ca1a376a855a6a095ccaa44eda9348639ca840a5266aa59ce78fe4e66a9ad0a6a3800115d07c34909f6936a7667aa65891a629955c03860a1c100dac7103723aa3e6284e869a59762a76bba8a8df92008e4a0bee35a5e6b83bdb53a9276aa4a8a8a9e2c1a9e5e90a70883e2144aa452a41156a53dbb90c0a109b840a900a5562677aa9c07787b52a19e320005faa5a1e007e11aaab1f7886c12a198af500538989bc5a9fca7a8e56d8aca131012561017f7a7a4d46ad88caff480251220a90002d1a02c54a4020807d7959adb3fa4be31a2503d0a9c010adf633aabfe9ae586a45f11a2582a0adb460011e9080b0c4ae1ba9af1dd5affeea223d250a0f90ae0035ad5f89b0fb14a90bdb24257100eee941bd83ac3549b1f0da1217bb08191ab0036b4a129b8f207b49163bb287d0b000a0a0382401dfaa902b0b469b28b22eab42194b902cb4ae2a1bae5ad8b23bab080aa0a113290004ab7c12598b378b42825ab4e5c216d07a6906cb7e3e1b41efaa3a512bb50f51127e5a61290b82f6aa7e6034591930a85e8b09e5daa2c43ab3af0a8465bbac4b24a56bcba8543bb74e37b6c1a7b75b8b829979b79f00b013d9ad2c845f1eeb7a7ebbffaf3f1a6482ab0a6d4b0be8ea6d578b608b0b40221ab88fbb0af3ca1a7aab3c358b6d97ab3a39bab9ba40b81c7ab27256b98b35ba01e6b8a66b2ae64a0b0f5b6144d566aeeb21b01bbbbc2013acb1b11c1bb7968ba877250264cabbcb50b213a9ba39c4b7c790bbf238a2c80b0e302bb3337bacb205bd9ab1a6d3eb0dbe1b1459ab9a7cabbd8ba6a7dd0b0e47bba116a0b41516bad6f4ab4929bde7fb0fd50ba3ea0a14316786a83abf0ef1bda210b6b6cb895abb6dfbcbbf1a11b9a3f0b6e2891a056cc01c5129b4fbb944f49cf2ebc02a81ba00e0a74b6b6767b6aa164c14082c0a938b684ae2c11ffc148deab9642601d87ac24f81c1dcbac11c2b429fea39c25a11c2310bb10a45c3365c189d1b14c0fb8535dcc36ea1bca94bb02a995f264cc48501b396aab64cecc3cf8511514cae910339c7ebc28100003b)
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [ShortDescription], [Description], [Picture]) VALUES (2, N'A medium-sized Articles', N'<description xmlns="http://www.red-gate.com/Blogs/ArticlesDescriptionSchema">
  <descriptiveText>This is a medium-sized Articles, ideally suited for the home and garden environment</descriptiveText>
  <manufacturer>Magic Articles Company</manufacturer>
  <countryOfOrigin>USA</countryOfOrigin>
  <size length="15" width="12" height="2" />
</description>', 0x474946383961db00d800e64300000000698495465863cccccc010f1b003366000b14333333666666999999ffffff032d51808080021e3600333334424aafafaf01162884a5bae0e0e07b9aae586e7c1116186699991a21252020201f1f1f4f4f4fb0b0b0dfdfdf4f636f7f7f7f6079883d4d57505050021a2f00003303294ac6d8e399cccc84a9c1b7cedc739bb61e517de9f0f494b5cad4e1ea336699e2ebf15a85a5517d9f7b878d365165144876b0c9d8333366afb3b613395a0916204d5d678fa3af2d4252bed3df7f8386d0dae3cddce68db1c7ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021f90401000043002c00000000db00d8000007ff804382838485868788898a8b8c8d8e8f430907080390969798999a9b9c9d9e890900a20019081c9fa8a9aaabacad8708a21a1aa3a222090aaeb9babbbcabb000070a0a031f07b4c00913bdcbcccdce0a22a21bc2d40a1d091bc7a595cedddedf9a0ac60008d5e6c209bfb4a6b8e0eeeff0e2a2e5e7f5c308b3b4b6caf0fdfebb0346ddb2477098a463071870fbc7b0e1a680a206169c782d1bad52a71c6adca888c3280813439a83a06e14825b1c536e0c256a80c897e606e043984ca54d782c01b884c9b3dab571a3262dbc49b4d7af603d939ec3a6cd54d1a7ae8e2a9d5a8f643e5107a06afd248f1cd5aff5208ada4a36dc387a60d30a030aa0ac5b4813ffceaa552b76c482b66ff32a122b712ed59c0e0adcd54bd8105fbf60d515583c3891020efc0a13cdb913f1548b061633c67b48ec819a925352b64c751c09cd9b1189a5f53972e87f0cb05626cdb32eead4863cb62449d3f56b7052692785302af0ed020e380f1a4d8d376bd0bfbb0517ce33e782e3c8c915627ece7950e8d17775454bfda562ecc913149a5ed03b56f0e1578d2fcff35766ec1100a827c45ea47b64bec5d7c9001988f2017d308d13017605e4b79f200afc32cd54ffb526e08002212852070a32e82021f3a555217c173a729886138965dc711f0e12a25f2306582222dca1688f8a0c92a01321038cd3976531ce08ca28b3d9b8d4280c1660c0ff8e839c485f90420e72540746129453924b0ee5248a5096d85f95d55cc9609684d4586585198517215660dac3d27dd81970c05066b6a9807bf1bd6827356f26094c3b82b0a441917bf23956747a16da27837ff2c766a1f6e070682f1c5808508690a2230a9cc7352ae5a3999a03440e93eab2e677327eb2a5a29bfa198ca37f865acd003fd4709772aef4184b6faae8060048a142c4e96d5eb92897acd40494d9adbbe4444f979bd469670748a2a79db1f3209b2c00f731eb0a341f755712809a486be7380c26870088c76aabac66deb24220a8f640dbc897ac02b0226aeaf258a07eda0af32ebca5a6129b8130d98b08be851a4380b5eb3689a9bbdcde162fff2a71c542a87fe35a6a48a2a18a52c271e9f13831b203a376b127be4ef815b420870cc075a8b52888581b439ab2ca0573a2ce8f60c598b157010b234a0335eb57269145efcc33ae9ae80a4cce228e7b72c0bf186773244c07ecf4d39e38aba17b40070c948e0f72a00ed57b7e0df626e08a02ac8d107cc036b2161dc3dadd6dbafd7626f3024365d1eee6fd1ce17eff7d494e0712eef80090433e78d315274930d48e98ebf8e65e576ef9669837121b527c736e7adf9e7f2e58cf8e8cde020ff3cc7dfaec76268eddca8f8c2e841012547056e9b4073f97edb7b32e3a30bb274f81071800a00125c2474f1bf1c587ce88eec9674f410816389fc0e4d2873f15fff5d567827df6e85fc03d32e08bef7e8aa9abae3824e7a36f3f080f4853f6fbfc0f13bffc97cb044bec47c0ece14f1ab2eb9ffbc89724dc994814058ce0ee7a7796042a30780c6ca0f1180111097a907715681e398077c160fd0f80f37b44073ff8c1e535ef7925345d062de7c046ac90852cbc40f3f617c34ccd90861b5cc40d71e8c10a10ad879d1b160acb87892112b180f9e32112db76c2255a2c887b81e0132318c52926d18aaaab2107b5b845fb75d18b28ab221853f8400094117d12681e09d188a01f02508c4224e31be3a8133acaca8e77c462229cf8440a6060507e34a112d7c8203c66d18d6fbc40ac12a9333532f28ad6cb2324b72849a450b2ff50805ca22307a9471c0660929fac9d252f8949c095f28346244f2ac1144a2b8e5235af94602c6749c545b25283997c24113d0080c6f19296abfc652b9b984b029ef19855aae51a6fd99966a2ef99d0b49134a729485c02e002129480312c984dfa6c939bc15484280210413eceb19c6939273a35b1ce02ba139eda4ca6321bd94d44d4d37e3a9c133e51244f4652f310ffcc5e27076aa30f706b5ffb44e1410d91d0dd2d94a174fb0509201a5120a633111505c111316a24e79060641df5283d01c0cedded92a47b620a002280d2942e1313ff7c294c217510008cc0a66c74443d4300b09dcaea27a2f8a94d275a887562d3a87f9c8901387a49a612421433ff282a5411679f9a56b59f8669c956677710655a7508be6a1fa43a50b70f24e09dbc7401ef00803456e6e7a3dbe95ab00c370a63c254aebb130000ec3a0f4b080aaed4c989dee406d314644f0274656472aef50886d949b18b652c431d8b3ec1ae71b2afaa2cbd3285d9cc8a82a127202064a9fa39363d22663135ed62a548c9d44271b04b24d26bdb152a87ca566f7ee5250b5a20410ae80b854b62522386264b4859edb75ae55c2836405b9ec080b81ecc1f0093fba03146445bcffdad2739e7d008fc0e2c806de1713f77d7ee6a32ba990aef6f67078bc0484002cc73de07d42a92203c51bb96bb6bc41aa1b936f115ba62355d7d0b400001244f7dddfb0cff4f384b44e3b2363b94654481c1c41604279873c6d04c83ef973f7290d31c3678238049e65a026b4c5b1df63062ab1462113b58b5be731ef4ea61db325a183b2d668465cfe5e163cc589b0718d6888b2b8008f785053d56316e51a3db7b8db69245a6c59109fabf257ff00225a6ee70dfa8bdf52e26b943710c6f7d98652dcbf0845ec6618e01400132676fc5dc6d046c55d9e60f3b2e140bc24e9c8928010b3cc0ceca9b59832262c3710497a77df633e1009da44113d1887546b4100e4000013bc247da2aad8c151cd94adff88d86d6b4102ed0bd0c2fc218cdcd579fb7aca1055bced24414293811ad021d78aa11c6d8010c6425dfdfd21a41b6bef5a9dfff788003f09ac1006000248ce16013c437d27d04f1943f876b229eb2a5658cc1620810ed6903e0c62770c19e8a2ddb63d3a7c6f2eb36119bfd461988b8dc8fa076f64e606d1a63dbddd41980067cc920799b92a55b7c016ac82ded7c9fdb7ea7dcc0892d13e3516fee8706c721bd718802852f1cdf9f7e38fa4e190b04f0772e154730c0851390875931e32cfc360b51b082e330dcdccbde1dc90f8798d5b479e5b4a1341861cec28d4b500535b739c8812df2eced5c6f3b068bcfb30c74d2087de83927b3244170f44a2f9d11fa1eb978ab5b90a917b9ea964936d655bdbb0758208217b8f5d75fddf4e43d5db60898b895b09d6dc7a97ded6c376e0508286effb9373ce459bffb6f35b0df9788dae28ecbc6850148741cbadd7e1e373cce211e690917c4b791d67ba6e0cdcacab350f0d9cbbce61d9e78be8fb01eec962dd9f744fad2671dd1971702cd293f774584dde9ae7f4f35626fdad9a38ee080f72005022001f55660f7bc3f3cd35b1f7c934020e508363e32919ffc0282a0d5c0c874040fd08397f73e11bfb77bf5d70f5f6d11e734293578fe025d8225edba8007a82b0a6fce7aceb3dff5da572557d751f2664410a523cd877ffa177d9b2776ff876d016824034880b737574a452c87a680e6277d6057773af78091168136f277145840c4942e74a6814bc47f88e77f20586422882224588204840117d8291ea0ff82fb777e88907e1ff8821ee63245630c5e0554b8065934831fce4640f9b7810d087c40586451272bb507540c767ba76439c9a1830cd87f0e188545a601df93291cb26d56386eb7674440c485f1c68387e08342a078608860d4d54b676873b727002ec74f6ca83a2c387d2e38877d36851a5250f196866678457dc86d6e680870288782188663882013788768484059982425b049e8d3842bd88885f08891587d75985833658982767bc6653923b084f6e3893bc88174477da3587d84a816a17083a868630564010b482c21b088abd7825f588bd5278627971433b88bdd4654fc747f9df88b7e088a84208ac6f880a54815cbc88c15f86336e78aaf288d8c28ff8bbee78171788d40788b22610c49b88b7818419e751bf9018dd1e8845e0885e8f882c8982089e88e0b57816d67663a3278e3278ec30888c5988f2f286613010bfea86c1e2458a360015c2741b0d885c4888f0a1985ec740227e00326109229e09142a0870f696a1f2401015001e0669106e975e4887ee608891bc97e2d4940267992a9c876d973916d18933d389335098637693f39a993b7617a1af79205478d83608d43f98245d9597b8894bcc893bbe393d308946f28945129951159955679855899954c29684e290850f995ff478f46299656a9944577964ac7958ee8956cf97f1f749463499665a995e3f884ea97977a19967d79955809984932597619ff8a784998d5b79770899472f9418a692dbf86901a0999ae074bfda89395e941978949a1758f83c999c1f741997898a1e99200340aa9528eb4889a7ca79a9f7992ad5990f2536596b096b41969b6799897f89774c99bbdf998bfd967c1299cb9298c9a81669ae09bc99965cb79980b207e3c399a79169dc8399d45569d8759966689258cb609d2e99d08069e56991c0f5091d969903aa2349c709ee8f95beaa99393350aedc97680e9699d409ff599596fe741ab899477d56cc7f0006ef9445ae99fffd99d016a5ae05840057a92078a0b13c000ff220a1610020b6a99bf380285f509001aa108719fee78a18520131b0a001dfaa15c085aa950a2261a14288aff8a2aaa1a08d0a22f3a979a015a80e209345aa3c843a0b779860e2a443b4a0b18e001d8198e8b01a4aa30a4353aa19878a44095a48ea036c7d0a44f3a9e05200a1910a4240aa144ca1a376a855a6a095ccaa44eda9348639ca840a5266aa59ce78fe4e66a9ad0a6a3800115d07c34909f6936a7667aa65891a629955c03860a1c100dac7103723aa3e6284e869a59762a76bba8a8df92008e4a0bee35a5e6b83bdb53a9276aa4a8a8a9e2c1a9e5e90a70883e2144aa452a41156a53dbb90c0a109b840a900a5562677aa9c07787b52a19e320005faa5a1e007e11aaab1f7886c12a198af500538989bc5a9fca7a8e56d8aca131012561017f7a7a4d46ad88caff480251220a90002d1a02c54a4020807d7959adb3fa4be31a2503d0a9c010adf633aabfe9ae586a45f11a2582a0adb460011e9080b0c4ae1ba9af1dd5affeea223d250a0f90ae0035ad5f89b0fb14a90bdb24257100eee941bd83ac3549b1f0da1217bb08191ab0036b4a129b8f207b49163bb287d0b000a0a0382401dfaa902b0b469b28b22eab42194b902cb4ae2a1bae5ad8b23bab080aa0a113290004ab7c12598b378b42825ab4e5c216d07a6906cb7e3e1b41efaa3a512bb50f51127e5a61290b82f6aa7e6034591930a85e8b09e5daa2c43ab3af0a8465bbac4b24a56bcba8543bb74e37b6c1a7b75b8b829979b79f00b013d9ad2c845f1eeb7a7ebbffaf3f1a6482ab0a6d4b0be8ea6d578b608b0b40221ab88fbb0af3ca1a7aab3c358b6d97ab3a39bab9ba40b81c7ab27256b98b35ba01e6b8a66b2ae64a0b0f5b6144d566aeeb21b01bbbbc2013acb1b11c1bb7968ba877250264cabbcb50b213a9ba39c4b7c790bbf238a2c80b0e302bb3337bacb205bd9ab1a6d3eb0dbe1b1459ab9a7cabbd8ba6a7dd0b0e47bba116a0b41516bad6f4ab4929bde7fb0fd50ba3ea0a14316786a83abf0ef1bda210b6b6cb895abb6dfbcbbf1a11b9a3f0b6e2891a056cc01c5129b4fbb944f49cf2ebc02a81ba00e0a74b6b6767b6aa164c14082c0a938b684ae2c11ffc148deab9642601d87ac24f81c1dcbac11c2b429fea39c25a11c2310bb10a45c3365c189d1b14c0fb8535dcc36ea1bca94bb02a995f264cc48501b396aab64cecc3cf8511514cae910339c7ebc28100003b)
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (3, 'Et Pro plorum trepicandor pladior e fecundio, vobis novum bono pars Quad regit, travissimantor e cognitio, nomen', '21711')
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (4, 'volcans Longam, estis non non estis et Id vantis. esset transit. Sed et fecit, vobis fecit. plurissimum quorum rarendum trepicandor quantare cognitio, si', '51534')
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (5, 'essit. volcans quad novum in brevens, si manifestum cognitio, non eudis glavans e delerium. eggredior.', '40493')
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (6, 'glavans eggredior. eudis delerium. cognitio, pars fecit. funem. essit. si pladior eggredior. glavans', '78782')
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (7, 'quo, plorum quo vobis manifestum Et imaginator eggredior. rarendum et quad fecit. linguens delerium. linguens', '50517')
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (8, 'Longam, quorum glavans ut Longam, e e venit. brevens, parte dolorum Longam, Quad et esset novum Sed Tam', NULL)
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (9, 'bono Sed plorum quad quad si plurissimum et Quad gravis homo, bono sed quo egreddior imaginator plorum Sed', '38345')
INSERT INTO [dbo].[ArticlesDescriptions] ([ArticlesID], [Description], [ArticlesName]) VALUES (10, 'pladior cognitio, quartu volcans vobis pladior nomen Id transit. quorum plurissimum sed vantis. in quis', '86125')
SET IDENTITY_INSERT [dbo].[ArticlesDescriptions] OFF

GRANT  SELECT  ON [dbo].[ArticlesPrices]  TO [public]
GO

DENY  REFERENCES ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[ArticlesPrices]  TO [public] CASCADE 
GO

GRANT  SELECT  ON [dbo].[Blogs]  TO [public]
GO

DENY  REFERENCES ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[Blogs]  TO [public] CASCADE 
GO


CREATE PROCEDURE prcGetContacts 
    AS SELECT 
    ID ,
		ContactFullName
		FROM Contacts
		
GO
CREATE PROCEDURE prcActivatePrices  AS

UPDATE ArticlesPrices SET Active='N' WHERE GETDATE()<ValidTo OR GETDATE()>ValidFrom
UPDATE ArticlesPrices SET Active='Y' WHERE GETDATE()>=ValidFrom OR GETDATE()<=ValidFrom

GO
DENY  EXECUTE  ON [dbo].[prcActivatePrices]  TO [public] CASCADE 
GO



/* 
Sample execution: 
EXEC [prcAddContact] 'david', '12345', '23456', '152 Riverside Place', 'Cambridge', '', 'feedback@red-gate.com', NULL
*/

CREATE PROCEDURE [dbo].[prcAddContact]   @ContactFullName VARCHAR(30),
										 @PhoneWork VARCHAR(30) = NULL,
										 @PhoneMobile VARCHAR(30) = NULL,
										 @Address1 VARCHAR(30) = NULL,
										 @Address2 VARCHAR(30) = NULL,
										 @Address3 VARCHAR(30) = NULL,
										 @Email VARCHAR(30) = NULL,
										 @JoiningDate DATETIME = NULL

WITH EXECUTE AS CALLER
AS
BEGIN

INSERT INTO dbo.Contacts
        ( ContactFullName ,
          PhoneWork ,
          PhoneMobile ,
          Address1 ,
          Address2 ,
          Address3 ,
          JoiningDate ,
          ModifiedDate ,
          Email
        )
VALUES  ( @ContactFullName , -- ContactFullName - nvarchar(100)
         @PhoneWork , -- PhoneWork - nvarchar(25)
         @PhoneMobile , -- PhoneMobile - nvarchar(25)
         @Address1 , -- Address1 - nvarchar(128)
         @Address2 , -- Address2 - nvarchar(128)
         @Address3 , -- Address3 - nvarchar(128)
          @JoiningDate , -- JoiningDate - datetime, e.g. '2012-01-17 11:42:45' 
          GETDATE() , -- ModifiedDate - datetime
          @Email  -- Email - nvarchar(256)
        )
        
        
        END;
GO

/* This is a procedure that simply contains dynamic SQL just to demonstrate that dependencies aren't picked up. 
Use SQL Search to find these. */
CREATE PROCEDURE [dbo].[prcProcedureWithDynamicSQL]
AS 
    BEGIN

        EXECUTE  ('SELECT count(*) FROM Contacts WHERE ContactFullName LIKE ''D%''')
    END

GO



/* Adding tSQLt Unit tests */

---Build+
/*
   Copyright 2011 tSQLt

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
DECLARE @Msg NVARCHAR(MAX);SELECT @Msg = 'Compiled at '+CONVERT(NVARCHAR,GETDATE(),121);RAISERROR(@Msg,0,1);
GO

IF TYPE_ID('tSQLt.Private') IS NOT NULL DROP TYPE tSQLt.Private;
IF TYPE_ID('tSQLtPrivate') IS NOT NULL DROP TYPE tSQLtPrivate;
GO
IF OBJECT_ID('tSQLt.DropClass') IS NOT NULL
    EXEC tSQLt.DropClass tSQLt;
GO

IF EXISTS (SELECT 1 FROM sys.assemblies WHERE name = 'tSQLtCLR')
    DROP ASSEMBLY tSQLtCLR;
GO

CREATE SCHEMA tSQLt;
GO
SET QUOTED_IDENTIFIER ON;
GO
---Build-

GO

IF OBJECT_ID('tSQLt.DropClass') IS NOT NULL DROP PROCEDURE tSQLt.DropClass;
GO
---Build+
CREATE PROCEDURE tSQLt.DropClass
    @ClassName NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Cmd NVARCHAR(MAX);

    WITH A(name, type) AS
           (SELECT QUOTENAME(SCHEMA_NAME(schema_id))+'.'+QUOTENAME(name) , type
              FROM sys.objects
             WHERE schema_id = SCHEMA_ID(@ClassName)
          ),
         B(no,cmd) AS
           (SELECT 0,'DROP ' +
                    CASE type WHEN 'P' THEN 'PROCEDURE'
                              WHEN 'PC' THEN 'PROCEDURE'
                              WHEN 'U' THEN 'TABLE'
                              WHEN 'IF' THEN 'FUNCTION'
                              WHEN 'TF' THEN 'FUNCTION'
                              WHEN 'FN' THEN 'FUNCTION'
                              WHEN 'V' THEN 'VIEW'
                     END +
                   ' ' + name + ';'
              FROM A
             UNION ALL
            SELECT -1,'DROP SCHEMA ' + QUOTENAME(name) +';'
              FROM sys.schemas
             WHERE schema_id = SCHEMA_ID(@ClassName)
           ),
         C(xml)AS
           (SELECT cmd [text()]
              FROM B
             ORDER BY no DESC
               FOR XML PATH(''), TYPE
           )
    SELECT @Cmd = xml.value('/', 'NVARCHAR(MAX)') 
      FROM C;

    EXEC(@Cmd);
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_GetFullTypeName') IS NOT NULL DROP FUNCTION tSQLt.Private_GetFullTypeName;
---Build+
GO
CREATE FUNCTION tSQLt.Private_GetFullTypeName(@TypeId INT, @Length INT, @Precision INT, @Scale INT, @CollationName NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN SELECT SchemaName + '.' + Name + Suffix + Collation AS TypeName, SchemaName, Name, Suffix
FROM(
  SELECT QUOTENAME(SCHEMA_NAME(schema_id)) SchemaName, QUOTENAME(name) Name,
              CASE WHEN max_length = -1
                    THEN ''
                   WHEN @Length = -1
                    THEN '(MAX)'
                   WHEN name LIKE 'n%char'
                    THEN '(' + CAST(@Length / 2 AS NVARCHAR) + ')'
                   WHEN name LIKE '%char' OR name LIKE '%binary'
                    THEN '(' + CAST(@Length AS NVARCHAR) + ')'
                   WHEN name IN ('decimal', 'numeric')
                    THEN '(' + CAST(@Precision AS NVARCHAR) + ',' + CAST(@Scale AS NVARCHAR) + ')'
                   ELSE ''
               END Suffix,
              CASE WHEN @CollationName IS NULL THEN ''
                   ELSE ' COLLATE ' + @CollationName
               END Collation
          FROM sys.types WHERE user_type_id = @TypeId
          )X;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_DisallowOverwritingNonTestSchema') IS NOT NULL DROP PROCEDURE tSQLt.Private_DisallowOverwritingNonTestSchema;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_DisallowOverwritingNonTestSchema
  @ClassName NVARCHAR(MAX)
AS
BEGIN
  IF SCHEMA_ID(@ClassName) IS NOT NULL AND tSQLt.Private_IsTestClass(@ClassName) = 0
  BEGIN
    RAISERROR('Attempted to execute tSQLt.NewTestClass on ''%s'' which is an existing schema but not a test class', 16, 10, @ClassName);
  END
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_QuoteClassNameForNewTestClass') IS NOT NULL DROP FUNCTION tSQLt.Private_QuoteClassNameForNewTestClass;
GO
---Build+
CREATE FUNCTION tSQLt.Private_QuoteClassNameForNewTestClass(@ClassName NVARCHAR(MAX))
  RETURNS NVARCHAR(MAX)
AS
BEGIN
  RETURN 
    CASE WHEN @ClassName LIKE '[[]%]' THEN @ClassName
         ELSE QUOTENAME(@ClassName)
     END;
END;
---Build-
GO
 

GO

IF OBJECT_ID('tSQLt.Private_MarkSchemaAsTestClass') IS NOT NULL DROP PROCEDURE tSQLt.Private_MarkSchemaAsTestClass;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_MarkSchemaAsTestClass
  @QuotedClassName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @UnquotedClassName NVARCHAR(MAX);

  SELECT @UnquotedClassName = name
    FROM sys.schemas
   WHERE QUOTENAME(name) = @QuotedClassName;

  EXEC sp_addextendedproperty @name = N'tSQLt.TestClass', 
                              @value = 1,
                              @level0type = 'SCHEMA',
                              @level0name = @UnquotedClassName;
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.NewTestClass') IS NOT NULL DROP PROCEDURE tSQLt.NewTestClass;
GO
---Build+
CREATE PROCEDURE tSQLt.NewTestClass
    @ClassName NVARCHAR(MAX)
AS
BEGIN
  BEGIN TRY
    EXEC tSQLt.Private_DisallowOverwritingNonTestSchema @ClassName;

    EXEC tSQLt.DropClass @ClassName = @ClassName;

    DECLARE @QuotedClassName NVARCHAR(MAX);
    SELECT @QuotedClassName = tSQLt.Private_QuoteClassNameForNewTestClass(@ClassName);

    EXEC ('CREATE SCHEMA ' + @QuotedClassName);  
    EXEC tSQLt.Private_MarkSchemaAsTestClass @QuotedClassName;
  END TRY
  BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(MAX);SET @ErrMsg = ERROR_MESSAGE() + ' (Error originated in ' + ERROR_PROCEDURE() + ')';
    DECLARE @ErrSvr INT;SET @ErrSvr = ERROR_SEVERITY();
    
    RAISERROR(@ErrMsg, @ErrSvr, 10);
  END CATCH;
END;
---Build-
GO


GO


CREATE TABLE tSQLt.TestResult(
    Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    Class NVARCHAR(MAX) NOT NULL,
    TestCase NVARCHAR(MAX) NOT NULL,
    Name AS (QUOTENAME(Class) + '.' + QUOTENAME(TestCase)),
    TranName NVARCHAR(MAX) NOT NULL,
    Result NVARCHAR(MAX) NULL,
    Msg NVARCHAR(MAX) NULL
);
GO
CREATE TABLE tSQLt.TestMessage(
    Msg NVARCHAR(MAX)
);
GO
CREATE TABLE tSQLt.Run_LastExecution(
    TestName NVARCHAR(MAX),
    SessionId INT,
    LoginTime DATETIME
);
GO

CREATE PROCEDURE tSQLt.Private_Print 
    @Message NVARCHAR(MAX),
    @Severity INT = 0
AS 
BEGIN
    DECLARE @SPos INT;SET @SPos = 1;
    DECLARE @EPos INT;
    DECLARE @Len INT; SET @Len = LEN(@Message);
    DECLARE @SubMsg NVARCHAR(MAX);
    DECLARE @Cmd NVARCHAR(MAX);
    
    DECLARE @CleanedMessage NVARCHAR(MAX);
    SET @CleanedMessage = REPLACE(@Message,'%','%%');
    
    WHILE (@SPos <= @Len)
    BEGIN
      SET @EPos = CHARINDEX(CHAR(13)+CHAR(10),@CleanedMessage+CHAR(13)+CHAR(10),@SPos);
      SET @SubMsg = SUBSTRING(@CleanedMessage, @SPos, @EPos - @SPos);
      SET @Cmd = N'RAISERROR(@Msg,@Severity,10) WITH NOWAIT;';
      EXEC sp_executesql @Cmd, 
                         N'@Msg NVARCHAR(MAX),@Severity INT',
                         @SubMsg,
                         @Severity;
      SELECT @SPos = @EPos + 2,
             @Severity = 0; --Print only first line with high severity
    END

    RETURN 0;
END;
GO

CREATE PROCEDURE tSQLt.Private_PrintXML
    @Message XML
AS 
BEGIN
    SELECT @Message FOR XML PATH('');--Required together with ":XML ON" sqlcmd statement to allow more than 1mb to be returned
    RETURN 0;
END;
GO


CREATE PROCEDURE tSQLt.GetNewTranName
  @TranName CHAR(32) OUTPUT
AS
BEGIN
  SELECT @TranName = LEFT('tSQLtTran'+REPLACE(CAST(NEWID() AS NVARCHAR(60)),'-',''),32);
END;
GO

CREATE PROCEDURE tSQLt.Fail
    @Message0 NVARCHAR(MAX) = '',
    @Message1 NVARCHAR(MAX) = '',
    @Message2 NVARCHAR(MAX) = '',
    @Message3 NVARCHAR(MAX) = '',
    @Message4 NVARCHAR(MAX) = '',
    @Message5 NVARCHAR(MAX) = '',
    @Message6 NVARCHAR(MAX) = '',
    @Message7 NVARCHAR(MAX) = '',
    @Message8 NVARCHAR(MAX) = '',
    @Message9 NVARCHAR(MAX) = ''
AS
BEGIN
   INSERT INTO tSQLt.TestMessage(Msg)
   SELECT COALESCE(@Message0, '!NULL!')
        + COALESCE(@Message1, '!NULL!')
        + COALESCE(@Message2, '!NULL!')
        + COALESCE(@Message3, '!NULL!')
        + COALESCE(@Message4, '!NULL!')
        + COALESCE(@Message5, '!NULL!')
        + COALESCE(@Message6, '!NULL!')
        + COALESCE(@Message7, '!NULL!')
        + COALESCE(@Message8, '!NULL!')
        + COALESCE(@Message9, '!NULL!');
        
   RAISERROR('tSQLt.Failure',16,10);
END;
GO

CREATE PROCEDURE tSQLt.Private_RunTest
   @TestName NVARCHAR(MAX),
   @SetUp NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @Msg NVARCHAR(MAX); SET @Msg = '';
    DECLARE @Msg2 NVARCHAR(MAX); SET @Msg2 = '';
    DECLARE @Cmd NVARCHAR(MAX); SET @Cmd = '';
    DECLARE @TestClassName NVARCHAR(MAX); SET @TestClassName = '';
    DECLARE @TestProcName NVARCHAR(MAX); SET @TestProcName = '';
    DECLARE @Result NVARCHAR(MAX); SET @Result = 'Success';
    DECLARE @TranName CHAR(32); EXEC tSQLt.GetNewTranName @TranName OUT;
    DECLARE @TestResultId INT;
    DECLARE @PreExecTrancount INT;
    
    TRUNCATE TABLE tSQLt.CaptureOutputLog;

    IF EXISTS (SELECT 1 FROM sys.extended_properties WHERE name = N'SetFakeViewOnTrigger')
    BEGIN
      RAISERROR('Test system is in an invalid state. SetFakeViewOff must be called if SetFakeViewOn was called. Call SetFakeViewOff after creating all test case procedures.', 16, 10) WITH NOWAIT;
      RETURN -1;
    END;

    SELECT @Cmd = 'EXEC ' + @TestName;
    
    SELECT @TestClassName = OBJECT_SCHEMA_NAME(OBJECT_ID(@TestName)), --tSQLt.Private_GetCleanSchemaName('', @TestName),
           @TestProcName = tSQLt.Private_GetCleanObjectName(@TestName);
           
    INSERT INTO tSQLt.TestResult(Class, TestCase, TranName, Result) 
        SELECT @TestClassName, @TestProcName, @TranName, 'A severe error happened during test execution. Test did not finish.'
        OPTION(MAXDOP 1);
    SELECT @TestResultId = SCOPE_IDENTITY();

    BEGIN TRAN;
    SAVE TRAN @TranName;

    SET @PreExecTrancount = @@TRANCOUNT;
    
    TRUNCATE TABLE tSQLt.TestMessage;

    BEGIN TRY
        IF (@SetUp IS NOT NULL) EXEC @SetUp;
        EXEC (@Cmd);
    END TRY
    BEGIN CATCH
        IF ERROR_MESSAGE() LIKE '%tSQLt.Failure%'
        BEGIN
            SELECT @Msg = Msg FROM tSQLt.TestMessage;
            SET @Result = 'Failure';
        END
        ELSE
        BEGIN
            SELECT @Msg = COALESCE(ERROR_MESSAGE(), '<ERROR_MESSAGE() is NULL>') + '{' + COALESCE(ERROR_PROCEDURE(), '<ERROR_PROCEDURE() is NULL>') + ',' + COALESCE(CAST(ERROR_LINE() AS NVARCHAR), '<ERROR_LINE() is NULL>') + '}';
            SET @Result = 'Error';
        END;
    END CATCH

    BEGIN TRY
        ROLLBACK TRAN @TranName;
    END TRY
    BEGIN CATCH
        SET @PreExecTrancount = @PreExecTrancount - @@TRANCOUNT;
        IF (@@TRANCOUNT > 0) ROLLBACK;
        BEGIN TRAN;
        IF(   @Result <> 'Success'
           OR @PreExecTrancount <> 0
          )
        BEGIN
          SELECT @Msg = COALESCE(@Msg, '<NULL>') + ' (There was also a ROLLBACK ERROR --> ' + COALESCE(ERROR_MESSAGE(), '<ERROR_MESSAGE() is NULL>') + '{' + COALESCE(ERROR_PROCEDURE(), '<ERROR_PROCEDURE() is NULL>') + ',' + COALESCE(CAST(ERROR_LINE() AS NVARCHAR), '<ERROR_LINE() is NULL>') + '})';
          SET @Result = 'Error';
        END
    END CATCH    

    If(@Result <> 'Success') 
    BEGIN
      SET @Msg2 = @TestName + ' failed: ' + @Msg;
      EXEC tSQLt.Private_Print @Message = @Msg2, @Severity = 0;
    END

    IF EXISTS(SELECT 1 FROM tSQLt.TestResult WHERE Id = @TestResultId)
    BEGIN
        UPDATE tSQLt.TestResult SET
            Result = @Result,
            Msg = @Msg
         WHERE Id = @TestResultId;
    END
    ELSE
    BEGIN
        INSERT tSQLt.TestResult(Class, TestCase, TranName, Result, Msg)
        SELECT @TestClassName, 
               @TestProcName,  
               '?', 
               'Error', 
               'TestResult entry is missing; Original outcome: ' + @Result + ', ' + @Msg;
    END    
      

    COMMIT;
END;
GO

CREATE PROCEDURE tSQLt.Private_CleanTestResult
AS
BEGIN
   DELETE FROM tSQLt.TestResult;
END;
GO

CREATE PROCEDURE tSQLt.RunTest
   @TestName NVARCHAR(MAX)
AS
BEGIN
  RAISERROR('tSQLt.RunTest has been retired. Please use tSQLt.Run instead.', 16, 10);
END;
GO

CREATE PROCEDURE tSQLt.SetTestResultFormatter
    @Formatter NVARCHAR(4000)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM sys.extended_properties WHERE [name] = N'tSQLt.ResultsFormatter')
    BEGIN
        EXEC sp_dropextendedproperty @name = N'tSQLt.ResultsFormatter',
                                    @level0type = 'SCHEMA',
                                    @level0name = 'tSQLt',
                                    @level1type = 'PROCEDURE',
                                    @level1name = 'Private_OutputTestResults';
    END;

    EXEC sp_addextendedproperty @name = N'tSQLt.ResultsFormatter', 
                                @value = @Formatter,
                                @level0type = 'SCHEMA',
                                @level0name = 'tSQLt',
                                @level1type = 'PROCEDURE',
                                @level1name = 'Private_OutputTestResults';
END;
GO

CREATE FUNCTION tSQLt.GetTestResultFormatter()
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @FormatterName NVARCHAR(MAX);
    
    SELECT @FormatterName = CAST(value AS NVARCHAR(MAX))
    FROM sys.extended_properties
    WHERE name = N'tSQLt.ResultsFormatter'
      AND major_id = OBJECT_ID('tSQLt.Private_OutputTestResults');
      
    SELECT @FormatterName = COALESCE(@FormatterName, 'tSQLt.DefaultResultFormatter');
    
    RETURN @FormatterName;
END;
GO

CREATE PROCEDURE tSQLt.DefaultResultFormatter
AS
BEGIN
    DECLARE @Msg1 NVARCHAR(MAX);
    DECLARE @Msg2 NVARCHAR(MAX);
    DECLARE @Msg3 NVARCHAR(MAX);
    DECLARE @Msg4 NVARCHAR(MAX);
    DECLARE @IsSuccess INT;
    DECLARE @SuccessCnt INT;
    DECLARE @Severity INT;
    
    SELECT ROW_NUMBER() OVER(ORDER BY Result DESC, Name ASC) No,Name [Test Case Name], Result
      INTO #Tmp
      FROM tSQLt.TestResult;
    
    EXEC tSQLt.TableToText @Msg1 OUTPUT, '#Tmp', 'No';

    SELECT @Msg3 = Msg, 
           @IsSuccess = 1 - SIGN(FailCnt + ErrorCnt),
           @SuccessCnt = SuccessCnt
      FROM tSQLt.TestCaseSummary();
      
    SELECT @Severity = 16*(1-@IsSuccess);
    
    SELECT @Msg2 = REPLICATE('-',LEN(@Msg3)),
           @Msg4 = CHAR(13)+CHAR(10);
    
    
    EXEC tSQLt.Private_Print @Msg4,0;
    EXEC tSQLt.Private_Print '+----------------------+',0;
    EXEC tSQLt.Private_Print '|Test Execution Summary|',0;
    EXEC tSQLt.Private_Print '+----------------------+',0;
    EXEC tSQLt.Private_Print @Msg4,0;
    EXEC tSQLt.Private_Print @Msg1,0;
    EXEC tSQLt.Private_Print @Msg2,0;
    EXEC tSQLt.Private_Print @Msg3, @Severity;
    EXEC tSQLt.Private_Print @Msg2,0;
END;
GO

CREATE PROCEDURE tSQLt.XmlResultFormatter
AS
BEGIN
    DECLARE @XmlOutput XML;

    SELECT @XmlOutput = (
      SELECT Tag, Parent, [testsuites!1!hide!hide], [testsuite!2!name], [testsuite!2!tests], [testsuite!2!errors], [testsuite!2!failures], [testcase!3!classname], [testcase!3!name], [failure!4!message]  FROM (
        SELECT 1 AS Tag,
               NULL AS Parent,
               'root' AS [testsuites!1!hide!hide],
               NULL AS [testsuite!2!name],
               NULL AS [testsuite!2!tests],
               NULL AS [testsuite!2!errors],
               NULL AS [testsuite!2!failures],
               NULL AS [testcase!3!classname],
               NULL AS [testcase!3!name],
               NULL AS [failure!4!message]
        UNION ALL
        SELECT 2 AS Tag, 
               1 AS Parent,
               'root',
               Class AS [testsuite!2!name],
               COUNT(1) AS [testsuite!2!tests],
               SUM(CASE Result WHEN 'Error' THEN 1 ELSE 0 END) AS [testsuite!2!errors],
               SUM(CASE Result WHEN 'Failure' THEN 1 ELSE 0 END) AS [testsuite!2!failures],
               NULL AS [testcase!3!classname],
               NULL AS [testcase!3!name],
               NULL AS [failure!4!message]
          FROM tSQLt.TestResult
        GROUP BY Class
        UNION ALL
        SELECT 3 AS Tag,
               2 AS Parent,
               'root',
               Class,
               NULL,
               NULL,
               NULL,
               Class,
               TestCase,
               NULL
          FROM tSQLt.TestResult
        UNION ALL
        SELECT 4 AS Tag,
               3 AS Parent,
               'root',
               Class,
               NULL,
               NULL,
               NULL,
               Class,
               TestCase,
               Msg
          FROM tSQLt.TestResult
         WHERE Result IN ('Failure', 'Error')) AS X
       ORDER BY [testsuite!2!name], [testcase!3!name], Tag
       FOR XML EXPLICIT
       );

    EXEC tSQLt.Private_PrintXML @XmlOutput;
END;
GO

CREATE PROCEDURE tSQLt.NullTestResultFormatter
AS
BEGIN
  RETURN 0;
END;
GO

CREATE PROCEDURE tSQLt.Private_OutputTestResults
  @TestResultFormatter NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @Formatter NVARCHAR(MAX);
    SELECT @Formatter = COALESCE(@TestResultFormatter, tSQLt.GetTestResultFormatter());
    EXEC (@Formatter);
END
GO

CREATE PROCEDURE tSQLt.RunTestClass
   @TestClassName NVARCHAR(MAX)
AS
BEGIN
    EXEC tSQLt.Run @TestClassName;
END
GO    

----------------------------------------------------------------------
CREATE FUNCTION tSQLt.Private_GetLastTestNameIfNotProvided(@TestName NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
  IF(LTRIM(ISNULL(@TestName,'')) = '')
  BEGIN
    SELECT @TestName = TestName 
      FROM tSQLt.Run_LastExecution le
      JOIN sys.dm_exec_sessions es
        ON le.SessionId = es.session_id
       AND le.LoginTime = es.login_time
     WHERE es.session_id = @@SPID;
  END

  RETURN @TestName;
END
GO

CREATE PROCEDURE tSQLt.Private_SaveTestNameForSession 
  @TestName NVARCHAR(MAX)
AS
BEGIN
  DELETE FROM tSQLt.Run_LastExecution
   WHERE SessionId = @@SPID;  

  INSERT INTO tSQLt.Run_LastExecution(TestName, SessionId, LoginTime)
  SELECT TestName = @TestName,
         session_id,
         login_time
    FROM sys.dm_exec_sessions
   WHERE session_id = @@SPID;
END
GO

----------------------------------------------------------------------
CREATE VIEW tSQLt.TestClasses
AS
  SELECT s.name AS Name, s.schema_id AS SchemaId
    FROM sys.extended_properties ep
    JOIN sys.schemas s
      ON ep.major_id = s.schema_id
   WHERE ep.name = N'tSQLt.TestClass';
GO

CREATE VIEW tSQLt.Tests
AS
  SELECT classes.SchemaId, classes.Name AS TestClassName, 
         procs.object_id AS ObjectId, procs.name AS Name
    FROM tSQLt.TestClasses classes
    JOIN sys.procedures procs ON classes.SchemaId = procs.schema_id
   WHERE LOWER(procs.name) LIKE 'test%';
GO

CREATE PROCEDURE tSQLt.Private_Run
   @TestName NVARCHAR(MAX),
   @TestResultFormatter NVARCHAR(MAX)
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @FullName NVARCHAR(MAX);
    DECLARE @SchemaId INT;
    DECLARE @IsTestClass BIT;
    DECLARE @IsTestCase BIT;
    DECLARE @IsSchema BIT;
    DECLARE @SetUp NVARCHAR(MAX);SET @SetUp = NULL;
    
    SELECT @TestName = tSQLt.Private_GetLastTestNameIfNotProvided(@TestName);
    EXEC tSQLt.Private_SaveTestNameForSession @TestName;
    
    SELECT @SchemaId = schemaId,
           @FullName = quotedFullName,
           @IsTestClass = isTestClass,
           @IsSchema = isSchema,
           @IsTestCase = isTestCase
      FROM tSQLt.Private_ResolveName(@TestName);
     
    EXEC tSQLt.Private_CleanTestResult;

    IF @IsSchema = 1
    BEGIN
        EXEC tSQLt.Private_RunTestClass @FullName;
    END
    
    IF @IsTestCase = 1
    BEGIN
      SELECT @SetUp = tSQLt.Private_GetQuotedFullName(object_id)
        FROM sys.procedures
       WHERE schema_id = @SchemaId
         AND name = 'SetUp';

      EXEC tSQLt.Private_RunTest @FullName, @SetUp;
    END;

    EXEC tSQLt.Private_OutputTestResults @TestResultFormatter;
END;
GO

CREATE PROCEDURE tSQLt.Run
   @TestName NVARCHAR(MAX) = NULL
AS
BEGIN
  DECLARE @TestResultFormatter NVARCHAR(MAX);
  SELECT @TestResultFormatter = tSQLt.GetTestResultFormatter();
  
  EXEC tSQLt.Private_Run @TestName, @TestResultFormatter;
END;
GO

CREATE PROCEDURE tSQLt.RunWithXmlResults
   @TestName NVARCHAR(MAX) = NULL
AS
BEGIN
  EXEC tSQLt.Private_Run @TestName, 'tSQLt.XmlResultFormatter';
END;
GO

CREATE PROCEDURE tSQLt.RunWithNullResults
    @TestName NVARCHAR(MAX) = NULL
AS
BEGIN
  EXEC tSQLt.Private_Run @TestName, 'tSQLt.NullTestResultFormatter';
END;
GO


CREATE FUNCTION tSQLt.TestCaseSummary()
RETURNS TABLE
AS
RETURN WITH A(Cnt, SuccessCnt, FailCnt, ErrorCnt) AS (
                SELECT COUNT(1),
                       ISNULL(SUM(CASE WHEN Result = 'Success' THEN 1 ELSE 0 END), 0),
                       ISNULL(SUM(CASE WHEN Result = 'Failure' THEN 1 ELSE 0 END), 0),
                       ISNULL(SUM(CASE WHEN Result = 'Error' THEN 1 ELSE 0 END), 0)
                  FROM tSQLt.TestResult
                  
                )
       SELECT 'Test Case Summary: ' + CAST(Cnt AS NVARCHAR) + ' test case(s) executed, '+
                  CAST(SuccessCnt AS NVARCHAR) + ' succeeded, '+
                  CAST(FailCnt AS NVARCHAR) + ' failed, '+
                  CAST(ErrorCnt AS NVARCHAR) + ' errored.' Msg,*
         FROM A;
GO

CREATE PROCEDURE tSQLt.Private_RunTestClass
  @TestClassName NVARCHAR(MAX)
AS
BEGIN
    DECLARE @TestCaseName NVARCHAR(MAX);
    DECLARE @SetUp NVARCHAR(MAX);SET @SetUp = NULL;

    SELECT @SetUp = tSQLt.Private_GetQuotedFullName(object_id)
      FROM sys.procedures
     WHERE schema_id = tSQLt.Private_GetSchemaId(@TestClassName)
       AND LOWER(name) = 'setup';

    DECLARE testCases CURSOR LOCAL FAST_FORWARD 
        FOR
     SELECT tSQLt.Private_GetQuotedFullName(object_id)
       FROM sys.procedures
      WHERE schema_id = tSQLt.Private_GetSchemaId(@TestClassName)
        AND LOWER(name) LIKE 'test%';

    OPEN testCases;
    
    FETCH NEXT FROM testCases INTO @TestCaseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC tSQLt.Private_RunTest @TestCaseName, @SetUp;

        FETCH NEXT FROM testCases INTO @TestCaseName;
    END;

    CLOSE testCases;
    DEALLOCATE testCases;
END;
GO

CREATE PROCEDURE tSQLt.RunAll
AS
BEGIN
  DECLARE @TestResultFormatter NVARCHAR(MAX);
  SELECT @TestResultFormatter = tSQLt.GetTestResultFormatter();
  
  EXEC tSQLt.Private_RunAll @TestResultFormatter;
END;
GO

CREATE PROCEDURE tSQLt.Private_RunAll
  @TestResultFormatter NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @TestClassName NVARCHAR(MAX);
  DECLARE @TestProcName NVARCHAR(MAX);

  EXEC tSQLt.Private_CleanTestResult;

  DECLARE tests CURSOR LOCAL FAST_FORWARD FOR
   SELECT Name
     FROM tSQLt.TestClasses;

  OPEN tests;
  
  FETCH NEXT FROM tests INTO @TestClassName;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC tSQLt.Private_RunTestClass @TestClassName;
    
    FETCH NEXT FROM tests INTO @TestClassName;
  END;
  
  CLOSE tests;
  DEALLOCATE tests;
  
  EXEC tSQLt.Private_OutputTestResults @TestResultFormatter;
END;
GO

CREATE PROCEDURE tSQLt.Private_ValidateProcedureCanBeUsedWithSpyProcedure
    @ProcedureName NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID(@ProcedureName))
    BEGIN
      RAISERROR('Cannot use SpyProcedure on %s because the procedure does not exist', 16, 10, @ProcedureName) WITH NOWAIT;
    END;
    
    IF (1020 < (SELECT COUNT(*) FROM sys.parameters WHERE object_id = OBJECT_ID(@ProcedureName)))
    BEGIN
      RAISERROR('Cannot use SpyProcedure on procedure %s because it contains more than 1020 parameters', 16, 10, @ProcedureName) WITH NOWAIT;
    END;
END;
GO


CREATE PROCEDURE tSQLt.AssertEquals
    @Expected SQL_VARIANT,
    @Actual SQL_VARIANT,
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
    IF ((@Expected = @Actual) OR (@Actual IS NULL AND @Expected IS NULL))
      RETURN 0;

    DECLARE @Msg NVARCHAR(MAX);
    SELECT @Msg = 'Expected: <' + ISNULL(CAST(@Expected AS NVARCHAR(MAX)), 'NULL') + 
                  '> but was: <' + ISNULL(CAST(@Actual AS NVARCHAR(MAX)), 'NULL') + '>';
    IF((COALESCE(@Message,'') <> '') AND (@Message NOT LIKE '% ')) SET @Message = @Message + ' ';
    EXEC tSQLt.Fail @Message, @Msg;
END;
GO

CREATE PROCEDURE tSQLt.AssertEqualsString
    @Expected NVARCHAR(MAX),
    @Actual NVARCHAR(MAX),
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
    IF ((@Expected = @Actual) OR (@Actual IS NULL AND @Expected IS NULL))
      RETURN 0;

    DECLARE @Msg NVARCHAR(MAX);
    SELECT @Msg = 'Expected: <' + ISNULL(@Expected, 'NULL') + 
                  '> but was: <' + ISNULL(@Actual, 'NULL') + '>';
    EXEC tSQLt.Fail @Message, @Msg;
END;
GO

CREATE PROCEDURE tSQLt.AssertObjectExists
    @ObjectName NVARCHAR(MAX),
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
    DECLARE @Msg NVARCHAR(MAX);
    IF(@ObjectName LIKE '#%')
    BEGIN
     IF OBJECT_ID('tempdb..'+@ObjectName) IS NULL
     BEGIN
         SELECT @Msg = '''' + COALESCE(@ObjectName, 'NULL') + ''' does not exist';
         EXEC tSQLt.Fail @Message, @Msg;
         RETURN 1;
     END;
    END
    ELSE
    BEGIN
     IF OBJECT_ID(@ObjectName) IS NULL
     BEGIN
         SELECT @Msg = '''' + COALESCE(@ObjectName, 'NULL') + ''' does not exist';
         EXEC tSQLt.Fail @Message, @Msg;
         RETURN 1;
     END;
    END;
    RETURN 0;
END;
GO

--------------------------------------------------------------------------------------------------------------------------
--below is untested code
--------------------------------------------------------------------------------------------------------------------------
GO
/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/
GO
CREATE PROCEDURE tSQLt.StubRecord(@SnTableName AS NVARCHAR(MAX), @BintObjId AS BIGINT)  
AS   
BEGIN  
    DECLARE @VcInsertStmt NVARCHAR(MAX),  
            @VcInsertValues NVARCHAR(MAX);  
    DECLARE @SnColumnName NVARCHAR(MAX); 
    DECLARE @SintDataType SMALLINT; 
    DECLARE @NvcFKCmd NVARCHAR(MAX);  
    DECLARE @VcFKVal NVARCHAR(MAX); 
  
    SET @VcInsertStmt = 'INSERT INTO ' + @SnTableName + ' ('  
      
    DECLARE curColumns CURSOR  
        LOCAL FAST_FORWARD  
    FOR  
    SELECT syscolumns.name,  
           syscolumns.xtype,  
           cmd.cmd  
    FROM syscolumns  
        LEFT OUTER JOIN dbo.sysconstraints ON syscolumns.id = sysconstraints.id  
                                      AND syscolumns.colid = sysconstraints.colid  
                                      AND sysconstraints.status = 1    -- Primary key constraints only  
        LEFT OUTER JOIN (select fkeyid id,fkey colid,N'select @V=cast(min('+syscolumns.name+') as NVARCHAR) from '+sysobjects.name cmd  
                        from sysforeignkeys   
                        join sysobjects on sysobjects.id=sysforeignkeys.rkeyid  
                        join syscolumns on sysobjects.id=syscolumns.id and syscolumns.colid=rkey) cmd  
            on cmd.id=syscolumns.id and cmd.colid=syscolumns.colid  
    WHERE syscolumns.id = OBJECT_ID(@SnTableName)  
      AND (syscolumns.isnullable = 0 )  
    ORDER BY ISNULL(sysconstraints.status, 9999), -- Order Primary Key constraints first  
             syscolumns.colorder  
  
    OPEN curColumns  
  
    FETCH NEXT FROM curColumns  
    INTO @SnColumnName, @SintDataType, @NvcFKCmd  
  
    -- Treat the first column retrieved differently, no commas need to be added  
    -- and it is the ObjId column  
    IF @@FETCH_STATUS = 0  
    BEGIN  
        SET @VcInsertStmt = @VcInsertStmt + @SnColumnName  
        SELECT @VcInsertValues = ')VALUES(' + ISNULL(CAST(@BintObjId AS nvarchar), 'NULL')  
  
        FETCH NEXT FROM curColumns  
        INTO @SnColumnName, @SintDataType, @NvcFKCmd  
    END  
    ELSE  
    BEGIN  
        -- No columns retrieved, we need to insert into any first column  
        SELECT @VcInsertStmt = @VcInsertStmt + syscolumns.name  
        FROM syscolumns  
        WHERE syscolumns.id = OBJECT_ID(@SnTableName)  
          AND syscolumns.colorder = 1  
  
        SELECT @VcInsertValues = ')VALUES(' + ISNULL(CAST(@BintObjId AS nvarchar), 'NULL')  
  
    END  
  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        SET @VcInsertStmt = @VcInsertStmt + ',' + @SnColumnName  
        SET @VcFKVal=',0'  
        if @NvcFKCmd is not null  
        BEGIN  
            set @VcFKVal=null  
            exec sp_executesql @NvcFKCmd,N'@V NVARCHAR(MAX) output',@VcFKVal output  
            set @VcFKVal=isnull(','''+@VcFKVal+'''',',NULL')  
        END  
        SET @VcInsertValues = @VcInsertValues + @VcFKVal  
  
        FETCH NEXT FROM curColumns  
        INTO @SnColumnName, @SintDataType, @NvcFKCmd  
    END  
      
    CLOSE curColumns  
    DEALLOCATE curColumns  
  
    SET @VcInsertStmt = @VcInsertStmt + @VcInsertValues + ')'  
  
    IF EXISTS (SELECT 1   
               FROM syscolumns  
               WHERE status = 128   
                 AND id = OBJECT_ID(@SnTableName))  
    BEGIN  
        SET @VcInsertStmt = 'SET IDENTITY_INSERT ' + @SnTableName + ' ON ' + CHAR(10) +   
                             @VcInsertStmt + CHAR(10) +   
                             'SET IDENTITY_INSERT ' + @SnTableName + ' OFF '  
    END  
  
    EXEC (@VcInsertStmt)    -- Execute the actual INSERT statement  
  
END  

GO

/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/
CREATE FUNCTION tSQLt.Private_GetCleanSchemaName(@SchemaName NVARCHAR(MAX), @ObjectName NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN (SELECT SCHEMA_NAME(schema_id) 
              FROM sys.objects 
             WHERE object_id = CASE WHEN ISNULL(@SchemaName,'') in ('','[]')
                                    THEN OBJECT_ID(@ObjectName)
                                    ELSE OBJECT_ID(@SchemaName + '.' + @ObjectName)
                                END);
END;
GO

CREATE FUNCTION [tSQLt].[Private_GetCleanObjectName](@ObjectName NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN (SELECT OBJECT_NAME(OBJECT_ID(@ObjectName)));
END;
GO

CREATE FUNCTION tSQLt.Private_ResolveFakeTableNamesForBackwardCompatibility 
 (@TableName NVARCHAR(MAX), @SchemaName NVARCHAR(MAX))
RETURNS TABLE AS 
RETURN
  SELECT QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) AS CleanSchemaName,
         QUOTENAME(OBJECT_NAME(object_id)) AS CleanTableName
     FROM (SELECT CASE
                    WHEN @SchemaName IS NULL THEN OBJECT_ID(@TableName)
                    ELSE COALESCE(OBJECT_ID(@SchemaName + '.' + @TableName),OBJECT_ID(@TableName + '.' + @SchemaName)) 
                  END object_id
          ) ids;
GO

CREATE PROCEDURE tSQLt.TableCompare
       @Expected NVARCHAR(MAX),
       @Actual NVARCHAR(MAX),
       @Txt NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    DECLARE @Cmd NVARCHAR(MAX);
    DECLARE @R INT;
    DECLARE @En NVARCHAR(MAX);
    DECLARE @An NVARCHAR(MAX);
    DECLARE @Rn NVARCHAR(MAX);
    SELECT @En = QUOTENAME('#TSQLt_TempTable'+CAST(NEWID() AS NVARCHAR(100))),
           @An = QUOTENAME('#TSQLt_TempTable'+CAST(NEWID() AS NVARCHAR(100))),
           @Rn = QUOTENAME('#TSQLt_TempTable'+CAST(NEWID() AS NVARCHAR(100)));

    WITH TA AS (SELECT column_id,name,is_identity
                  FROM sys.columns 
                 WHERE object_id = OBJECT_ID(@Actual)
                 UNION ALL
                SELECT column_id,name,is_identity
                  FROM tempdb.sys.columns 
                 WHERE object_id = OBJECT_ID('tempdb..'+@Actual)
               ),
         TB AS (SELECT column_id,name,is_identity
                  FROM sys.columns 
                 WHERE object_id = OBJECT_ID(@Expected)
                 UNION ALL
                SELECT column_id,name,is_identity
                  FROM tempdb.sys.columns 
                 WHERE object_id = OBJECT_ID('tempdb..'+@Expected)
               ),
         T AS (SELECT TA.column_id,TA.name,
                      CASE WHEN TA.is_identity = 1 THEN 1
                           WHEN TB.is_identity = 1 THEN 1
                           ELSE 0
                      END is_identity
                 FROM TA
                 LEFT JOIN TB
                   ON TA.column_id = TB.column_id
              ),
         A AS (SELECT column_id,
                      P0 = ', '+QUOTENAME(name)+
                           CASE WHEN is_identity = 1
                                THEN '*1'
                                ELSE ''
                           END+
                         ' AS C'+CAST(column_id AS NVARCHAR),
                      P1 = CASE WHEN column_id = 1 THEN '' ELSE ' AND ' END+
                           '((A.C'+
                           CAST(column_id AS NVARCHAR)+
                           '=E.C'+
                           CAST(column_id AS NVARCHAR)+
                           ') OR (COALESCE(A.C'+ 
                           CAST(column_id AS NVARCHAR)+
                           ',E.C'+
                           CAST(column_id AS NVARCHAR)+
                           ') IS NULL))',
                      P2 = ', COALESCE(E.C'+
                           CAST(column_id AS NVARCHAR)+
                           ',A.C'+
                           CAST(column_id AS NVARCHAR)+
                           ') AS '+
                           QUOTENAME(name)
                 FROM T),
         B(m,p) AS (SELECT 0,0 UNION ALL 
                    SELECT 1,0 UNION ALL 
                    SELECT 2,1 UNION ALL 
                    SELECT 3,2),
         C(n,cmd) AS (SELECT 100+2000*B.m+column_id,
                             CASE B.p WHEN 0 THEN P0
                                      WHEN 1 THEN P1
                                      WHEN 2 THEN P2
                             END
                        FROM A
                       CROSS JOIN B),
         D(n,cmd) AS (SELECT * FROM C
                      UNION ALL
                      SELECT 1,'SELECT IDENTITY(int,1,1) no'
                      UNION ALL
                      SELECT 2001,' INTO '+@An+' FROM '+@Actual+';SELECT IDENTITY(int,1,1) no'
                      UNION ALL
                      SELECT 4001,' INTO '+@En+' FROM '+
                                  @Expected+';'+
                                  'WITH Match AS (SELECT A.no Ano, E.no Eno FROM '+@An+' A FULL OUTER JOIN '+@En+' E ON '
                      UNION ALL
                      SELECT 6001,'),MatchWithRowNo AS (SELECT Ano, Eno, r1=ROW_NUMBER() OVER(PARTITION BY Ano ORDER BY Eno), r2=ROW_NUMBER() OVER(PARTITION BY Eno ORDER BY Ano) FROM Match)'+
                                  ',CleanMatch AS (SELECT Ano,Eno FROM MatchWithRowNo WHERE r1 = r2)'+
                                  'SELECT CASE WHEN A.no IS NULL THEN ''<'' WHEN E.no IS NULL THEN ''>'' ELSE ''='' END AS _m_'
                      UNION ALL
                      SELECT 8001,' INTO '+@Rn+' FROM CleanMatch FULL JOIN '+@En+' E ON E.no = CleanMatch.Eno FULL JOIN '+@An+' A ON A.no = CleanMatch.Ano;'+
                                  ' SELECT @R = CASE WHEN EXISTS(SELECT 1 FROM '+@Rn+' WHERE _m_<>''='') THEN -1 ELSE 0 END;'+
--' SELECT * FROM '+@Rn+';'+
                                  ' EXEC tSQLt.TableToText @Txt OUTPUT,'''+@Rn+''',''_m_'';'+
--' PRINT @Txt;'+
                                  ' DROP TABLE '+@An+'; DROP TABLE '+@En+'; DROP TABLE '+@Rn+';'
                     ),
         E(xml) AS (SELECT cmd AS [data()]  FROM D ORDER BY n FOR XML PATH(''), TYPE)
    select @Cmd = xml.value( '/', 'NVARCHAR(max)' ) from E;

--    PRINT @Cmd;
    EXEC sp_executesql @Cmd, N'@R INT OUTPUT, @Txt NVARCHAR(MAX) OUTPUT', @R OUTPUT, @Txt OUTPUT;;

--    PRINT 'Outcome:'+CAST(@R AS NVARCHAR);
--    PRINT @Txt; 
    RETURN @R;
END;
GO

/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/
CREATE PROCEDURE tSQLt.AssertEqualsTable
    @Expected NVARCHAR(MAX),
    @Actual NVARCHAR(MAX),
    @FailMsg NVARCHAR(MAX) = 'unexpected/missing resultset rows!'
AS
BEGIN
    DECLARE @TblMsg NVARCHAR(MAX);
    DECLARE @R INT;
    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @FailureOccurred BIT;
    SET @FailureOccurred = 0;

    EXEC @FailureOccurred = tSQLt.AssertObjectExists @Actual;
    IF @FailureOccurred = 1 RETURN 1;
    EXEC @FailureOccurred = tSQLt.AssertObjectExists @Expected;
    IF @FailureOccurred = 1 RETURN 1;
        
    EXEC @R = tSQLt.TableCompare @Expected, @Actual, @TblMsg OUT;

    IF (@R <> 0)
    BEGIN
        IF ISNULL(@FailMsg,'')<>'' SET @FailMsg = @FailMsg + CHAR(13) + CHAR(10);
        EXEC tSQLt.Fail @FailMsg, @TblMsg;
    END;
    
END;
GO
/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/
CREATE FUNCTION tSQLt.Private_GetOriginalTableName(@SchemaName NVARCHAR(MAX), @TableName NVARCHAR(MAX)) --DELETE!!!
RETURNS NVARCHAR(MAX)
AS
BEGIN
  RETURN (SELECT CAST(value AS NVARCHAR(4000))
    FROM sys.extended_properties
   WHERE class_desc = 'OBJECT_OR_COLUMN'
     AND major_id = OBJECT_ID(@SchemaName + '.' + @TableName)
     AND minor_id = 0
     AND name = 'tSQLt.FakeTable_OrgTableName');
END;
GO

CREATE FUNCTION tSQLt.Private_GetOriginalTableInfo(@TableObjectId INT)
RETURNS TABLE
AS
  RETURN SELECT CAST(value AS NVARCHAR(4000)) OrgTableName,
                OBJECT_ID(QUOTENAME(OBJECT_SCHEMA_NAME(@TableObjectId)) + '.' + QUOTENAME(CAST(value AS NVARCHAR(4000)))) OrgTableObjectId
    FROM sys.extended_properties
   WHERE class_desc = 'OBJECT_OR_COLUMN'
     AND major_id = @TableObjectId
     AND minor_id = 0
     AND name = 'tSQLt.FakeTable_OrgTableName';
GO

CREATE FUNCTION tSQLt.Private_GetQuotedTableNameForConstraint(@ConstraintObjectId INT)
RETURNS TABLE
AS
RETURN
  SELECT QUOTENAME(SCHEMA_NAME(newtbl.schema_id)) + '.' + QUOTENAME(OBJECT_NAME(newtbl.object_id)) QuotedTableName,
         SCHEMA_NAME(newtbl.schema_id) SchemaName,
         OBJECT_NAME(newtbl.object_id) TableName,
         OBJECT_NAME(constraints.parent_object_id) OrgTableName
      FROM sys.objects AS constraints
      JOIN sys.extended_properties AS p
      JOIN sys.objects AS newtbl
        ON newtbl.object_id = p.major_id
       AND p.minor_id = 0
       AND p.class_desc = 'OBJECT_OR_COLUMN'
       AND p.name = 'tSQLt.FakeTable_OrgTableName'
        ON OBJECT_NAME(constraints.parent_object_id) = CAST(p.value AS NVARCHAR(4000))
       AND constraints.schema_id = newtbl.schema_id
       AND constraints.object_id = @ConstraintObjectId;
GO

CREATE FUNCTION tSQLt.Private_FindConstraint
(
  @TableObjectId INT,
  @ConstraintName NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
  SELECT TOP(1) constraints.object_id AS ConstraintObjectId, type_desc AS ConstraintType
    FROM sys.objects constraints
    CROSS JOIN tSQLt.Private_GetOriginalTableInfo(@TableObjectId) orgTbl
   WHERE @ConstraintName IN (constraints.name, QUOTENAME(constraints.name))
     AND constraints.parent_object_id = orgTbl.OrgTableObjectId
   ORDER BY LEN(constraints.name) ASC;
GO

CREATE FUNCTION tSQLt.Private_ResolveApplyConstraintParameters
(
  @A NVARCHAR(MAX),
  @B NVARCHAR(MAX),
  @C NVARCHAR(MAX)
)
RETURNS TABLE
AS 
RETURN
  SELECT ConstraintObjectId, ConstraintType
    FROM tSQLt.Private_FindConstraint(OBJECT_ID(@A), @B)
   WHERE @C IS NULL
   UNION ALL
  SELECT *
    FROM tSQLt.Private_FindConstraint(OBJECT_ID(@A + '.' + @B), @C)
   UNION ALL
  SELECT *
    FROM tSQLt.Private_FindConstraint(OBJECT_ID(@C + '.' + @A), @B);
GO

CREATE PROCEDURE tSQLt.Private_ApplyCheckConstraint
  @ConstraintObjectId INT
AS
BEGIN
  DECLARE @Cmd NVARCHAR(MAX);
  SELECT @Cmd = 'CONSTRAINT ' + QUOTENAME(name) + ' CHECK' + definition 
    FROM sys.check_constraints
   WHERE object_id = @ConstraintObjectId;
  
  DECLARE @QuotedTableName NVARCHAR(MAX);
  
  SELECT @QuotedTableName = QuotedTableName FROM tSQLt.Private_GetQuotedTableNameForConstraint(@ConstraintObjectId);

  EXEC tSQLt.Private_RenameObjectToUniqueNameUsingObjectId @ConstraintObjectId;
  SELECT @Cmd = 'ALTER TABLE ' + @QuotedTableName + ' ADD ' + @Cmd
    FROM sys.objects 
   WHERE object_id = @ConstraintObjectId;

  EXEC (@Cmd);

END; 
GO

CREATE PROCEDURE tSQLt.Private_ApplyForeignKeyConstraint 
  @ConstraintObjectId INT
AS
BEGIN
  DECLARE @SchemaName NVARCHAR(MAX);
  DECLARE @OrgTableName NVARCHAR(MAX);
  DECLARE @TableName NVARCHAR(MAX);
  DECLARE @ConstraintName NVARCHAR(MAX);
  DECLARE @CreateFkCmd NVARCHAR(MAX);
  DECLARE @AlterTableCmd NVARCHAR(MAX);
  DECLARE @CreateIndexCmd NVARCHAR(MAX);
  DECLARE @FinalCmd NVARCHAR(MAX);
  
  SELECT @SchemaName = SchemaName,
         @OrgTableName = OrgTableName,
         @TableName = TableName,
         @ConstraintName = OBJECT_NAME(@ConstraintObjectId)
    FROM tSQLt.Private_GetQuotedTableNameForConstraint(@ConstraintObjectId);
      
  SELECT @CreateFkCmd = cmd, @CreateIndexCmd = CreIdxCmd
    FROM tSQLt.Private_GetForeignKeyDefinition(@SchemaName, @OrgTableName, @ConstraintName);
  SELECT @AlterTableCmd = 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + 
                          ' ADD ' + @CreateFkCmd;
  SELECT @FinalCmd = @CreateIndexCmd + @AlterTableCmd;

  EXEC tSQLt.Private_RenameObjectToUniqueName @SchemaName, @ConstraintName;
  EXEC (@FinalCmd);
END;
GO

CREATE FUNCTION tSQLt.Private_GetConstraintType(@TableObjectId INT, @ConstraintName NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
  SELECT object_id,type,type_desc
    FROM sys.objects 
   WHERE object_id = OBJECT_ID(SCHEMA_NAME(schema_id)+'.'+@ConstraintName)
     AND parent_object_id = @TableObjectId;
GO

CREATE PROCEDURE tSQLt.ApplyConstraint
       @TableName NVARCHAR(MAX),
       @ConstraintName NVARCHAR(MAX),
       @SchemaName NVARCHAR(MAX) = NULL --parameter preserved for backward compatibility. Do not use. Will be removed soon.
AS
BEGIN
  DECLARE @ConstraintType NVARCHAR(MAX);
  DECLARE @ConstraintObjectId INT;
  
  SELECT @ConstraintType = ConstraintType, @ConstraintObjectId = ConstraintObjectId
    FROM tSQLt.Private_ResolveApplyConstraintParameters (@TableName, @ConstraintName, @SchemaName);

  IF @ConstraintType = 'CHECK_CONSTRAINT'
  BEGIN
    EXEC tSQLt.Private_ApplyCheckConstraint @ConstraintObjectId;
    RETURN 0;
  END

  IF @ConstraintType = 'FOREIGN_KEY_CONSTRAINT'
  BEGIN
    EXEC tSQLt.Private_ApplyForeignKeyConstraint @ConstraintObjectId;
    RETURN 0;
  END;  
   
  RAISERROR ('ApplyConstraint could not resolve the object names, ''%s'', ''%s''. Be sure to call ApplyConstraint and pass in two parameters, such as: EXEC tSQLt.ApplyConstraint ''MySchema.MyTable'', ''MyConstraint''', 
             16, 10, @TableName, @ConstraintName);
  RETURN 0;
END;
GO


CREATE FUNCTION [tSQLt].[F_Num](
       @N INT
)
RETURNS TABLE 
AS 
RETURN WITH C0(c) AS (SELECT 1 UNION ALL SELECT 1),
            C1(c) AS (SELECT 1 FROM C0 AS A CROSS JOIN C0 AS B),
            C2(c) AS (SELECT 1 FROM C1 AS A CROSS JOIN C1 AS B),
            C3(c) AS (SELECT 1 FROM C2 AS A CROSS JOIN C2 AS B),
            C4(c) AS (SELECT 1 FROM C3 AS A CROSS JOIN C3 AS B),
            C5(c) AS (SELECT 1 FROM C4 AS A CROSS JOIN C4 AS B),
            C6(c) AS (SELECT 1 FROM C5 AS A CROSS JOIN C5 AS B)
       SELECT TOP(CASE WHEN @N>0 THEN @N ELSE 0 END) ROW_NUMBER() OVER (ORDER BY c) no
         FROM C6;
GO

CREATE PROCEDURE [tSQLt].[Private_SetFakeViewOn_SingleView]
  @ViewName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Cmd NVARCHAR(MAX),
          @SchemaName NVARCHAR(MAX),
          @TriggerName NVARCHAR(MAX);
          
  SELECT @SchemaName = OBJECT_SCHEMA_NAME(ObjId),
         @ViewName = OBJECT_NAME(ObjId),
         @TriggerName = OBJECT_NAME(ObjId) + '_SetFakeViewOn'
    FROM (SELECT OBJECT_ID(@ViewName) AS ObjId) X;

  SET @Cmd = 
     'CREATE TRIGGER $$SCHEMA_NAME$$.$$TRIGGER_NAME$$
      ON $$SCHEMA_NAME$$.$$VIEW_NAME$$ INSTEAD OF INSERT AS
      BEGIN
         RAISERROR(''Test system is in an invalid state. SetFakeViewOff must be called if SetFakeViewOn was called. Call SetFakeViewOff after creating all test case procedures.'', 16, 10) WITH NOWAIT;
         RETURN;
      END;
     ';
      
  SET @Cmd = REPLACE(@Cmd, '$$SCHEMA_NAME$$', QUOTENAME(@SchemaName));
  SET @Cmd = REPLACE(@Cmd, '$$VIEW_NAME$$', QUOTENAME(@ViewName));
  SET @Cmd = REPLACE(@Cmd, '$$TRIGGER_NAME$$', QUOTENAME(@TriggerName));
  EXEC(@Cmd);

  EXEC sp_addextendedproperty @name = N'SetFakeViewOnTrigger', 
                               @value = 1,
                               @level0type = 'SCHEMA',
                               @level0name = @SchemaName, 
                               @level1type = 'VIEW',
                               @level1name = @ViewName,
                               @level2type = 'TRIGGER',
                               @level2name = @TriggerName;

  RETURN 0;
END;
GO

CREATE PROCEDURE [tSQLt].[SetFakeViewOn]
  @SchemaName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @ViewName NVARCHAR(MAX);
    
  DECLARE viewNames CURSOR LOCAL FAST_FORWARD FOR
  SELECT QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) + '.' + QUOTENAME([name]) AS viewName
    FROM sys.objects
   WHERE type = 'V'
     AND schema_id = SCHEMA_ID(@SchemaName);
  
  OPEN viewNames;
  
  FETCH NEXT FROM viewNames INTO @ViewName;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC tSQLt.Private_SetFakeViewOn_SingleView @ViewName;
    
    FETCH NEXT FROM viewNames INTO @ViewName;
  END;
  
  CLOSE viewNames;
  DEALLOCATE viewNames;
END;
GO

CREATE PROCEDURE [tSQLt].[SetFakeViewOff]
  @SchemaName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @ViewName NVARCHAR(MAX);
    
  DECLARE viewNames CURSOR LOCAL FAST_FORWARD FOR
   SELECT QUOTENAME(OBJECT_SCHEMA_NAME(t.parent_id)) + '.' + QUOTENAME(OBJECT_NAME(t.parent_id)) AS viewName
     FROM sys.extended_properties ep
     JOIN sys.triggers t
       on ep.major_id = t.object_id
     WHERE ep.name = N'SetFakeViewOnTrigger'  
  OPEN viewNames;
  
  FETCH NEXT FROM viewNames INTO @ViewName;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC tSQLt.Private_SetFakeViewOff_SingleView @ViewName;
    
    FETCH NEXT FROM viewNames INTO @ViewName;
  END;
  
  CLOSE viewNames;
  DEALLOCATE viewNames;
END;
GO

CREATE PROCEDURE [tSQLt].[Private_SetFakeViewOff_SingleView]
  @ViewName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Cmd NVARCHAR(MAX),
          @SchemaName NVARCHAR(MAX),
          @TriggerName NVARCHAR(MAX);
          
  SELECT @SchemaName = QUOTENAME(OBJECT_SCHEMA_NAME(ObjId)),
         @TriggerName = QUOTENAME(OBJECT_NAME(ObjId) + '_SetFakeViewOn')
    FROM (SELECT OBJECT_ID(@ViewName) AS ObjId) X;
  
  SET @Cmd = 'DROP TRIGGER %SCHEMA_NAME%.%TRIGGER_NAME%;';
      
  SET @Cmd = REPLACE(@Cmd, '%SCHEMA_NAME%', @SchemaName);
  SET @Cmd = REPLACE(@Cmd, '%TRIGGER_NAME%', @TriggerName);
  
  EXEC(@Cmd);
END;
GO

CREATE FUNCTION tSQLt.Private_GetQuotedFullName(@Objectid INT)
RETURNS NVARCHAR(517)
AS
BEGIN
    DECLARE @QuotedName NVARCHAR(517);
    SELECT @QuotedName = QUOTENAME(OBJECT_SCHEMA_NAME(@Objectid)) + '.' + QUOTENAME(OBJECT_NAME(@Objectid));
    RETURN @QuotedName;
END;
GO

CREATE FUNCTION tSQLt.Private_GetSchemaId(@SchemaName NVARCHAR(MAX))
RETURNS INT
AS
BEGIN
  RETURN (
    SELECT TOP(1) schema_id
      FROM sys.schemas
     WHERE @SchemaName IN (name, QUOTENAME(name), QUOTENAME(name, '"'))
     ORDER BY 
        CASE WHEN name = @SchemaName THEN 0 ELSE 1 END
  );
END;
GO

CREATE FUNCTION tSQLt.Private_IsTestClass(@TestClassName NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
  RETURN 
    CASE 
      WHEN EXISTS(
             SELECT 1 
               FROM tSQLt.TestClasses
              WHERE SchemaId = tSQLt.Private_GetSchemaId(@TestClassName)
            )
      THEN 1
      ELSE 0
    END;
END;
GO

CREATE FUNCTION tSQLt.Private_ResolveSchemaName(@Name NVARCHAR(MAX))
RETURNS TABLE 
AS
RETURN
  WITH ids(schemaId) AS
       (SELECT tSQLt.Private_GetSchemaId(@Name)
       ),
       idsWithNames(schemaId, quotedSchemaName) AS
        (SELECT schemaId,
         QUOTENAME(SCHEMA_NAME(schemaId))
         FROM ids
        )
  SELECT schemaId, 
         quotedSchemaName,
         CASE WHEN EXISTS(SELECT 1 FROM tSQLt.TestClasses WHERE TestClasses.SchemaId = idsWithNames.schemaId)
               THEN 1
              ELSE 0
         END AS isTestClass, 
         CASE WHEN schemaId IS NOT NULL THEN 1 ELSE 0 END AS isSchema
    FROM idsWithNames;
GO

CREATE FUNCTION tSQLt.Private_ResolveObjectName(@Name NVARCHAR(MAX))
RETURNS TABLE 
AS
RETURN
  WITH ids(schemaId, objectId) AS
       (SELECT SCHEMA_ID(OBJECT_SCHEMA_NAME(OBJECT_ID(@Name))),
               OBJECT_ID(@Name)
       ),
       idsWithNames(schemaId, objectId, quotedSchemaName, quotedObjectName) AS
        (SELECT schemaId, objectId,
         QUOTENAME(SCHEMA_NAME(schemaId)) AS quotedSchemaName, 
         QUOTENAME(OBJECT_NAME(objectId)) AS quotedObjectName
         FROM ids
        )
  SELECT schemaId, 
         objectId, 
         quotedSchemaName,
         quotedObjectName,
         quotedSchemaName + '.' + quotedObjectName AS quotedFullName, 
         CASE WHEN LOWER(quotedObjectName) LIKE '[[]test%]' 
               AND objectId = OBJECT_ID(quotedSchemaName + '.' + quotedObjectName,'P') 
              THEN 1 ELSE 0 END AS isTestCase
    FROM idsWithNames;
    
GO

CREATE FUNCTION tSQLt.Private_ResolveName(@Name NVARCHAR(MAX))
RETURNS TABLE 
AS
RETURN
  WITH resolvedNames(ord, schemaId, objectId, quotedSchemaName, quotedObjectName, quotedFullName, isTestClass, isTestCase, isSchema) AS
  (SELECT 1, schemaId, NULL, quotedSchemaName, NULL, quotedSchemaName, isTestClass, 0, 1
     FROM tSQLt.Private_ResolveSchemaName(@Name)
    UNION ALL
   SELECT 2, schemaId, objectId, quotedSchemaName, quotedObjectName, quotedFullName, 0, isTestCase, 0
     FROM tSQLt.Private_ResolveObjectName(@Name)
    UNION ALL
   SELECT 3, NULL, NULL, NULL, NULL, NULL, 0, 0, 0
   )
   SELECT TOP(1) schemaId, objectId, quotedSchemaName, quotedObjectName, quotedFullName, isTestClass, isTestCase, isSchema
     FROM resolvedNames
    WHERE schemaId IS NOT NULL 
       OR ord = 3
    ORDER BY ord
GO

CREATE PROCEDURE tSQLt.Uninstall
AS
BEGIN
  DROP TYPE tSQLt.Private;

  EXEC tSQLt.DropClass 'tSQLt';  
  
  DROP ASSEMBLY tSQLtCLR;
END;
GO


GO

IF OBJECT_ID('tSQLt.CaptureOutputLog') IS NOT NULL DROP TABLE tSQLt.CaptureOutputLog;
---Build+
CREATE TABLE tSQLt.CaptureOutputLog (
  Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
  OutputText NVARCHAR(MAX)
);
---Build-


GO

IF OBJECT_ID('tSQLt.LogCapturedOutput') IS NOT NULL DROP PROCEDURE tSQLt.LogCapturedOutput;
GO
---Build+
CREATE PROCEDURE tSQLt.LogCapturedOutput @text NVARCHAR(MAX)
AS
BEGIN
  INSERT INTO tSQLt.CaptureOutputLog (OutputText) VALUES (@text);
END;
---Build-

GO

CREATE ASSEMBLY [tSQLtCLR]
AUTHORIZATION [dbo]
FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C0103009813A04F0000000000000000E00002210B0108000042000000060000000000005E60000000200000008000000000400000200000000200000400000000000000040000000000000000C0000000020000792201000300408500001000001000000000100000100000000000001000000000000000000000000C6000004F00000000800000E80300000000000000000000000000000000000000A000000C000000585F00001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E7465787400000064400000002000000042000000020000000000000000000000000000200000602E72737263000000E8030000008000000004000000440000000000000000000000000000400000402E72656C6F6300000C00000000A00000000200000048000000000000000000000000000040000042000000000000000000000000000000004060000000000000480000000200050094320000C42C000009000000000000000000000000000000502000008000000000000000000000000000000000000000000000000000000000000000000000004CA35AF114B2CC9FBA7EE28B74782EFAC7474309267252CBCB9A69CB3F40ED6C11CFA45E2AD23EE1AA1A5DC0794F72CC0AC9A91BD66EAA3B748903B95FF8F3ED019789AB912EBD27650B4BB565F7DC1AB9A5E6057B80FC5B3E85927CFE6911852C30F8ED461020C84E6DB6AA1E6D9C0F7F5065FE12DCD821F7978D083A62CB991B3003006D00000001000011140A18730F00000A0B28020000060C08731000000A0A066F1100000A731200000A0D09066F1300000A090F01FE16070000016F1400000A6F1500000A096F1600000A26DE0A072C06076F1700000ADCDE0F13047201000070110473060000067ADE0A062C06066F1800000ADC2A00000001280000020009003C45000A00000000000002004F51000F30000001020002006062000A00000000133003004E0000000200001173390000060A066F3E0000060B066F3F0000060C731900000A0D0972B6000070076F1A00000A0972CE000070178C330000016F1A00000A0972F6000070086F1A00000A096F1B00000A130411042A1E02281C00000A2A1E02281E00000A2A220203281F00000A2A26020304282000000A2A26020304282100000A2A3A02281C00000A02037D010000042A7A0203280B000006027B01000004027B010000046F3B0000066F440000062A220203280B0000062A0000133002001400000003000011027B01000004036F400000060A066F2200000A2A6A282500000A6F2600000A6F2700000A6F1400000A282800000A2A001330040032000000040000117216010070282A00000A0A1200FE163E0000016F1400000A723A010070723E0100706F2B00000A282C00000A282800000A2A00001B30050015020000050000110F00282D00000A2C0B7240010070731F00000A7A0F01282D00000A2C0C723E010070282800000A100173390000060A0F000F0128110000060B0607282800000A6F400000060C0828120000060D16130409166F2E00000A8E698D400000011305096F2F00000A13102B3B1210283000000A13061613072B1F110511071105110794110611079A6F3100000A283200000A9E110717581307110711068E6932D91104175813041210283300000A2DBCDE0E1210FE160200001B6F1700000ADC1613082B1A110511081105110894209B000000283400000A9E110817581308110811058E6932DE161309110513111613122B161111111294130A110917110A58581309111217581312111211118E6932E21109175813091109110417585A130917130B1109733500000A130C096F2F00000A131338B00000001213283000000A130D110B2D08110C6F3600000A2616130E2B2C110C72760100706F3700000A110D110E9A28100000061105110E94280F0000066F3700000A26110E1758130E110E110D8E6932CC110C72760100706F3700000A26110B2C5116130B110C6F3600000A2616130F2B2C110C727A0100706F3700000A26110C110C6F3800000A723A0100701105110F946F3900000A26110F1758130F110F110D8E6932CC110C727A0100706F3700000A261213283300000A3A44FFFFFFDE0E1213FE160200001B6F1700000ADC110C6F1400000A282800000A733A00000A2A000000011C00000200680048B0000E0000000002003201C3F5010E000000009202733B00000A16727E01007003026F3100000A59283900000A6F1400000A282C00000A2AD2026F3100000A209B000000312502161F4B6F3C00000A728201007002026F3100000A1F4B591F4B6F3C00000A283D00000A2A022A0000133003004500000006000011728E01007002FE16070000016F1400000A282C00000A0A03FE16070000016F1400000A6F3100000A1631180672AC01007003FE16070000016F1400000A283D00000A0A062A000000133004001802000007000011026F3E00000A0A733F00000A0B066F4000000A6F4100000A0C088D3F0000010D1613042B2A066F4000000A11046F4200000A1305091104110572C20100706F4300000A6F1400000AA211041758130411040832D107096F4400000A38AB010000088D3F000001130616130738860100000211076F4500000A2C0F1106110772D8010070A23867010000066F4000000A11076F4200000A72E60100706F4300000AA54600000113081108130911091F0F302411091A59450400000078000000BC000000DA0000000001000011091F0F2E56380901000011091F13594503000000DF000000F3000000DF00000011091F1F59450400000005000000D9000000590000006D00000038D4000000110611070211076F4600000A284700000A2813000006A238CA000000110611070211076F4600000A284700000A2815000006A238AE000000110611070211076F4600000A284700000A2814000006A23892000000110611070211076F4600000A2816000006A22B7E110611070211076F4800000A2817000006A22B6A110611070211076F4900000A130A120AFE16470000016F1400000AA22B4C110611070211076F4A00000A130B120B284B00000A130C120C7200020070284C00000AA22B26110611070211076F4D00000A2818000006A22B12110611070211076F4E00000A6F1400000AA21107175813071107026F4F00000A3F6DFEFFFF0711066F4400000A026F5000000A3A4AFEFFFF072A5E722A0200700F00285100000A8C0E000001285200000A2A5E72480200700F00285100000A8C0E000001285200000A2A5E72800200700F00285100000A8C0E000001285200000A2A7272AA0200700F00285300000A735400000A8C0E000001285200000A2A4672EA020070028C0F000001285200000A2A00133003004400000008000011733B00000A7232030070283700000A0A0F00285500000A0C160D2B1B0809910B0612017238030070285600000A6F3700000A260917580D09088E6932DF066F1400000A2A2E723E030070731F00000A7A2E723E030070731F00000A7A2E723E030070731F00000A7A2E723E030070731F00000A7A1A735700000A7A1A735700000A7A1E02281E00000A2A220203281F00000A2A26020304282000000A2A26020304282100000A2A3A02281C00000A02037D040000042A00001B3003003400000009000011020328250000060A020428250000060B027B0400000406076F42000006DE140C027B04000004086F5800000A6F43000006DE002A01100000000000001F1F0014060000021B300200370000000A000011140A027B04000004036F400000060A066F5000000A26030628270000060B030728280000060728290000060CDE07062826000006DC082A0001100000020002002C2E0007000000002A022C06026F2200000A2A001B3003002F0000000B000011036F3E00000A0BDE240A72B20300700F00FE16070000016F1400000A72CE030070283D00000A0673210000067A072A00011000000000000009090024020000019A032D2272B20300700F00FE16070000016F1400000A7216040070283D00000A73200000067A2A001B3004000F0100000C000011723E0100700A026F4000000A6F5900000A0D38D5000000096F5A00000A74190000010B0772520400706F4300000A6F1400000A7264040070285B00000A39AA00000006726E040070282C00000A0A026F5C00000A6F5900000A13042B6311046F5A00000A74140000010C08282A0000062C4E0613051C8D0100000113061106161105A21106177272040070A2110618086F5D00000AA21106197276040070A211061A07086F5D00000A6F4300000AA211061B727A040070A21106285E00000A0A11046F5F00000A2D94DE1511047506000001130711072C0711076F1700000ADC06727E040070282C00000A0A096F5F00000A3A20FFFFFFDE14097506000001130811082C0711086F1700000ADC062A00011C000002005B0070CB00150000000002001200E7F9001400000000AA026F5D00000A72820400701B6F6000000A2D15026F5D00000A72880400701B6F6000000A16FE012A162A3A02281C00000A02037D050000042A000013300300A50000000D0000110203282D000006027B05000004046F400000060A160B066F4F00000A1631270717580B07286100000A03286200000A286300000A2C0806282E0000062B08066F6400000A2DD9066F2200000A07286100000A03286500000A286300000A2C451B8D3F0000010C08167292040070A208171201286600000AA2081872C4040070A208190F01FE16150000016F1400000AA2081A72F6040070A208286700000A73200000067A2A000000033003004F000000000000000316286100000A286500000A25286300000A2D110F01286800000A286900000A286A00000A286300000A2C22721A0500700F01FE16150000016F1400000A7278050070283D00000A73200000067A2A0013300300290000000E0000110228310000060A286B00000A06736C00000A6F6D00000A0206282F000006286B00000A6F6E00000A2A722B11286B00000A020328300000066F6F00000A026F5000000A2DE72A000013300200250000000F00001103736C00000A0A026F4F00000A8D010000010B02076F7000000A2606076F7100000A26062A0000001B3003005800000010000011026F3E00000A0A0628320000060B076F7200000A8D160000010C160D076F7300000A13052B171205287400000A1304080911042833000006A20917580D1205287500000A2DE0DE0E1205FE160400001B6F1700000ADC082A01100000020024002448000E000000001B3002006600000011000011737600000A0A026F4000000A6F5900000A0C2B35086F5A00000A74190000010B0772520400706F4300000A6F1400000A6F7700000A7294050070285B00000A2C0806076F7800000A26086F5F00000A2DC3DE110875060000010D092C06096F1700000ADC062A000001100000020012004153001100000000133005006F010000120000110272E60100706F4300000AA5460000010A0272C20100706F4300000A743F0000010B02729E0500706F4300000A74540000010C06130411044523000000050000000D000000050000000D000000050000004B000000050000000500000005000000050000000D0000000500000026000000050000000500000005000000050000000500000005000000050000000500000026000000260000000500000086000000050000008600000086000000860000007D0000008600000005000000050000004B0000004B00000038810000000706737900000A2A07060272B00500706F4300000AA5400000016A737A00000A2A0272B00500706F4300000AA5400000010D0920FF7F00003102150D0706096A737A00000A2A07060272C60500706F4300000A287B00000A287C00000A0272E80500706F4300000A287B00000A287C00000A737D00000A2A070608737E00000A2A7202060070068C460000016F1400000A7218060070283D00000A737F00000A7A00133003001400000013000011733900000673230000060A0602036F240000062A1330030014000000140000117339000006732B0000060A0602036F2C0000062A133002000E0000001500001173030000060A06026F010000062A0000133002001300000016000011733900000673080000060A06026F090000062A00133002001300000016000011733900000673080000060A06026F0A0000062A3602281C00000A02283C0000062A72027B080000042D0D02283D00000602177D0800000402288000000A2A1E027B070000042A9E02738100000A7D06000004027B0600000472600600706F8200000A027B060000046F1100000A2A32027B060000046F8300000A2A00133002002800000017000011027292060070282800000A28400000060A066F5000000A2606166F8400000A0B066F2200000A072A32027B060000046F8500000A2A000000133004005100000018000011027E8600000A7D07000004027B0600000402FE0641000006738700000A6F8800000A731200000A0A06027B060000046F1300000A060F01FE16070000016F1400000A6F1500000A061A6F8900000A0B072A000000033004004400000000000000027C07000004282D00000A2C1002723E010070282800000A7D0700000402257B07000004046F8A00000A72DC060070282C00000A282800000A288B00000A7D070000042A133003005000000019000011731200000A0A06027B060000046F1300000A0672E20600706F1500000A066F8C00000A7214070070036F8D00000A26066F8C00000A7226070070046F8D00000A26061A6F8E00000A066F1600000A262A133003003E00000019000011731200000A0A06027B060000046F1300000A0672340700706F1500000A066F8C00000A724A070070036F8D00000A26061A6F8E00000A066F1600000A262A0000133003004300000019000011731200000A0A06027B060000046F1300000A06725C0700706F1500000A066F8C00000A728C070070038C070000016F8D00000A26061A6F8E00000A066F1600000A262A0042534A4201000100000000000C00000076322E302E35303732370000000005006C0000006C0D0000237E0000D80D00008010000023537472696E677300000000581E00009807000023555300F025000010000000234755494400000000260000C406000023426C6F620000000000000002000001579FA2090900000000FA013300160000010000005F0000000A000000080000004400000045000000030000008E000000020000000F000000010000001900000002000000050000000500000004000000010000000400000000000A000100000000000600DA00D3000600E100D3000600EB00D3000A00160101010A003B01200106004C01D3000A00580101010600B50198010600C70198010A005A0201010600B6029B020A00D302BD020A00F502010106003B03D30006005903D3000A00820301010600CB03C1030600DD03C1030A004704F5000A009904F5000A00CF0401010A00270520010A00480520010E008F059B020A009C05F5000A00EF05BD020A007706BD0206001007FE0606002907D30006005E073F0706007207FE0606008B07FE060600A607FE060600C107FE060600DA07FE060600F307FE0606001208FE0606002F08FE060600590846089F006D08000006009C087C080600BC087C081200F608E20812000709E2080A0031091E090A004309BD020A005D091E0906009D098D090A00AF09BD020A00CA091E090600ED09D30006000A0AD3000A00440A1E090A00510A20010A006D0A20010600740A3F0706008A0A3F070600950AFE060600B30AFE060600C80AD3000A00E80A20010600FB0AD3000600080BD30006003D0BD3002F00430B00000600730BD3000600950B890B0A00F10BF5000A000C0CF5000A003E0CF5000A00660C01010A007F0C01010600A00CD3000600F10CD3000600F80CD3000600560D430D0A00700DF5000600A70DD3000A00CF0D01010A001D0E20010A00280E20016300430B00000E008C0E9B020600B30ED3000600CD0EB80E0600EE0ED3000600F60ED30006000D0FD30006002B0FD3000E006A0F540F0A00930FBD020A00BE0FF5000A001010BD020A003610BD020A005010F500000000000100000000000100010000001000170027000500010001000120100030002700090001000400000010004900270005000100080009011000560027000D0002000C000120100063002700090004001F00000010007D0027000500040023000000100096002700050005002B0081011000A600270005000600340000001000B70027000500060039000100D8012C0051802102360051802D0246000100D8012C000100D8012C000100FD053F01010008064301010014064701D02000000000860062010A00010074210000000091006A0110000200CE21000000008618920114000200D621000000008618920114000200DE21000000008618920118000200E72100000000861892011D000300F121000000008418920124000500FB210000000086189201300007000A22000000008300EB010A000800292200000000830003020A000900342200000000830012020A000A0054220000000096003E024E000B00702200000000960043024E000B00B022000000009600630253000B00F02400000000910071025C000D0015250000000091007B0262000F004C250000000091008B0267001000A025000000009100E10271001200C42700000000910001037C001300DC2700000000910011037C001400F42700000000910025037C0015000C2800000000910044038200160029280000000091006803880017003C280000000091008C038E0018008C280000000096089E0394001900982800000000E609A70399001900A428000000009600B2039D001900B02800000000C600B803A4001A00BC2800000000E601D803A8001A00C32800000000E601EA03AE001B00CA28000000008618920114001C00D228000000008618920118001C00DB2800000000861892011D001D00E528000000008418920124001F00EF280000000086189201300021000029000000008600FC03BD00220050290000000081001D04C5002400A4290000000091003B04CB002500B0290000000091005104D1002600FC290000000091006904DA002800242A0000000091008704E2002A005C2B000000009100A404E8002B00872B000000008618920130002C00982B000000008600D804EE002D004C2C000000008100FA04F6002F00A82C0000000091001205CB003000DD2C0000000091003305FC003100FC2C000000009100560505013300302D00000000910074050F013500A42D000000009100A40517013600282E000000009100B80522013700A42F000000009600FC0329013800C42F000000009600960031013A00E42F000000009600D30539013C000030000000009600E10539013D002030000000009600030239013E003F30000000008618920114003F004D3000000000E6011D0614003F006A3000000000860825064A013F007230000000008100350614003F009A300000000081003D0614003F00A8300000000086084806A4003F00DC300000000086085706A4003F00EC3000000000860068064F013F004C310000000084008F06560140009C310000000086009D065D014200F831000000008600AA06180044004432000000008600C8060A00450000000100DA0800000100200A00000100200A00000200280A00000100370A000002003C0A00000100D80100000100DA0800000100DA0800000100DA08000001001E0B00000200280B00000100BC0B00000200C20B00000100C90B000001001E0B00000200280B00000100DB0B00000100CC0C00000100CC0C00000100CC0C00000100CC0C00000100DE0C00000100E70C00000100BC0B00000100F60C00000100100D00000100200A00000100200A00000200280A00000100370A000002003C0A00000100D80100000100120D00000200220D00000100DA0800000100DB0B00000100DA0800000200DB0B00000100DA08000002003C0D000001003C0D00000100A00D00000100D80100000100C30D00000200DA0800000100C30D00000100120E00000100120E00000200590E00000100120E00000200590E00000100120E000001003C0D00000100A50E00000100120D00000200220D000001001F0F00000200DA0800000100DA0800000100DA0800000100DA08000001008B0F00000100DC0F00000200E30F00000100F40F000002000310000001006C10000001007B1005001100050015000A001900E10092011800E90092016C01F10092016C01F90092011800010192011800090192011800110192011800190192011800210192011800290192011800310192011800390192017101490192017801510192011400590192011F02D1009201180069013E09140071019201140071014E0926020900B803A400790167091800790177092C0231001D0614006901870914008901920114009101E4093F029101F509A400090092011400A10192011400110092011400110092011800110092011D00110092012400A90187091400B10192015502C10192018802D1019E0A8F02D101C00A9502D901D00A9B023900DC0AA102E90192011400F101000B3803F9010F0B3E03F901170B44033900A70399000C00340B57030C004E0B5D0314005C0B6F03F901680B2C021102780B740314007C0B99001102850B74031902920178011902A30B7A031902AE0B80031902680B2C021902B50B8703510092010A00190292011400F901D10BC003F901170BC603A901E20BD1030C00920114009900030CD6032902270C2C022102340BDC03C900340BE2030C00310CE703A901350CED03A901480CF2036900DC0AF8036100540CFF036100710C05046100890C0C044102960C13044902B80317046100A70C1C04A901B40C2204A901BD0C2C02A901D80399006900960C4804F9016D0A4D047100D40C53047100920157048100960C5C045102B80317045902920114001100300DA40029024E0B810461025C0B8704F901620D8B049900850D9104A100910DA400F901170B970461027C0B9900F901B80DB204A900DC0ABA04A900DA0DC0047902E60DCA04A901EE0D9900A900F90DC0040102B803A400F901170BD104A900A70399007902DC0ADF047902050EE6048102300EF204B9009201F8048902390EFF0489024A0E140089025E0EFF0461006D0E0B05B9007A0E0B051C00270C2C021C004E0B1F0524005C0B6F0324007C0B99001C0092011400F901840EA4001C009D0E4905B10092016505B10092016D05A902D90E7605B102060F7C05B10092018405B10092018E05C10292011800C9022E0FBB05D1009201140069013F0F1800D1021D061400A901740FC00569017E0FA4003900F0034301D9029201CB05D100AE0FD1057101CE0FD805D900300DA4003900E80FE80571012710F105E9024310F70579015C10FF050E000800390008000C0049002E003B003A062E007300A4062E0013000C062E001B0012062E002B0012062E00330018062E00430045062E004B0012062E00530055062E005B0084062E00630092062E006B009B06A3001B015C02A0014B01A702C0014B01A70200000100000005003002450250024A039003CD03270461046B0472047A049D04D70405051105310555059905A705AC05B105B605C505E0050606050001000A0003000000F003B4000000F503B9000000DA0663010000E60668010000F106680102001900030002001A00050002003B00070002003E00090002003F000B00500367031805290504800000010000009811E452010000007D01270000000200000000000000000000000100CA00000000000200000000000000000000000100F500000000000200000000000000000000000100D300000000000200000000000000000000000100E2080000000000000000003C4D6F64756C653E007453514C74434C522E646C6C00436F6D6D616E644578656375746F72007453514C74434C5200436F6D6D616E644578656375746F72457863657074696F6E004F7574707574436170746F72007453514C745072697661746500496E76616C6964526573756C74536574457863657074696F6E004D65746144617461457175616C697479417373657274657200526573756C7453657446696C7465720053746F72656450726F6365647572657300546573744461746162617365466163616465006D73636F726C69620053797374656D004F626A65637400457863657074696F6E0056616C7565547970650053797374656D2E446174610053797374656D2E446174612E53716C547970657300494E756C6C61626C65004D6963726F736F66742E53716C5365727665722E536572766572004942696E61727953657269616C697A650049446973706F7361626C650053716C537472696E67004578656375746500437265617465436F6E6E656374696F6E537472696E67546F436F6E746578744461746162617365002E63746F720053797374656D2E52756E74696D652E53657269616C697A6174696F6E0053657269616C697A6174696F6E496E666F0053747265616D696E67436F6E746578740074657374446174616261736546616361646500436170747572654F7574707574546F4C6F675461626C650053757070726573734F75747075740045786563757465436F6D6D616E64004E554C4C5F535452494E47004D41585F434F4C554D4E5F574944544800496E666F00437265617465556E697175654F626A6563744E616D650053716C4368617273005461626C65546F537472696E6700506164436F6C756D6E005472696D546F4D61784C656E6774680067657453716C53746174656D656E740053797374656D2E436F6C6C656374696F6E732E47656E65726963004C69737460310053797374656D2E446174612E53716C436C69656E740053716C44617461526561646572006765745461626C65537472696E6741727261790053716C4461746554696D650053716C44617465546F537472696E670053716C4461746554696D65546F537472696E6700536D616C6C4461746554696D65546F537472696E67004461746554696D650053716C4461746554696D6532546F537472696E67004461746554696D654F66667365740053716C4461746554696D654F6666736574546F537472696E670053716C42696E6172790053716C42696E617279546F537472696E67006765745F4E756C6C006765745F49734E756C6C00506172736500546F537472696E670053797374656D2E494F0042696E61727952656164657200526561640042696E617279577269746572005772697465004E756C6C0049734E756C6C00417373657274526573756C74536574734861766553616D654D6574614461746100637265617465536368656D61537472696E6746726F6D436F6D6D616E6400636C6F736552656164657200446174615461626C6500617474656D7074546F476574536368656D615461626C65007468726F77457863657074696F6E4966536368656D614973456D707479006275696C64536368656D61537472696E670044617461436F6C756D6E00636F6C756D6E50726F7065727479497356616C6964466F724D65746144617461436F6D70617269736F6E0053716C496E7433320073656E6453656C6563746564526573756C74536574546F53716C436F6E746578740076616C6964617465526573756C745365744E756D6265720073656E64526573756C747365745265636F7264730053716C4D657461446174610073656E64456163685265636F72644F66446174610053716C446174615265636F7264006372656174655265636F7264506F70756C617465645769746844617461006372656174654D65746144617461466F72526573756C74736574004C696E6B65644C69737460310044617461526F7700676574446973706C61796564436F6C756D6E730063726561746553716C4D65746144617461466F72436F6C756D6E004E6577436F6E6E656374696F6E00436170747572654F75747075740053716C436F6E6E656374696F6E00636F6E6E656374696F6E00696E666F4D65737361676500646973706F73656400446973706F7365006765745F496E666F4D65737361676500636F6E6E65637400646973636F6E6E656374006765745F5365727665724E616D65006765745F44617461626173654E616D650065786563757465436F6D6D616E640053716C496E666F4D6573736167654576656E7441726773004F6E496E666F4D65737361676500617373657274457175616C73006661696C5465737443617365416E645468726F77457863657074696F6E006C6F6743617074757265644F757470757400496E666F4D657373616765005365727665724E616D650044617461626173654E616D650053797374656D2E5265666C656374696F6E00417373656D626C7956657273696F6E41747472696275746500434C53436F6D706C69616E744174747269627574650053797374656D2E52756E74696D652E496E7465726F70536572766963657300436F6D56697369626C6541747472696275746500417373656D626C7943756C7475726541747472696275746500417373656D626C7954726164656D61726B41747472696275746500417373656D626C79436F7079726967687441747472696275746500417373656D626C7950726F6475637441747472696275746500417373656D626C79436F6D70616E7941747472696275746500417373656D626C79436F6E66696775726174696F6E41747472696275746500417373656D626C794465736372697074696F6E41747472696275746500417373656D626C795469746C654174747269627574650053797374656D2E446961676E6F73746963730044656275676761626C6541747472696275746500446562756767696E674D6F6465730053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C69747941747472696275746500636F6D6D616E640053797374656D2E5472616E73616374696F6E73005472616E73616374696F6E53636F7065005472616E73616374696F6E53636F70654F7074696F6E0053797374656D2E446174612E436F6D6D6F6E004462436F6E6E656374696F6E004F70656E0053716C436F6D6D616E64007365745F436F6E6E656374696F6E004462436F6D6D616E64007365745F436F6D6D616E645465787400457865637574654E6F6E517565727900436C6F73650053797374656D2E5365637572697479005365637572697479457863657074696F6E0053716C436F6E6E656374696F6E537472696E674275696C646572004462436F6E6E656374696F6E537472696E674275696C646572007365745F4974656D00426F6F6C65616E006765745F436F6E6E656374696F6E537472696E670053657269616C697A61626C65417474726962757465006D65737361676500696E6E6572457863657074696F6E00696E666F00636F6E74657874004462446174615265616465720053716C55736572446566696E65645479706541747472696275746500466F726D6174005374727563744C61796F7574417474726962757465004C61796F75744B696E6400417373656D626C7900476574457865637574696E67417373656D626C7900417373656D626C794E616D65004765744E616D650056657273696F6E006765745F56657273696F6E006F705F496D706C696369740053716C4D6574686F644174747269627574650047756964004E65774775696400537472696E67005265706C61636500436F6E636174005461626C654E616D65004F726465724F7074696F6E006765745F4974656D00496E74333200456E756D657261746F7200476574456E756D657261746F72006765745F43757272656E74006765745F4C656E677468004D617468004D6178004D6F76654E657874004D696E0053797374656D2E5465787400537472696E674275696C64657200417070656E644C696E6500417070656E6400496E7365727400696E707574006C656E67746800726F774461746100537562737472696E670072656164657200476574536368656D615461626C650044617461526F77436F6C6C656374696F6E006765745F526F777300496E7465726E616C44617461436F6C6C656374696F6E42617365006765745F436F756E740041646400497344424E756C6C0053716C446254797065004765744461746554696D65004765744461746554696D654F66667365740053716C446563696D616C0047657453716C446563696D616C0053716C446F75626C650047657453716C446F75626C65006765745F56616C756500446F75626C650047657453716C42696E6172790047657456616C7565006765745F4669656C64436F756E7400647456616C7565006765745F5469636B730064746F56616C75650073716C42696E61727900427974650072004E6F74496D706C656D656E746564457863657074696F6E0077006578706563746564436F6D6D616E640061637475616C436F6D6D616E64006765745F4D65737361676500736368656D610053797374656D2E436F6C6C656374696F6E730049456E756D657261746F72006F705F496E657175616C6974790044617461436F6C756D6E436F6C6C656374696F6E006765745F436F6C756D6E73006765745F436F6C756D6E4E616D6500636F6C756D6E00537472696E67436F6D70617269736F6E005374617274735769746800726573756C747365744E6F0053716C426F6F6C65616E006F705F457175616C697479006F705F54727565004E657874526573756C74006F705F4C6573735468616E006F705F426974776973654F7200646174615265616465720053716C436F6E746578740053716C50697065006765745F506970650053656E64526573756C747353746172740053656E64526573756C7473456E64006D6574610053656E64526573756C7473526F770047657453716C56616C7565730053657456616C75657300546F4C6F776572004C696E6B65644C6973744E6F64656031004164644C61737400636F6C756D6E44657461696C7300547970650053797374656D2E476C6F62616C697A6174696F6E0043756C74757265496E666F006765745F496E76617269616E7443756C7475726500436F6E766572740049466F726D617450726F766964657200546F4279746500417267756D656E74457863657074696F6E00726573756C745365744E6F00474300537570707265737346696E616C697A65007365745F436F6E6E656374696F6E537472696E670053797374656D2E436F6D706F6E656E744D6F64656C00436F6D706F6E656E7400476574537472696E67006765745F446174616261736500436F6D6D616E640053716C496E666F4D6573736167654576656E7448616E646C6572006164645F496E666F4D65737361676500436F6D6D616E644265686176696F7200457865637574655265616465720073656E6465720061726773006F705F4164646974696F6E006578706563746564537472696E670061637475616C537472696E670053716C506172616D65746572436F6C6C656374696F6E006765745F506172616D65746572730053716C506172616D65746572004164645769746856616C756500436F6D6D616E6454797065007365745F436F6D6D616E6454797065006661696C7572654D6573736167650074657874000080B34500720072006F007200200063006F006E006E0065006300740069006E006700200074006F002000640061007400610062006100730065002E00200059006F00750020006D006100790020006E00650065006400200074006F00200063007200650061007400650020007400530051004C007400200061007300730065006D0062006C007900200077006900740068002000450058005400450052004E0041004C005F004100430043004500530053002E0000174400610074006100200053006F007500720063006500002749006E0074006500670072006100740065006400200053006500630075007200690074007900001F49006E0069007400690061006C00200043006100740061006C006F00670000237400530051004C0074005F00740065006D0070006F0062006A006500630074005F0000032D00010100354F0062006A0065006300740020006E0061006D0065002000630061006E006E006F00740020006200650020004E0055004C004C0000037C0000032B0000032000000B3C002E002E002E003E00001D530045004C0045004300540020002A002000460052004F004D002000001520004F0052004400450052002000420059002000001543006F006C0075006D006E004E0061006D006500000D21004E0055004C004C0021000019500072006F00760069006400650072005400790070006500002930002E0030003000300030003000300030003000300030003000300030003000300045002B003000001D7B0030003A0079007900790079002D004D004D002D00640064007D0001377B0030003A0079007900790079002D004D004D002D00640064002000480048003A006D006D003A00730073002E006600660066007D0001297B0030003A0079007900790079002D004D004D002D00640064002000480048003A006D006D007D00013F7B0030003A0079007900790079002D004D004D002D00640064002000480048003A006D006D003A00730073002E0066006600660066006600660066007D0001477B0030003A0079007900790079002D004D004D002D00640064002000480048003A006D006D003A00730073002E00660066006600660066006600660020007A007A007A007D0001053000780000055800320000737400530051004C007400500072006900760061007400650020006900730020006E006F007400200069006E00740065006E00640065006400200074006F002000620065002000750073006500640020006F0075007400730069006400650020006F00660020007400530051004C0074002100001B540068006500200063006F006D006D0061006E00640020005B0000475D00200064006900640020006E006F0074002000720065007400750072006E00200061002000760061006C0069006400200072006500730075006C0074002000730065007400003B5D00200064006900640020006E006F0074002000720065007400750072006E0020006100200072006500730075006C0074002000730065007400001149007300480069006400640065006E000009540072007500650000035B0000037B0000033A0000037D0000035D0000054900730000094200610073006500003145007800650063007500740069006F006E002000720065007400750072006E006500640020006F006E006C00790020000031200052006500730075006C00740053006500740073002E00200052006500730075006C00740053006500740020005B0000235D00200064006F006500730020006E006F0074002000650078006900730074002E00005D52006500730075006C007400530065007400200069006E00640065007800200062006500670069006E007300200061007400200031002E00200052006500730075006C007400530065007400200069006E0064006500780020005B00001B5D00200069007300200069006E00760061006C00690064002E0000097400720075006500001144006100740061005400790070006500001543006F006C0075006D006E00530069007A00650000214E0075006D00650072006900630050007200650063006900730069006F006E0000194E0075006D0065007200690063005300630061006C006500001541007200670075006D0065006E00740020005B0000475D0020006900730020006E006F0074002000760061006C0069006400200066006F007200200052006500730075006C007400530065007400460069006C007400650072002E00003143006F006E007400650078007400200043006F006E006E0065006300740069006F006E003D0074007200750065003B000049530045004C004500430054002000530045005200560045005200500052004F0050004500520054005900280027005300650072007600650072004E0061006D006500270029003B0001050D000A0000317400530051004C0074002E0041007300730065007200740045007100750061006C00730053007400720069006E006700001145007800700065006300740065006400000D410063007400750061006C0000157400530051004C0074002E004600610069006C0000114D006500730073006100670065003000002F7400530051004C0074002E004C006F006700430061007000740075007200650064004F0075007400700075007400000974006500780074000000006F8550E9F9562A4A9D0C94CAA0AD2EDD0008B77A5C561934E08905200101111D0300000E03200001042001010E062002010E120907200201122111250306122805200101122802060E0C21004E0055004C004C002100020608049B000000040000111D0800021229111D111D0500020E0E080400010E0E0900020E10111D10111D0A000115122D011D0E12310500010E11350500010E11390500010E113D0500010E11410400001114032000020600011114111D0320000E05200101124505200101124904080011140328000207200201111D111D0520010E111D050001011231080002124D111D123107000201111D124D0500010E124D050001021251072002011155111D0520010111550800020112311D1259090002125D12311D12590700011D125912310A0001151261011265124D0600011259126507000201111D111D070002011155111D05000101111D030612690306111D020602042000111D0620011231111D062002011C126D052002010E0E042800111D0328000E0420010102062001011180A1042001010880A00024000004800000940000000602000000240000525341310004000001000100590AB8C4CF2A26FA41954EEAABE1E3D152A84C81F41E1FAD58EAE59DFB9D7D3520D36FDFC23567120AF4B46ACC235A150B34CF341AD40147E9DD4F11A1A7A8D20664924F46776FD00AA300F2E09F7BFBE5583FFFBB233B24401A3C0894E805BA8BE5451FDBD81AD24E0897512A842B08E1FC09CC6F35B3B21B5F927687887AC4062001011180B1052001011269032000080E070512691280AD0E1280B91280C1052002010E1C0A070512280E0E1280C50E0407011231062001011180DD2B010002000000020054080B4D61784279746553697A650100000054020D497346697865644C656E67746801062001011180E50500001280E90520001280ED0520001280F1050001111D0E808F010001005455794D6963726F736F66742E53716C5365727665722E5365727665722E446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D322E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038390A44617461416363657373010000000500001180F90520020E0E0E0500020E0E0E0507011180F90615122D011D0E052001130008092000151181050113000715118105011D0E042000130005000208080805200012810D06200112810D0E08200312810D080E082F071412280E123115122D011D0E081D081D0E080808080212810D1D0E080815118105011D0E1D080815118105011D0E0520020E08080600030E0E0E0E0307010E042000124D0520001281110520011265080420011C0E052001011300042001020805200111390806000111351139052001113D0806200111811D08062001118121080320000D0420010E0E0520011141080420011C0820070D124D15122D011D0E081D0E0812651D0E0811811911811911811D1181210D04200011390500020E0E1C0320000A042001010A0420001D0509070412810D051D05080607030E0E12180707031231124D0E0607021209124D0520001281310320001C050002020E0E0520001281350500010E1D1C1407090E126512511281311281311C1D1C12191219072002020E11813905000111550809000211813D115511550600010211813D0500010E1D0E0707031231081D0E06000111813D020B000211813D11813D11813D050000128145062001011D125905200101125D0507011D1259052001081D1C060702125D1D1C06151261011265092000151181490113000715118149011265170706124D1512610112651D1259081265151181490112650B20011512814D01130013000F070415126101126512651281311219072002010E118119082003010E1181190A050000128155070002051C12815D092004010E11811905050A2003010E1181191281510D07051181190E12815108118119040701121C040701122004070112080407011210040001011C0420010E0805070212310E052002011C180620010112816D07200112311181710707021280B91231080002111D111D111D0520001281750720021281790E1C0620010111817D0507011280B90501000100000501000000002101001C436F7079726967687420C2A92073716C6974792E6E6574203230313000000A0100057453514C7400000F01000A73716C6974792E6E657400002E010029434C527320666F7220746865207453514C7420756E69742074657374696E67206672616D65776F726B00000D0100087453514C74434C5200000801000200000000000801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F77730100000000009813A04F000000000200000095000000745F0000744100005253445340C8124359C3AC4D88C93F5C236A856601000000633A5C55736572735C6D65696E736530305C62616D626F6F2D686F6D655C786D6C2D646174615C6275696C642D6469725C5453514C542D5453514C54504C414E2D5453514C544255494C445C7453514C74434C525C7453514C74434C525C6F626A5C437275697365436F6E74726F6C5C7453514C74434C522E706462000000003460000000000000000000004E60000000200000000000000000000000000000000000000000000040600000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF25002040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058800000900300000000000000000000900334000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE0000010000000100E452981100000100E45298113F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004F0020000010053007400720069006E006700460069006C00650049006E0066006F000000CC02000001003000300030003000300034006200300000006C002A00010043006F006D006D0065006E0074007300000043004C0052007300200066006F007200200074006800650020007400530051004C007400200075006E00690074002000740065007300740069006E00670020006600720061006D00650077006F0072006B00000038000B00010043006F006D00700061006E0079004E0061006D00650000000000730071006C006900740079002E006E0065007400000000003C0009000100460069006C0065004400650073006300720069007000740069006F006E00000000007400530051004C00740043004C0052000000000040000F000100460069006C006500560065007200730069006F006E000000000031002E0030002E0034003500300034002E0032003100320032003000000000003C000D00010049006E007400650072006E0061006C004E0061006D00650000007400530051004C00740043004C0052002E0064006C006C00000000005C001C0001004C006500670061006C0043006F007000790072006900670068007400000043006F0070007900720069006700680074002000A9002000730071006C006900740079002E006E006500740020003200300031003000000044000D0001004F0072006900670069006E0061006C00460069006C0065006E0061006D00650000007400530051004C00740043004C0052002E0064006C006C00000000002C0006000100500072006F0064007500630074004E0061006D006500000000007400530051004C007400000044000F000100500072006F006400750063007400560065007200730069006F006E00000031002E0030002E0034003500300034002E00320031003200320030000000000048000F00010041007300730065006D0062006C0079002000560065007200730069006F006E00000031002E0030002E0034003500300034002E003200310032003200300000000000000000000000000000000000000000000000000000000000006000000C000000603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
WITH PERMISSION_SET = EXTERNAL_ACCESS
GO



GO

/*
   Copyright 2011 tSQLt

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
GO

CREATE PROCEDURE tSQLt.ResultSetFilter @ResultsetNo INT, @Command NVARCHAR(MAX)
AS
EXTERNAL NAME tSQLtCLR.[tSQLtCLR.StoredProcedures].ResultSetFilter;
GO

CREATE PROCEDURE tSQLt.AssertResultSetsHaveSameMetaData @expectedCommand NVARCHAR(MAX), @actualCommand NVARCHAR(MAX)
AS
EXTERNAL NAME tSQLtCLR.[tSQLtCLR.StoredProcedures].AssertResultSetsHaveSameMetaData;
GO

CREATE TYPE tSQLt.[Private] EXTERNAL NAME tSQLtCLR.[tSQLtCLR.tSQLtPrivate];
GO

CREATE PROCEDURE tSQLt.NewConnection @command NVARCHAR(MAX)
AS
EXTERNAL NAME tSQLtCLR.[tSQLtCLR.StoredProcedures].NewConnection;
GO

CREATE PROCEDURE tSQLt.CaptureOutput @command NVARCHAR(MAX)
AS
EXTERNAL NAME tSQLtCLR.[tSQLtCLR.StoredProcedures].CaptureOutput;
GO

CREATE PROCEDURE tSQLt.SuppressOutput @command NVARCHAR(MAX)
AS
EXTERNAL NAME tSQLtCLR.[tSQLtCLR.StoredProcedures].SuppressOutput;
GO



GO

IF OBJECT_ID('tSQLt.Info') IS NOT NULL DROP FUNCTION tSQLt.Info;
GO
---Build+
CREATE FUNCTION tSQLt.Info()
RETURNS TABLE
AS
RETURN
SELECT
Version = '1.0.4504.21220',
ClrVersion = (SELECT tSQLt.Private::Info());
---Build-


GO

IF OBJECT_ID('tSQLt.TableToText') IS NOT NULL DROP PROCEDURE tSQLt.TableToText;
GO
---Build+
CREATE PROCEDURE tSQLt.TableToText
    @txt NVARCHAR(MAX) OUTPUT,
    @TableName NVARCHAR(MAX),
    @OrderBy NVARCHAR(MAX) = NULL
AS
BEGIN
    SET @txt = tSQLt.Private::TableToString(@TableName,@OrderBy);
END;
---Build-


GO

IF OBJECT_ID('tSQLt.Private_GetForeignKeyDefinition') IS NOT NULL DROP FUNCTION tSQLt.Private_GetForeignKeyDefinition;
GO
---Build+
CREATE FUNCTION tSQLt.Private_GetForeignKeyDefinition(
    @SchemaName NVARCHAR(MAX),
    @ParentTableName NVARCHAR(MAX),
    @ForeignKeyName NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN SELECT 'CONSTRAINT ' + name + ' FOREIGN KEY (' +
              parCol + ') REFERENCES ' + refName + '(' + refCol + ')' cmd,
              CASE 
                WHEN RefTableIsFakedInd = 1
                  THEN 'CREATE UNIQUE INDEX ' + tSQLt.Private::CreateUniqueObjectName() + ' ON ' + refName + '(' + refCol + ');' 
                ELSE '' 
              END CreIdxCmd
         FROM (SELECT QUOTENAME(SCHEMA_NAME(k.schema_id)) AS SchemaName,
                      QUOTENAME(k.name) AS name,
                      QUOTENAME(OBJECT_NAME(k.parent_object_id)) AS parName,
                      QUOTENAME(SCHEMA_NAME(refTab.schema_id)) + '.' + QUOTENAME(refTab.name) AS refName,
                      QUOTENAME(parCol.name) AS parCol,
                      QUOTENAME(refCol.name) AS refCol,
                      CASE WHEN e.name IS NULL THEN 0
                           ELSE 1 
                       END AS RefTableIsFakedInd
                 FROM sys.foreign_keys k
                 JOIN sys.foreign_key_columns c
                   ON k.object_id = c.constraint_object_id
                 JOIN sys.columns parCol
                   ON parCol.object_id = c.parent_object_id
                  AND parCol.column_id = c.parent_column_id
                 JOIN sys.columns refCol
                   ON refCol.object_id = c.referenced_object_id
                  AND refCol.column_id = c.referenced_column_id
                 LEFT JOIN sys.extended_properties e
                   ON e.name = 'tSQLt.FakeTable_OrgTableName'
                  AND e.value = OBJECT_NAME(c.referenced_object_id)
                 JOIN sys.tables refTab
                   ON COALESCE(e.major_id,refCol.object_id) = refTab.object_id
                WHERE k.parent_object_id = OBJECT_ID(@SchemaName + '.' + @ParentTableName)
                  AND k.object_id = OBJECT_ID(@SchemaName + '.' + @ForeignKeyName)
               )x;
---Build-

GO

IF OBJECT_ID('tSQLt.Private_RenamedObjectLog') IS NOT NULL DROP TABLE tSQLt.Private_RenamedObjectLog;
GO
---Build+
CREATE TABLE tSQLt.Private_RenamedObjectLog (
  Id INT IDENTITY(1,1) CONSTRAINT PK__Private_RenamedObjectLog__Id PRIMARY KEY CLUSTERED,
  ObjectId INT NOT NULL,
  OriginalName NVARCHAR(MAX) NOT NULL
);
---Build-
GO

GO

IF OBJECT_ID('tSQLt.Private_MarkObjectBeforeRename') IS NOT NULL DROP PROCEDURE tSQLt.Private_MarkObjectBeforeRename;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_MarkObjectBeforeRename
    @SchemaName NVARCHAR(MAX), 
    @OriginalName NVARCHAR(MAX)
AS
BEGIN
  INSERT INTO tSQLt.Private_RenamedObjectLog (ObjectId, OriginalName) 
  VALUES (OBJECT_ID(@SchemaName + '.' + @OriginalName), @OriginalName);
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_RenameObjectToUniqueName') IS NOT NULL DROP PROCEDURE tSQLt.Private_RenameObjectToUniqueName;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_RenameObjectToUniqueName
    @SchemaName NVARCHAR(MAX),
    @ObjectName NVARCHAR(MAX),
    @NewName NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
   SET @NewName=tSQLt.Private::CreateUniqueObjectName();

   DECLARE @RenameCmd NVARCHAR(MAX);
   SET @RenameCmd = 'EXEC sp_rename ''' + 
                          @SchemaName + '.' + @ObjectName + ''', ''' + 
                          @NewName + ''';';
   
   EXEC tSQLt.Private_MarkObjectBeforeRename @SchemaName, @ObjectName;

   EXEC tSQLt.SuppressOutput @RenameCmd;

END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_RenameObjectToUniqueNameUsingObjectId') IS NOT NULL DROP PROCEDURE tSQLt.Private_RenameObjectToUniqueNameUsingObjectId;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_RenameObjectToUniqueNameUsingObjectId
    @ObjectId INT,
    @NewName NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
   DECLARE @SchemaName NVARCHAR(MAX);
   DECLARE @ObjectName NVARCHAR(MAX);
   
   SELECT @SchemaName = QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId)), @ObjectName = QUOTENAME(OBJECT_NAME(@ObjectId));
   
   EXEC tSQLt.Private_RenameObjectToUniqueName @SchemaName,@ObjectName, @NewName OUTPUT;
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_ValidateFakeTableParameters') IS NOT NULL DROP PROCEDURE tSQLt.Private_ValidateFakeTableParameters;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_ValidateFakeTableParameters
  @SchemaName NVARCHAR(MAX),
  @OrigTableName NVARCHAR(MAX),
  @OrigSchemaName NVARCHAR(MAX)
AS
BEGIN
   IF @SchemaName IS NULL
   BEGIN
        DECLARE @FullName NVARCHAR(MAX); SET @FullName = @OrigTableName + COALESCE('.' + @OrigSchemaName, '');
        
        RAISERROR ('FakeTable could not resolve the object name, ''%s''. Be sure to call FakeTable and pass in a single parameter, such as: EXEC tSQLt.FakeTable ''MySchema.MyTable''', 
                   16, 10, @FullName);
   END;
END;
---Build-
GO



GO

IF OBJECT_ID('tSQLt.Private_GetDataTypeOrComputedColumnDefinition') IS NOT NULL DROP FUNCTION tSQLt.Private_GetDataTypeOrComputedColumnDefinition;
---Build+
GO
CREATE FUNCTION tSQLt.Private_GetDataTypeOrComputedColumnDefinition(@UserTypeId INT, @MaxLength INT, @Precision INT, @Scale INT, @CollationName NVARCHAR(MAX), @ObjectId INT, @ColumnId INT, @ReturnDetails BIT)
RETURNS TABLE
AS
RETURN SELECT 
              COALESCE(IsComputedColumn, 0) AS IsComputedColumn,
              COALESCE(ComputedColumnDefinition, TypeName) AS ColumnDefinition
        FROM tSQLt.Private_GetFullTypeName(@UserTypeId, @MaxLength, @Precision, @Scale, @CollationName)
        LEFT JOIN (SELECT 1 AS IsComputedColumn,' AS '+ definition + CASE WHEN is_persisted = 1 THEN ' PERSISTED' ELSE '' END AS ComputedColumnDefinition,object_id,column_id
                     FROM sys.computed_columns 
                  )cc
               ON cc.object_id = @ObjectId
              AND cc.column_id = @ColumnId
              AND @ReturnDetails = 1;               
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_GetIdentityDefinition') IS NOT NULL DROP FUNCTION tSQLt.Private_GetIdentityDefinition;
GO
---Build+
CREATE FUNCTION tSQLt.Private_GetIdentityDefinition(@ObjectId INT, @ColumnId INT, @ReturnDetails BIT)
RETURNS TABLE
AS
RETURN SELECT 
              COALESCE(IsIdentity, 0) AS IsIdentityColumn,
              COALESCE(IdentityDefinition, '') AS IdentityDefinition
        FROM (SELECT 1) X(X)
        LEFT JOIN (SELECT 1 AS IsIdentity,
                          ' IDENTITY(' + CAST(seed_value AS NVARCHAR(MAX)) + ',' + CAST(increment_value AS NVARCHAR(MAX)) + ')' AS IdentityDefinition, 
                          object_id, 
                          column_id
                     FROM sys.identity_columns
                  ) AS id
               ON id.object_id = @ObjectId
              AND id.column_id = @ColumnId
              AND @ReturnDetails = 1;               
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_GetDefaultConstraintDefinition') IS NOT NULL DROP FUNCTION tSQLt.Private_GetDefaultConstraintDefinition;
---Build+
GO
CREATE FUNCTION tSQLt.Private_GetDefaultConstraintDefinition(@ObjectId INT, @ColumnId INT, @ReturnDetails BIT)
RETURNS TABLE
AS
RETURN SELECT 
              COALESCE(IsDefault, 0) AS IsDefault,
              COALESCE(DefaultDefinition, '') AS DefaultDefinition
        FROM (SELECT 1) X(X)
        LEFT JOIN (SELECT 1 AS IsDefault,' DEFAULT '+ definition AS DefaultDefinition,parent_object_id,parent_column_id
                     FROM sys.default_constraints
                  )dc
               ON dc.parent_object_id = @ObjectId
              AND dc.parent_column_id = @ColumnId
              AND @ReturnDetails = 1;               
---Build-
GO

GO

IF OBJECT_ID('tSQLt.Private_CreateFakeOfTable') IS NOT NULL DROP PROCEDURE tSQLt.Private_CreateFakeOfTable;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_CreateFakeOfTable
  @SchemaName NVARCHAR(MAX),
  @TableName NVARCHAR(MAX),
  @NewNameOfOriginalTable NVARCHAR(MAX),
  @Identity BIT,
  @ComputedColumns BIT,
  @Defaults BIT
AS
BEGIN
   DECLARE @Cmd NVARCHAR(MAX);
   DECLARE @Cols NVARCHAR(MAX);
   
   SELECT @Cols = 
   (
    SELECT
       ',' +
       QUOTENAME(name) + 
       cc.ColumnDefinition +
       dc.DefaultDefinition + 
       id.IdentityDefinition +
       CASE WHEN cc.IsComputedColumn = 1 OR id.IsIdentityColumn = 1 
            THEN ''
            ELSE ' NULL'
       END
      FROM sys.columns c
     CROSS APPLY tSQLt.Private_GetDataTypeOrComputedColumnDefinition(c.user_type_id, c.max_length, c.precision, c.scale, c.collation_name, c.object_id, c.column_id, @ComputedColumns) cc
     CROSS APPLY tSQLt.Private_GetDefaultConstraintDefinition(c.object_id, c.column_id, @Defaults) AS dc
     CROSS APPLY tSQLt.Private_GetIdentityDefinition(c.object_id, c.column_id, @Identity) AS id
     WHERE object_id = OBJECT_ID(@SchemaName + '.' + @NewNameOfOriginalTable)
     ORDER BY column_id
     FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)');
    
   SELECT @Cmd = 'CREATE TABLE ' + @SchemaName + '.' + @TableName + '(' + STUFF(@Cols,1,1,'') + ')';
   
   EXEC (@Cmd);
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_MarkFakeTable') IS NOT NULL DROP PROCEDURE tSQLt.Private_MarkFakeTable;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_MarkFakeTable
  @SchemaName NVARCHAR(MAX),
  @TableName NVARCHAR(MAX),
  @NewNameOfOriginalTable NVARCHAR(4000)
AS
BEGIN
   DECLARE @UnquotedSchemaName NVARCHAR(MAX);SET @UnquotedSchemaName = OBJECT_SCHEMA_NAME(OBJECT_ID(@SchemaName+'.'+@TableName));
   DECLARE @UnquotedTableName NVARCHAR(MAX);SET @UnquotedTableName = OBJECT_NAME(OBJECT_ID(@SchemaName+'.'+@TableName));

   EXEC sys.sp_addextendedproperty 
      @name = N'tSQLt.FakeTable_OrgTableName', 
      @value = @NewNameOfOriginalTable, 
      @level0type = N'SCHEMA', @level0name = @UnquotedSchemaName, 
      @level1type = N'TABLE',  @level1name = @UnquotedTableName;
END;
---Build-
GO

GO

IF OBJECT_ID('tSQLt.FakeTable') IS NOT NULL DROP PROCEDURE tSQLt.FakeTable;
GO
---Build+
CREATE PROCEDURE tSQLt.FakeTable
    @TableName NVARCHAR(MAX),
    @SchemaName NVARCHAR(MAX) = NULL, --parameter preserved for backward compatibility. Do not use. Will be removed soon.
    @Identity BIT = NULL,
    @ComputedColumns BIT = NULL,
    @Defaults BIT = NULL
AS
BEGIN
   DECLARE @OrigSchemaName NVARCHAR(MAX);
   DECLARE @OrigTableName NVARCHAR(MAX);
   DECLARE @NewNameOfOriginalTable NVARCHAR(4000);
   
   SELECT @OrigSchemaName = @SchemaName,
          @OrigTableName = @TableName
   
   SELECT @SchemaName = CleanSchemaName,
          @TableName = CleanTableName
     FROM tSQLt.Private_ResolveFakeTableNamesForBackwardCompatibility(@TableName, @SchemaName);
   
   EXEC tSQLt.Private_ValidateFakeTableParameters @SchemaName,@OrigTableName,@OrigSchemaName;

   EXEC tSQLt.Private_RenameObjectToUniqueName @SchemaName, @TableName, @NewNameOfOriginalTable OUTPUT;

   EXEC tSQLt.Private_CreateFakeOfTable @SchemaName, @TableName, @NewNameOfOriginalTable, @Identity, @ComputedColumns, @Defaults;

   EXEC tSQLt.Private_MarkFakeTable @SchemaName, @TableName, @NewNameOfOriginalTable;
END
---Build-
GO


GO

IF OBJECT_ID('tSQLt.Private_CreateProcedureSpy') IS NOT NULL DROP PROCEDURE tSQLt.Private_CreateProcedureSpy;
GO
---Build+
CREATE PROCEDURE tSQLt.Private_CreateProcedureSpy
    @ProcedureObjectId INT,
    @OriginalProcedureName NVARCHAR(MAX),
    @LogTableName NVARCHAR(MAX),
    @CommandToExecute NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @Cmd NVARCHAR(MAX);
    DECLARE @ProcParmList NVARCHAR(MAX),
            @TableColList NVARCHAR(MAX),
            @ProcParmTypeList NVARCHAR(MAX),
            @TableColTypeList NVARCHAR(MAX);
            
    DECLARE @Seperator CHAR(1),
            @ProcParmTypeListSeparater CHAR(1),
            @ParamName sysname,
            @TypeName sysname,
            @IsOutput BIT,
            @IsCursorRef BIT;
            

      
    SELECT @Seperator = '', @ProcParmTypeListSeparater = '', 
           @ProcParmList = '', @TableColList = '', @ProcParmTypeList = '', @TableColTypeList = '';
      
    DECLARE Parameters CURSOR FOR
     SELECT p.name, t.TypeName, is_output, is_cursor_ref
       FROM sys.parameters p
       CROSS APPLY tSQLt.Private_GetFullTypeName(p.user_type_id,p.max_length,p.precision,p.scale,NULL) t
      WHERE object_id = @ProcedureObjectId;
    
    OPEN Parameters;
    
    FETCH NEXT FROM Parameters INTO @ParamName, @TypeName, @IsOutput, @IsCursorRef;
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF @IsCursorRef = 0
        BEGIN
            SELECT @ProcParmList = @ProcParmList + @Seperator + @ParamName, 
                   @TableColList = @TableColList + @Seperator + '[' + STUFF(@ParamName,1,1,'') + ']', 
                   @ProcParmTypeList = @ProcParmTypeList + @ProcParmTypeListSeparater + @ParamName + ' ' + @TypeName + ' = NULL ' + 
                                       CASE WHEN @IsOutput = 1 THEN ' OUT' 
                                            ELSE '' 
                                       END, 
                   @TableColTypeList = @TableColTypeList + ',[' + STUFF(@ParamName,1,1,'') + '] ' + 
                          CASE WHEN @TypeName LIKE '%nchar%'
                                 OR @TypeName LIKE '%nvarchar%'
                               THEN 'nvarchar(MAX)'
                               WHEN @TypeName LIKE '%char%'
                               THEN 'varchar(MAX)'
                               ELSE @TypeName
                          END + ' NULL';

            SELECT @Seperator = ',';        
            SELECT @ProcParmTypeListSeparater = ',';
        END
        ELSE
        BEGIN
            SELECT @ProcParmTypeList = @ProcParmTypeListSeparater + @ParamName + ' CURSOR VARYING OUTPUT';
            SELECT @ProcParmTypeListSeparater = ',';
        END;
        
        FETCH NEXT FROM Parameters INTO @ParamName, @TypeName, @IsOutput, @IsCursorRef;
    END;
    
    CLOSE Parameters;
    DEALLOCATE Parameters;
    
    DECLARE @InsertStmt NVARCHAR(MAX);
    SELECT @InsertStmt = 'INSERT INTO ' + @LogTableName + 
                         CASE WHEN @TableColList = '' THEN ' DEFAULT VALUES'
                              ELSE ' (' + @TableColList + ') SELECT ' + @ProcParmList
                         END + ';';
                         
    SELECT @Cmd = 'CREATE TABLE ' + @LogTableName + ' (_id_ int IDENTITY(1,1) PRIMARY KEY CLUSTERED ' + @TableColTypeList + ');';
    EXEC(@Cmd);

    SELECT @Cmd = 'CREATE PROCEDURE ' + @OriginalProcedureName + ' ' + @ProcParmTypeList + 
                  ' AS BEGIN ' + 
                     @InsertStmt + 
                     ISNULL(@CommandToExecute, '') + ';' +
                  ' END;';
    EXEC(@Cmd);

    RETURN 0;
END;
---Build-
GO


GO

IF OBJECT_ID('tSQLt.SpyProcedure') IS NOT NULL DROP PROCEDURE tSQLt.SpyProcedure;
GO
---Build+
CREATE PROCEDURE tSQLt.SpyProcedure
    @ProcedureName NVARCHAR(MAX),
    @CommandToExecute NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @ProcedureObjectId INT;
    SELECT @ProcedureObjectId = OBJECT_ID(@ProcedureName);

    EXEC tSQLt.Private_ValidateProcedureCanBeUsedWithSpyProcedure @ProcedureName;

    DECLARE @LogTableName NVARCHAR(MAX);
    SELECT @LogTableName = QUOTENAME(OBJECT_SCHEMA_NAME(@ProcedureObjectId)) + '.' + QUOTENAME(OBJECT_NAME(@ProcedureObjectId)+'_SpyProcedureLog');

    EXEC tSQLt.Private_RenameObjectToUniqueNameUsingObjectId @ProcedureObjectId;

    EXEC tSQLt.Private_CreateProcedureSpy @ProcedureObjectId, @ProcedureName, @LogTableName, @CommandToExecute;

    RETURN 0;
END;
---Build-
GO


GO



/* Adding the demo tSQLt Tests */

CREATE SCHEMA [Unit Tests]
GO
CREATE SCHEMA [SQL Cop]
GO

EXEC sys.sp_addextendedproperty @name=N'tSQLt.TestClass', @value=1 , @level0type=N'SCHEMA',@level0name=N'Unit Tests'
GO
EXEC sys.sp_addextendedproperty @name=N'tSQLt.TestClass', @value=1 , @level0type=N'SCHEMA',@level0name=N'SQL Cop'
GO


CREATE PROCEDURE [Unit Tests].[test Email in prcAddContact]
AS
BEGIN
-- Create a fake table
EXEC tSQLt.FakeTable 'dbo.Contacts';

-- Populate a record using the procedure I'm testing
EXEC [prcAddContact]
@ContactFullName = 'David Atkinson',
@Email = 'sql.in.the.city@red-gate.com';

-- Specify the actual results
DECLARE @ActualEmail CHAR(30);
SET @ActualEmail = (SELECT Email FROM dbo.Contacts);

-- Verify that the actual results corresponds to the expected results
EXEC tSQLt.AssertEquals @Expected = 'sql.in.the.city@red-gate.com', @Actual = @ActualEmail;
END;

GO


/* Adding the SQL Cop tSQLt tests*/
GO
CREATE PROCEDURE [SQL Cop].[test Procedures Named SP_]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012
    -- http://sqlcop.lessthandot.com
    -- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-start-your-procedures-with-sp_
    
    SET NOCOUNT ON
    
    Declare @Output VarChar(max)
    Set @Output = ''
  
    SELECT	@Output = @Output + SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME + Char(13) + Char(10)
    From	INFORMATION_SCHEMA.ROUTINES
    Where	SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'sp[_]%'
            And SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI NOT LIKE '%diagram%'
            AND ROUTINE_SCHEMA <> 'tSQLt'
    Order By SPECIFIC_SCHEMA,SPECIFIC_NAME

    If @Output > '' 
        Begin
            Set @Output = Char(13) + Char(10) 
                          + 'For more information:  '
                          + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-start-your-procedures-with-sp_'
                          + Char(13) + Char(10) 
                          + Char(13) + Char(10) 
                          + @Output
            EXEC tSQLt.Fail @Output
        End 
END;

GO

/****** Object:  StoredProcedure [[Unit Tests]].[test Procedures using dynamic SQL without sp_executesql]    Script Date: 04/09/2012 18:32:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SQL Cop].[test Procedures using dynamic SQL without sp_executesql]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/avoid-conversions-in-execution-plans-by-
	
	SET NOCOUNT ON
	
	Declare @Output VarChar(max)
	Set @Output = ''

	SELECT	@Output = @Output + SCHEMA_NAME(so.uid) + '.' + so.name + Char(13) + Char(10)
	From	sys.sql_modules sm
			Inner Join sys.sysobjects so
				On  sm.object_id = so.id
				And so.type = 'P'
	Where	so.uid <> Schema_Id('tSQLt')
			And so.uid <> Schema_Id('SQLCop')
			And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%Exec(%'
			And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Not Like '%sp_Executesql%'
			And OBJECTPROPERTY(so.id, N'IsMSShipped') = 0
	Order By SCHEMA_NAME(so.uid),so.name

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/avoid-conversions-in-execution-plans-by-'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
 
END;

GO

/****** Object:  StoredProcedure [SQLCop].[test Procedures with @@Identity]    Script Date: 04/09/2012 18:32:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SQL Cop].[test Procedures with @@Identity]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://wiki.lessthandot.com/index.php/6_Different_Ways_To_Get_The_Current_Identity_Value
	
	SET NOCOUNT ON

	Declare @Output VarChar(max)
	Set @Output = ''

	Select	@Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
	From	sys.all_objects
	Where	type = 'P'
			AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram','testProcedures with @@Identity')
			And Object_Definition(object_id) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%@@identity%'
			And is_ms_shipped = 0
			and schema_id <> Schema_id('tSQLt')
			and schema_id <> Schema_id('SQLCop')
	ORDER BY Schema_Name(schema_id), name 

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://wiki.lessthandot.com/index.php/6_Different_Ways_To_Get_The_Current_Identity_Value'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
	
END;

GO

/****** Object:  StoredProcedure [SQLCop].[test Procedures With SET ROWCOUNT]    Script Date: 04/09/2012 18:32:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SQL Cop].[test Procedures With SET ROWCOUNT]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012
    -- http://sqlcop.lessthandot.com
    -- http://sqltips.wordpress.com/2007/08/19/set-rowcount-will-not-be-supported-in-future-version-of-sql-server/
    
    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''
  
    SELECT	@Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
    From	sys.all_objects
    Where	type = 'P'
            AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram','testProcedures With SET ROWCOUNT')
            And Replace(Object_Definition(Object_id), ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%SETROWCOUNT%'
            And is_ms_shipped = 0
            and schema_id <> Schema_id('tSQLt')
            and schema_id <> Schema_id('SQLCop')			
    ORDER BY Schema_Name(schema_id) + '.' + name

    If @Output > '' 
        Begin
            Set @Output = Char(13) + Char(10) 
                          + 'For more information:  '
                          + 'http://sqltips.wordpress.com/2007/08/19/set-rowcount-will-not-be-supported-in-future-version-of-sql-server/'
                          + Char(13) + Char(10) 
                          + Char(13) + Char(10) 
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO


