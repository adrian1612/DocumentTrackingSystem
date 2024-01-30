USE [master]
GO
/****** Object:  Database [dbDocTrack]    Script Date: 30/01/2024 11:35:30 am ******/
CREATE DATABASE [dbDocTrack]
GO
USE [dbDocTrack]
GO
/****** Object:  StoredProcedure [dbo].[tbl_Document_Proc]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[tbl_Document_Proc]
@Type VARCHAR(50),
@Search VARCHAR(max) = null,
@ID int = null,
@Path varchar(max) = null,
@Filename varchar(max) = null,
@QRCode varchar(500) = null,
@ReceivedFrom varchar(max) = null,
@Office int = null,
@Category int = null,
@Description varchar(max) = null,
@Encoder int = null,
@Date datetime = null,
@Timestamp datetime = null,
@From DATETIME = NULL,
@To DATETIME = NULL,
@startSeries INT = NULL,
@endSeries INT = NULL,
@ADate DATETIME = NULL,
@Activity VARCHAR(MAX) = NULL
AS
BEGIN
IF @Type = 'Create'
BEGIN
	INSERT INTO [tbl_Document]
	([Path],[Filename],[ReceivedFrom],[Office],[Category],[Description],[Encoder],[Date])
	VALUES
	(@Path,@Filename,@ReceivedFrom,@Office,@Category,@Description,@Encoder,@Date)

	INSERT INTO tbl_Activity (DocumentID,ADate, Activity, Encoder) VALUES (IDENT_CURRENT('tbl_Document'),@Date, 'Document Encoded', @Encoder)
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Update'
BEGIN
	UPDATE [tbl_Document] SET [Path] = @Path
	,[Filename] = @Filename
	,[ReceivedFrom] = @ReceivedFrom
	,[Office] = @Office
	,[Category] = @Category
	,[Description] = @Description
	,[Date] = @Date WHERE [ID] = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Search'
BEGIN
	SELECT * FROM [vw_Document] 
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'AddActivity'
BEGIN
	INSERT INTO tbl_Activity (DocumentID, ADate, Activity, Encoder) VALUES (@ID, @ADate, @Activity, @Encoder)
	SELECT * FROM vw_Activity WHERE DocumentID = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'SearchFromReceived'
BEGIN
	SELECT * FROM [vw_Document] WHERE ReceivedFrom LIKE CONCAT('%', @Search, '%')
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'ByDate'
BEGIN
	SELECT * FROM [vw_Document] WHERE [Date] BETWEEN @From AND @To
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'ByDocumentType'
BEGIN
	SELECT * FROM [vw_Document] WHERE Category LIKE CONCAT('%',@Search,'%')
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'ByQRCode'
BEGIN
	SELECT * FROM [vw_Document] WHERE QRCode LIKE CONCAT('%',@Search,'%')
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'QRCode'
BEGIN
	SELECT * FROM [vw_Document] WHERE QRCode = @QRCode
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'ByOffice'
BEGIN
	SELECT * FROM [vw_Document] WHERE OfficeName LIKE CONCAT('%',@Search,'%')
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Find'
BEGIN
	SELECT * FROM [vw_Document] WHERE  ID = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'GenerateQR'
BEGIN
	SELECT * FROM [vw_Document] WHERE  ID between @startSeries and @endSeries
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'ReceivedFromList'
BEGIN
	SELECT ReceivedFrom FROM [vw_Document] WHERE ReceivedFrom LIKE CONCAT('%',@Search, '%') GROUP BY ReceivedFrom
END
END





GO
/****** Object:  StoredProcedure [dbo].[tbl_User_Proc]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[tbl_User_Proc]
@Type VARCHAR(50),
@Search VARCHAR(max) = null,
@ID int = null,
@Username varchar(max) = null,
@Password varchar(max) = null,
@Role int = null,
@Active bit = null,
@fname varchar(max) = null,
@mn varchar(max) = null,
@lname varchar(max) = null,
@gender varchar(50) = null,
@email varchar(max) = null,
@address varchar(max) = null,
@Timestamp datetime = null
AS
BEGIN
IF @Type = 'Create'
BEGIN
	IF (SELECT COUNT(*) FROM tbl_User WHERE Username = @Username) >= 1
	BEGIN
		SELECT CAST(0 AS BIT) Response
	END
	ELSE
	BEGIN
		INSERT INTO [tbl_User]
		([Username],[Password],[fname],[mn],[lname],[gender],[email],[address])
		VALUES
		(@Username,@Password,@fname,@mn,@lname,@gender,@email,@address)
		SELECT CAST(1 AS BIT) Response
	END
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Update'
BEGIN
	IF (SELECT COUNT(*) FROM tbl_User WHERE Username = @Username AND ID != @ID) >= 1
	BEGIN
		SELECT CAST(0 AS BIT) Response
	END
	ELSE
	BEGIN
		UPDATE [tbl_User] SET [Username] = @Username
		,[Password] = @Password
		,[Role] = @Role
		,[Active] = @Active
		,[fname] = @fname
		,[mn] = @mn
		,[lname] = @lname
		,[gender] = @gender
		,[email] = @email
		,[address] = @address WHERE [ID] = @ID
		SELECT CAST(1 AS BIT) Response
	END
	
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'UpdateProfile'
BEGIN
	UPDATE [tbl_User] SET [Password] = @Password
		,[fname] = @fname
		,[mn] = @mn
		,[lname] = @lname
		,[gender] = @gender
		,[email] = @email
		,[address] = @address WHERE [ID] = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Search'
BEGIN
	SELECT * FROM [tbl_User] 
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Find'
BEGIN
	SELECT * FROM [tbl_User] WHERE  ID = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Login'
BEGIN
	SELECT * FROM [tbl_User] WHERE HASHBYTES('MD5', Username) = HASHBYTES('MD5', @Username) AND HASHBYTES('MD5', [Password]) = HASHBYTES('MD5', @Password) AND Active = 1
END
END





GO
/****** Object:  Table [dbo].[tbl_Activity]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Activity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NULL,
	[ADate] [datetime] NULL,
	[Activity] [varchar](max) NULL,
	[Encoder] [int] NULL,
	[Timestamp] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Categories]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Categories](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Category] [varchar](max) NULL,
	[Color] [varchar](50) NULL,
	[Timestamp] [datetime] NULL CONSTRAINT [DF__tbl_Categ__Times__182C9B23]  DEFAULT (getdate()),
 CONSTRAINT [PK__tbl_Cate__3214EC27FC904875] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Document]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Document](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Path] [varchar](max) NULL,
	[Filename] [varchar](max) NULL,
	[ReceivedFrom] [varchar](max) NULL,
	[Office] [int] NULL,
	[Category] [int] NULL,
	[Description] [varchar](max) NULL,
	[Encoder] [int] NULL,
	[Date] [datetime] NULL,
	[Timestamp] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Office]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Office](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Office] [varchar](max) NULL,
	[ContactNo] [varchar](max) NULL,
	[Timestamp] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_User]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_User](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](max) NULL,
	[Password] [varchar](max) NULL,
	[Role] [int] NULL DEFAULT ((2)),
	[Active] [bit] NULL DEFAULT ((1)),
	[fname] [varchar](max) NULL,
	[mn] [varchar](max) NULL,
	[lname] [varchar](max) NULL,
	[gender] [varchar](50) NULL,
	[email] [varchar](max) NULL,
	[address] [varchar](max) NULL,
	[Timestamp] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_Activity]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Activity]
AS
SELECT [ID]
      ,[DocumentID]
      ,[ADate]
      ,[Activity]
      ,[Encoder]
	  ,EncoderName = (SELECT CONCAT(fname, ' ', mn, ' ', lname) FROM tbl_User WHERE ID = a.Encoder)
      ,[Timestamp]
  FROM [tbl_Activity] a
GO
/****** Object:  View [dbo].[vw_Categories]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Categories]
AS
SELECT [ID]
      ,[Category]
	  ,Color
	  ,Total = (SELECT COUNT(*) FROM tbl_Document WHERE Category = c.ID)
      ,[Timestamp]
  FROM [tbl_Categories] c




GO
/****** Object:  View [dbo].[vw_Document]    Script Date: 30/01/2024 11:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Document]
AS
SELECT [ID]
      ,[Path]
      ,[Filename]
      ,[QRCode] = CONCAT(FORMAT([Timestamp], 'ddMMMyy'), ' ', ID)
      ,[ReceivedFrom]
      ,[Office]
	  ,OfficeName = (SELECT Office FROM tbl_Office WHERE ID = d.Office)
      ,[Category]
	  ,CategoryName = (SELECT Category FROM tbl_Categories WHERE ID = d.Category)
      ,[Description]
      ,[Encoder]
	  ,EncoderName = (SELECT CONCAT(fname, ' ', mn, ' ', lname) FROM tbl_User WHERE ID = d.Encoder)
      ,[Date]
      ,[Timestamp]
  FROM [tbl_Document] d




GO
USE [master]
GO
ALTER DATABASE [dbDocTrack] SET  READ_WRITE 
GO
