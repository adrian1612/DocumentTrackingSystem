﻿USE [master]
GO
/****** Object:  Database [dbDocTrack]    Script Date: 10/03/2024 1:44:41 pm ******/
CREATE DATABASE [dbDocTrack]
GO
USE [dbDocTrack]
GO
/****** Object:  StoredProcedure [dbo].[tbl_Categories_Proc]    Script Date: 10/03/2024 1:44:41 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[tbl_Categories_Proc]
@Type VARCHAR(50),
@Search VARCHAR(MAX) = NULL,
@ID INT = NULL,
@Category VARCHAR(MAX) = NULL,
@Color VARCHAR(50) = NULL,
@Deleted BIT = 0,
@Timestamp DATETIME = NULL
AS
BEGIN
IF @Type = 'Create'
BEGIN
	IF (SELECT COUNT(*) FROM tbl_Categories WHERE Category = @Category) >= 1
	BEGIN
		IF (SELECT COUNT(*) FROM tbl_Categories WHERE Category = @Category AND Deleted = 1) >= 1
		BEGIN
			UPDATE tbl_Categories SET Deleted = 0 WHERE Category = @Category
			SELECT CAST(1 AS BIT)
		END
		ELSE
		BEGIN
			SELECT CAST(0 AS BIT)
		END
	END
	ELSE
	BEGIN
		INSERT INTO tbl_Categories (Category, Color) VALUES (@Category, @Color)
		SELECT CAST(1 AS BIT)
	END
END
IF @Type = 'Update'
BEGIN
	IF (SELECT COUNT(*) FROM tbl_Categories WHERE Category = @Category AND ID != @ID) >= 1
	BEGIN
		SELECT CAST(0 AS BIT)
	END
	ELSE
	BEGIN
		UPDATE tbl_Categories SET Category = @Category, Color = @Color WHERE ID = @ID
		SELECT CAST(1 AS BIT)
	END
END
IF @Type = 'Search'
BEGIN
	SELECT * FROM vw_Categories WHERE Deleted = 0
END
IF @Type = 'Find'
BEGIN
	SELECT * FROM vw_Categories WHERE ID = @ID
END
IF @Type = 'Delete'
BEGIN
	UPDATE tbl_Categories SET Deleted = 1 WHERE ID = @ID
END
END
GO
/****** Object:  StoredProcedure [dbo].[tbl_Document_Proc]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	([Path],[Filename],[QRCode],[ReceivedFrom],[Office],[Category],[Description],[Encoder],[Date])
	VALUES
	(@Path,@Filename,@QRCode,@ReceivedFrom,@Office,@Category,@Description,@Encoder,@Date)

	INSERT INTO tbl_Activity (DocumentID,ADate, Activity, Encoder) VALUES (IDENT_CURRENT('tbl_Document'),@Date, 'Document Encoded', @Encoder)
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Update'
BEGIN
	UPDATE [tbl_Document] SET [Path] = @Path
	,[Filename] = @Filename
	,[QRCode] = @QRCode
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
	SELECT * FROM [vw_Document] d WHERE (SELECT QRCode FROM tbl_QRCode WHERE d.QRCode = ID) = @QRCode
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
/****** Object:  StoredProcedure [dbo].[tbl_QRCode_Proc]    Script Date: 10/03/2024 1:44:41 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[tbl_QRCode_Proc]
@Type VARCHAR(50),
@Search VARCHAR(max) = null,
@Count INT = 0,
@ID int = null,
@QRCode varchar(max) = null,
@Encoder int = null,
@Timestamp datetime = null
AS
BEGIN
DECLARE @LastID INT = IDENT_CURRENT('tbl_QRCode')
IF @Type = 'Create'
BEGIN
	WHILE @Count >= 1
	BEGIN
		SET @Count -= 1
		INSERT INTO [tbl_QRCode]
		([QRCode],[Encoder])
		VALUES
		(CONCAT(FORMAT(GETDATE(), 'ddMMyy'), FORMAT(CASE WHEN (SELECT COUNT(*) FROM tbl_QRCode) >= 1 AND IDENT_CURRENT('tbl_QRCode') = 1 THEN 2 ELSE IDENT_CURRENT('tbl_QRCode') END, '0000')), @Encoder)
	END
	SELECT * FROM tbl_QRCode WHERE ID BETWEEN CASE WHEN @LastID = 1 THEN @LastID ELSE @LastID + 1 END AND IDENT_CURRENT('tbl_QRCode')
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Update'
BEGIN
UPDATE [tbl_QRCode] SET [QRCode] = @QRCode
,[Encoder] = @Encoder WHERE [ID] = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Search'
BEGIN
SELECT * FROM [vw_QRCode] ORDER BY ID DESC
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'AvailableQR'
BEGIN
	IF @ID IS NULL
	BEGIN
		SELECT * FROM [vw_QRCode] WHERE ID NOT IN (SELECT QRCode FROM tbl_Document WHERE QRCode IS NOT NULL) ORDER BY ID DESC
	END
	ELSE
	BEGIN
		SELECT * FROM [vw_QRCode] WHERE ID NOT IN (SELECT QRCode FROM tbl_Document WHERE QRCode IS NOT NULL) OR ID = @ID ORDER BY ID DESC
	END
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @Type = 'Find'
BEGIN
SELECT * FROM [vw_QRCode] WHERE  ID = @ID
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------

END



GO
/****** Object:  StoredProcedure [dbo].[tbl_User_Proc]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	IF (SELECT COUNT(*) FROM tbl_User) <= 0
	BEGIN
		INSERT INTO tbl_User ([Username],[Password],[Role],[Active],[fname],[mn],[lname],[gender],[email],[address]) VALUES ('admin', 'admin!!@@', 1, 1, '', '', '', 'Male', '', '')
		SELECT TOP 1 * FROM tbl_User
	END
	ELSE
	BEGIN
		SELECT * FROM [tbl_User] WHERE HASHBYTES('MD5', Username) = HASHBYTES('MD5', @Username) AND HASHBYTES('MD5', [Password]) = HASHBYTES('MD5', @Password) AND Active = 1
	END
END
END






GO
/****** Object:  Table [dbo].[tbl_Activity]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	[Timestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Categories]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	[Deleted] [bit] NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [PK__tbl_Cate__3214EC27FC904875] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Document]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	[QRCode] [int] NULL,
	[ReceivedFrom] [varchar](max) NULL,
	[Office] [int] NULL,
	[Category] [int] NULL,
	[Description] [varchar](max) NULL,
	[Encoder] [int] NULL,
	[Date] [datetime] NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [PK__tbl_Docu__3214EC270F8DC1E5] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Office]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	[Timestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_QRCode]    Script Date: 10/03/2024 1:44:41 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_QRCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[QRCode] [varchar](max) NULL,
	[Encoder] [int] NULL,
	[Timestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_User]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	[Role] [int] NULL,
	[Active] [bit] NULL,
	[fname] [varchar](max) NULL,
	[mn] [varchar](max) NULL,
	[lname] [varchar](max) NULL,
	[gender] [varchar](50) NULL,
	[email] [varchar](max) NULL,
	[address] [varchar](max) NULL,
	[Timestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_Activity]    Script Date: 10/03/2024 1:44:41 pm ******/
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
/****** Object:  View [dbo].[vw_Categories]    Script Date: 10/03/2024 1:44:41 pm ******/
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
	  ,Deleted
      ,[Timestamp]
  FROM [tbl_Categories] c






GO
/****** Object:  View [dbo].[vw_Document]    Script Date: 10/03/2024 1:44:41 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vw_Document]
AS
SELECT [ID]
      ,[Path]
      ,[Filename]
      ,[QRCode]
	  ,QRCodeText = (SELECT QRCode FROM tbl_QRCode WHERE ID = D.QRCode)
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
/****** Object:  View [dbo].[vw_QRCode]    Script Date: 10/03/2024 1:44:41 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_QRCode]
AS
SELECT [ID]
      ,[QRCode]
      ,[Encoder]
	  ,EncoderName = (SELECT CONCAT(fname, ' ', mn, ' ', lname) FROM tbl_User WHERE ID = q.Encoder)
      ,[Timestamp]
  FROM [tbl_QRCode] q

GO
ALTER TABLE [dbo].[tbl_Activity] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_Categories] ADD  CONSTRAINT [DF_tbl_Categories_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[tbl_Categories] ADD  CONSTRAINT [DF__tbl_Categ__Times__182C9B23]  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_Document] ADD  CONSTRAINT [DF__tbl_Docum__Times__1B0907CE]  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_Office] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_QRCode] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_User] ADD  DEFAULT ((2)) FOR [Role]
GO
ALTER TABLE [dbo].[tbl_User] ADD  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[tbl_User] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
USE [master]
GO
ALTER DATABASE [dbDocTrack] SET  READ_WRITE 
GO
