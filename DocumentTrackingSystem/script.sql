USE [master]
GO
/****** Object:  Database [dbDocTrack]    Script Date: 06/02/2024 2:05:37 pm ******/
CREATE DATABASE [dbDocTrack]
GO
USE [dbDocTrack]
GO
/****** Object:  StoredProcedure [dbo].[tbl_Document_Proc]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  StoredProcedure [dbo].[tbl_QRCode_Proc]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  StoredProcedure [dbo].[tbl_User_Proc]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  Table [dbo].[tbl_Activity]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  Table [dbo].[tbl_Categories]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  Table [dbo].[tbl_Document]    Script Date: 06/02/2024 2:05:37 pm ******/
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
	[Timestamp] [datetime] NULL CONSTRAINT [DF__tbl_Docum__Times__1B0907CE]  DEFAULT (getdate()),
 CONSTRAINT [PK__tbl_Docu__3214EC270F8DC1E5] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Office]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  Table [dbo].[tbl_QRCode]    Script Date: 06/02/2024 2:05:37 pm ******/
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
	[Timestamp] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_User]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  View [dbo].[vw_Activity]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  View [dbo].[vw_Categories]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  View [dbo].[vw_Document]    Script Date: 06/02/2024 2:05:37 pm ******/
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
/****** Object:  View [dbo].[vw_QRCode]    Script Date: 06/02/2024 2:05:37 pm ******/
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
SET IDENTITY_INSERT [dbo].[tbl_Activity] ON 

GO
INSERT [dbo].[tbl_Activity] ([ID], [DocumentID], [ADate], [Activity], [Encoder], [Timestamp]) VALUES (1, 1, CAST(N'2024-01-30 11:08:00.000' AS DateTime), N'Deliver to billing department', 1, CAST(N'2024-01-30 11:08:38.260' AS DateTime))
GO
INSERT [dbo].[tbl_Activity] ([ID], [DocumentID], [ADate], [Activity], [Encoder], [Timestamp]) VALUES (2, 2, CAST(N'2024-01-30 11:12:00.000' AS DateTime), N'Received Documents', 1, CAST(N'2024-01-30 11:12:22.043' AS DateTime))
GO
INSERT [dbo].[tbl_Activity] ([ID], [DocumentID], [ADate], [Activity], [Encoder], [Timestamp]) VALUES (3, 2049, CAST(N'2024-01-30 11:13:00.000' AS DateTime), NULL, 1, CAST(N'2024-01-30 11:13:22.867' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tbl_Activity] OFF
GO
SET IDENTITY_INSERT [dbo].[tbl_Categories] ON 

GO
INSERT [dbo].[tbl_Categories] ([ID], [Category], [Color], [Timestamp]) VALUES (1, N'Clearance', N'#a25353', CAST(N'2024-01-23 08:47:08.890' AS DateTime))
GO
INSERT [dbo].[tbl_Categories] ([ID], [Category], [Color], [Timestamp]) VALUES (2, N'Communication', N'#409695', CAST(N'2024-01-23 08:55:36.147' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tbl_Categories] OFF
GO
SET IDENTITY_INSERT [dbo].[tbl_Document] ON 

GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', 10, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-23 11:24:24.610' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:33:56.153' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (3, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:34:25.060' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (4, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', 5, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:34:44.557' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (5, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:18.377' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (6, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:18.377' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (7, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:18.377' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (8, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:18.377' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (9, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (10, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (11, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (12, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (13, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (14, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (15, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (16, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:19.473' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (17, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (18, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (19, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (20, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (21, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (22, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (23, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (24, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (25, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (26, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (27, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (28, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (29, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (30, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (31, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (32, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.033' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (33, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (34, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (35, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (36, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (37, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (38, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (39, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (40, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (41, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (42, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (43, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (44, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (45, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (46, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (47, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (48, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (49, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (50, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (51, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (52, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (53, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (54, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (55, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (56, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (57, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (58, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (59, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (60, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (61, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (62, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (63, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (64, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:20.550' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (65, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (66, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (67, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (68, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (69, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (70, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (71, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (72, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (73, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (74, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (75, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (76, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (77, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (78, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (79, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (80, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (81, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (82, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (83, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (84, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (85, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (86, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (87, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (88, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (89, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (90, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (91, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (92, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (93, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (94, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (95, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (96, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (97, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (98, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (99, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (100, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (101, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (102, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (103, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (104, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (105, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (106, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (107, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (108, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (109, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (110, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (111, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (112, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (113, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (114, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (115, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (116, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (117, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (118, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (119, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (120, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (121, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (122, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (123, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (124, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (125, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (126, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (127, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (128, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.093' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (129, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (130, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (131, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (132, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (133, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (134, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (135, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (136, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (137, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (138, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (139, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (140, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (141, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (142, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (143, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (144, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (145, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (146, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (147, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (148, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (149, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (150, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (151, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (152, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (153, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (154, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (155, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (156, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (157, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (158, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (159, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (160, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (161, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (162, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (163, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (164, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (165, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (166, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (167, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (168, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (169, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (170, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (171, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (172, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (173, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (174, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (175, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (176, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (177, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (178, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (179, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (180, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (181, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (182, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (183, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (184, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (185, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (186, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (187, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (188, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (189, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (190, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (191, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (192, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (193, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (194, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (195, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (196, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (197, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (198, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (199, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (200, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (201, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (202, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (203, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (204, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (205, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (206, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (207, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (208, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (209, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (210, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (211, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (212, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (213, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (214, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (215, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (216, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (217, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (218, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (219, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (220, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (221, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (222, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (223, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (224, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (225, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (226, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (227, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (228, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (229, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (230, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (231, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (232, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (233, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (234, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (235, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (236, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (237, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (238, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (239, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (240, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (241, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (242, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (243, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (244, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (245, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (246, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (247, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (248, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (249, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (250, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (251, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (252, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (253, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (254, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (255, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (256, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:22.630' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (257, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (258, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (259, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (260, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (261, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (262, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (263, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (264, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (265, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (266, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (267, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (268, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (269, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (270, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (271, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (272, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (273, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (274, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (275, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (276, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (277, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (278, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (279, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (280, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (281, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (282, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (283, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (284, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (285, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (286, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (287, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (288, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (289, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (290, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (291, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (292, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (293, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (294, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (295, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (296, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (297, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (298, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (299, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (300, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (301, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (302, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (303, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (304, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (305, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (306, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (307, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (308, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (309, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (310, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (311, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (312, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (313, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (314, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (315, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (316, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (317, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (318, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (319, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (320, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (321, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (322, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (323, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (324, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (325, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (326, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (327, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (328, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (329, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (330, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (331, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (332, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (333, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (334, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (335, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (336, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (337, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (338, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (339, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (340, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (341, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (342, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (343, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (344, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (345, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (346, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (347, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (348, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (349, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (350, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (351, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (352, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (353, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (354, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (355, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (356, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (357, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (358, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (359, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (360, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (361, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (362, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (363, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (364, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (365, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (366, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (367, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (368, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (369, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (370, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (371, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (372, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (373, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (374, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (375, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (376, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (377, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (378, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (379, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (380, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (381, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (382, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (383, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (384, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (385, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (386, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (387, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (388, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (389, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (390, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (391, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (392, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (393, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (394, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (395, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (396, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (397, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (398, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (399, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (400, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (401, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (402, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (403, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (404, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (405, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (406, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (407, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (408, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (409, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (410, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (411, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (412, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (413, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (414, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (415, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (416, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (417, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (418, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (419, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (420, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (421, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (422, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (423, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (424, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (425, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (426, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (427, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (428, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (429, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (430, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (431, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (432, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (433, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (434, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (435, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (436, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (437, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (438, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (439, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (440, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (441, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (442, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (443, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (444, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (445, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (446, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (447, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (448, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (449, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (450, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (451, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (452, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (453, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (454, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (455, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (456, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (457, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (458, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (459, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (460, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (461, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (462, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (463, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (464, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (465, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (466, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (467, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (468, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (469, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (470, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (471, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (472, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (473, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (474, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (475, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (476, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (477, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (478, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (479, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (480, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (481, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (482, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (483, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (484, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (485, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (486, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (487, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (488, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (489, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (490, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (491, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (492, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (493, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (494, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (495, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (496, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (497, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (498, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (499, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (500, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (501, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (502, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (503, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (504, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (505, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (506, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (507, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (508, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (509, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (510, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (511, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (512, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:34.767' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (513, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (514, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (515, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (516, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (517, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (518, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (519, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (520, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (521, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (522, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (523, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (524, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (525, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (526, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (527, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (528, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (529, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (530, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (531, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (532, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (533, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (534, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (535, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (536, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (537, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (538, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (539, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (540, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (541, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (542, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (543, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (544, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (545, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (546, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (547, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (548, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (549, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (550, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (551, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (552, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (553, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (554, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (555, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (556, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (557, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (558, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (559, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (560, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (561, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (562, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (563, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (564, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (565, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (566, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (567, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (568, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (569, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (570, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (571, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (572, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (573, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (574, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (575, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (576, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (577, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (578, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (579, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (580, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (581, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (582, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (583, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (584, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (585, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (586, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (587, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (588, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (589, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (590, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (591, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (592, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (593, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (594, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (595, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (596, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (597, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (598, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (599, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (600, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (601, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (602, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (603, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (604, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (605, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (606, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (607, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (608, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (609, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (610, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (611, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (612, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (613, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (614, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (615, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (616, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (617, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (618, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (619, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (620, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (621, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (622, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (623, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (624, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (625, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (626, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (627, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (628, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (629, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (630, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (631, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (632, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (633, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (634, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (635, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (636, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (637, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (638, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (639, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (640, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (641, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (642, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (643, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (644, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (645, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (646, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (647, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (648, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (649, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (650, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (651, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (652, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (653, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (654, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (655, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (656, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (657, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (658, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (659, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (660, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (661, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (662, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (663, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (664, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (665, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (666, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (667, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (668, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (669, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (670, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (671, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (672, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (673, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (674, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (675, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (676, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (677, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (678, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (679, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (680, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (681, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (682, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (683, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (684, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (685, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (686, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (687, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (688, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (689, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (690, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (691, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (692, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (693, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (694, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (695, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (696, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (697, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (698, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (699, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (700, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (701, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (702, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (703, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (704, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (705, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (706, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (707, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (708, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (709, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (710, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (711, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (712, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (713, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (714, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (715, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (716, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (717, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (718, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (719, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (720, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (721, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (722, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (723, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (724, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (725, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (726, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (727, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (728, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (729, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (730, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (731, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (732, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (733, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (734, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (735, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (736, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (737, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (738, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (739, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (740, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (741, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (742, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (743, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (744, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (745, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (746, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (747, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (748, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (749, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (750, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (751, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (752, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (753, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (754, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (755, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (756, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (757, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (758, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (759, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (760, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (761, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (762, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (763, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (764, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (765, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (766, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (767, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (768, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (769, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (770, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (771, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (772, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (773, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (774, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (775, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (776, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (777, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (778, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (779, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (780, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (781, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (782, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (783, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (784, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (785, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (786, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (787, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (788, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (789, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (790, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (791, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (792, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (793, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (794, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (795, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (796, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (797, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (798, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (799, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (800, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (801, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (802, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (803, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (804, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (805, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (806, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (807, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (808, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (809, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (810, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (811, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (812, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (813, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (814, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (815, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (816, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (817, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (818, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (819, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (820, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (821, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (822, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (823, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (824, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (825, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (826, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (827, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (828, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (829, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (830, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (831, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (832, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (833, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (834, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (835, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (836, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (837, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (838, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (839, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (840, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (841, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (842, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (843, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (844, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (845, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (846, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (847, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (848, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (849, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (850, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (851, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (852, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (853, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (854, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (855, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (856, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (857, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (858, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (859, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (860, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (861, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (862, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (863, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (864, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (865, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (866, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (867, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (868, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (869, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (870, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (871, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (872, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (873, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (874, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (875, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (876, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (877, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (878, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (879, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (880, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (881, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (882, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (883, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (884, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (885, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (886, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (887, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (888, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (889, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (890, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (891, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (892, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (893, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (894, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (895, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (896, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (897, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (898, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (899, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (900, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (901, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (902, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (903, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (904, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (905, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (906, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (907, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (908, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (909, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (910, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (911, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (912, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (913, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (914, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (915, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (916, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (917, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (918, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (919, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (920, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (921, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (922, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (923, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (924, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (925, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (926, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (927, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (928, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (929, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (930, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (931, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (932, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (933, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (934, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (935, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (936, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (937, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (938, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (939, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (940, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (941, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (942, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (943, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (944, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (945, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (946, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (947, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (948, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (949, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (950, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (951, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (952, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (953, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (954, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (955, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (956, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (957, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (958, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (959, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (960, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (961, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (962, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (963, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (964, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (965, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (966, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (967, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (968, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (969, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (970, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (971, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (972, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (973, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (974, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (975, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (976, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (977, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (978, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (979, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (980, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (981, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (982, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (983, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (984, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (985, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (986, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (987, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (988, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (989, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (990, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (991, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (992, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (993, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (994, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (995, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (996, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (997, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (998, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (999, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1000, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1001, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1002, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1003, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1004, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1005, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1006, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1007, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1008, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1009, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1010, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1011, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1012, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1013, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1014, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1015, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1016, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1017, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1018, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1019, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1020, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1021, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1022, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1023, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1024, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:35.307' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1025, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1026, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1027, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1028, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1029, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1030, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1031, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1032, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1033, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1034, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1035, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1036, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1037, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1038, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1039, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1040, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1041, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1042, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1043, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1044, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1045, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1046, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1047, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1048, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1049, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1050, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1051, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1052, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1053, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1054, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1055, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1056, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1057, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1058, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1059, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1060, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1061, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1062, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1063, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1064, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1065, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1066, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1067, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1068, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1069, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1070, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1071, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1072, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1073, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1074, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1075, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1076, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1077, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1078, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1079, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1080, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1081, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1082, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1083, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1084, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1085, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1086, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1087, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1088, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1089, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1090, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1091, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1092, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1093, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1094, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1095, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1096, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1097, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1098, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1099, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1100, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1101, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1102, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1103, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1104, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1105, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1106, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1107, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1108, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1109, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1110, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1111, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1112, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1113, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1114, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1115, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1116, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1117, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1118, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1119, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1120, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1121, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1122, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1123, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1124, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1125, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1126, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1127, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1128, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1129, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1130, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1131, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1132, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1133, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1134, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1135, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1136, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1137, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1138, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1139, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1140, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1141, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1142, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1143, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1144, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1145, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1146, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1147, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1148, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1149, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1150, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1151, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1152, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1153, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1154, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1155, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1156, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1157, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1158, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1159, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1160, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1161, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1162, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1163, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1164, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1165, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1166, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1167, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1168, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1169, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1170, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1171, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1172, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1173, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1174, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1175, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1176, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1177, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1178, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1179, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1180, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1181, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1182, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1183, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1184, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1185, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1186, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1187, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1188, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1189, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1190, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1191, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1192, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1193, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1194, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1195, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1196, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1197, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1198, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1199, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1200, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1201, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1202, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1203, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1204, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1205, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1206, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1207, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1208, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1209, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1210, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1211, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1212, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1213, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1214, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1215, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1216, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1217, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1218, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1219, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1220, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1221, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1222, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1223, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1224, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1225, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1226, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1227, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1228, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1229, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1230, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1231, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1232, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1233, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1234, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1235, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1236, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1237, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1238, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1239, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1240, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1241, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1242, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1243, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1244, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1245, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1246, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1247, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1248, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1249, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1250, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1251, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1252, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1253, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1254, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1255, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1256, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1257, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1258, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1259, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1260, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1261, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1262, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1263, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1264, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1265, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1266, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1267, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1268, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1269, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1270, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1271, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1272, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1273, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1274, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1275, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1276, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1277, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1278, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1279, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1280, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1281, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1282, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1283, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1284, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1285, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1286, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1287, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1288, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1289, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1290, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1291, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1292, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1293, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1294, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1295, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1296, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1297, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1298, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1299, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1300, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1301, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1302, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1303, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1304, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1305, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1306, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1307, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1308, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1309, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1310, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1311, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1312, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1313, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1314, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1315, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1316, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1317, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1318, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1319, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1320, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1321, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1322, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1323, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1324, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1325, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1326, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1327, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1328, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1329, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1330, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1331, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1332, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1333, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1334, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1335, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1336, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1337, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1338, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1339, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1340, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1341, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1342, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1343, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1344, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1345, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1346, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1347, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1348, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1349, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1350, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1351, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1352, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1353, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1354, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1355, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1356, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1357, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1358, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1359, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1360, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1361, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1362, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1363, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1364, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1365, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1366, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1367, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1368, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1369, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1370, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1371, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1372, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1373, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1374, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1375, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1376, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1377, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1378, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1379, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1380, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1381, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1382, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1383, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1384, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1385, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1386, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1387, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1388, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1389, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1390, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1391, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1392, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1393, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1394, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1395, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1396, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1397, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1398, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1399, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1400, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1401, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1402, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1403, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1404, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1405, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1406, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1407, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1408, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1409, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1410, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1411, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1412, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1413, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1414, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1415, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1416, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1417, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1418, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1419, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1420, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1421, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1422, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1423, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1424, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1425, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1426, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1427, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1428, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1429, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1430, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1431, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1432, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1433, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1434, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1435, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1436, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1437, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1438, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1439, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1440, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1441, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1442, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1443, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1444, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1445, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1446, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1447, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1448, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1449, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1450, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1451, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1452, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1453, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1454, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1455, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1456, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1457, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1458, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1459, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1460, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1461, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1462, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1463, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1464, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1465, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1466, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1467, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1468, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1469, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1470, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1471, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1472, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1473, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1474, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1475, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1476, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1477, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1478, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1479, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1480, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1481, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1482, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1483, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1484, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1485, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1486, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1487, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1488, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1489, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1490, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1491, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1492, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1493, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1494, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1495, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1496, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1497, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1498, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1499, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1500, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1501, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1502, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1503, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1504, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1505, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1506, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1507, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1508, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1509, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1510, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1511, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1512, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1513, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1514, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1515, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1516, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1517, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1518, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1519, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1520, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1521, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1522, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1523, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1524, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1525, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1526, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1527, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1528, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1529, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1530, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1531, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1532, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1533, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1534, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1535, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1536, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1537, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1538, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1539, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1540, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1541, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1542, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1543, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1544, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1545, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1546, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1547, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1548, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1549, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1550, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1551, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1552, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1553, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1554, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1555, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1556, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1557, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1558, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1559, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1560, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1561, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1562, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1563, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1564, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1565, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1566, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1567, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1568, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1569, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1570, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1571, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1572, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1573, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1574, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1575, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1576, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1577, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1578, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1579, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1580, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1581, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1582, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1583, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1584, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1585, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1586, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1587, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1588, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1589, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1590, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1591, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1592, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1593, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1594, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1595, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1596, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1597, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1598, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1599, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1600, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1601, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1602, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1603, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1604, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1605, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1606, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1607, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1608, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1609, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1610, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1611, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1612, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1613, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1614, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1615, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1616, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1617, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1618, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1619, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1620, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1621, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1622, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1623, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1624, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1625, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1626, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1627, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1628, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1629, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1630, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1631, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1632, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1633, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1634, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1635, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1636, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1637, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1638, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1639, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1640, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1641, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1642, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1643, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1644, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1645, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1646, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1647, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1648, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1649, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1650, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1651, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1652, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1653, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1654, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1655, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1656, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1657, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1658, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1659, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1660, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1661, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1662, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1663, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1664, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1665, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1666, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1667, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1668, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1669, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1670, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1671, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1672, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1673, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1674, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1675, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1676, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1677, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1678, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1679, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1680, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1681, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1682, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1683, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1684, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1685, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1686, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1687, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1688, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1689, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1690, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1691, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1692, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1693, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1694, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1695, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1696, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1697, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1698, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1699, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1700, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1701, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1702, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1703, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1704, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1705, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1706, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1707, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1708, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1709, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1710, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1711, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1712, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1713, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1714, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1715, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1716, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1717, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1718, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1719, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1720, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1721, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1722, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1723, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1724, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1725, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1726, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1727, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1728, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1729, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1730, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1731, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1732, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1733, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1734, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1735, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1736, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1737, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1738, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1739, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1740, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1741, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1742, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1743, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1744, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1745, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1746, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1747, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1748, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1749, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1750, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1751, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1752, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1753, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1754, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1755, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1756, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1757, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1758, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1759, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1760, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1761, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1762, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1763, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1764, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1765, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1766, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1767, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1768, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1769, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1770, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1771, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1772, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1773, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1774, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1775, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1776, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1777, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1778, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1779, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1780, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1781, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1782, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1783, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1784, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1785, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1786, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1787, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1788, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1789, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1790, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1791, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1792, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1793, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1794, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1795, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1796, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1797, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1798, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1799, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1800, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1801, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1802, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1803, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1804, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1805, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1806, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1807, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1808, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1809, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1810, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1811, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1812, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1813, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1814, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1815, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1816, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1817, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1818, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1819, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1820, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1821, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1822, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1823, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1824, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1825, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1826, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1827, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1828, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1829, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1830, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1831, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1832, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1833, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1834, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1835, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1836, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1837, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1838, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1839, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1840, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1841, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1842, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1843, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1844, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1845, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1846, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1847, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1848, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1849, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1850, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1851, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1852, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1853, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1854, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1855, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1856, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1857, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1858, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1859, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1860, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1861, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1862, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1863, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1864, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1865, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1866, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1867, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1868, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1869, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1870, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1871, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1872, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1873, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1874, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1875, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1876, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1877, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1878, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1879, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1880, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1881, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1882, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1883, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1884, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1885, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1886, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1887, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1888, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1889, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1890, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1891, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1892, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1893, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1894, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1895, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1896, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1897, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1898, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1899, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1900, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1901, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1902, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1903, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1904, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1905, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1906, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1907, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1908, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1909, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1910, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1911, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1912, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1913, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1914, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1915, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1916, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1917, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1918, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1919, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1920, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1921, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1922, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1923, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1924, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1925, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1926, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1927, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1928, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1929, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1930, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1931, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1932, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1933, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1934, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1935, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1936, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1937, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1938, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1939, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1940, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1941, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1942, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1943, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1944, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1945, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1946, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1947, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1948, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1949, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1950, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1951, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1952, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1953, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1954, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1955, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1956, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1957, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1958, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1959, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1960, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1961, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1962, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1963, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1964, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1965, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1966, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1967, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1968, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1969, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1970, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1971, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1972, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1973, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1974, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1975, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1976, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1977, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1978, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1979, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1980, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1981, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1982, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1983, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1984, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1985, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1986, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1987, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1988, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1989, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1990, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1991, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1992, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1993, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1994, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1995, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1996, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1997, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1998, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (1999, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2000, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2001, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2002, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2003, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2004, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2005, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2006, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2007, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2008, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2009, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2010, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2011, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2012, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2013, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2014, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2015, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2016, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2017, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2018, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2019, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2020, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2021, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2022, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2023, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2024, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2025, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2026, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2027, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2028, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2029, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2030, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2031, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2032, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2033, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2034, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2035, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2036, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2037, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2038, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2039, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2040, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2041, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2042, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', 6, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2043, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2044, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2045, N'~/Attachment/Clearance/Adrian Japsio/b885f3a6-64bc-4af8-9e92-a7c42cdfab14.pdf', N'G3L8E-1728866.pdf', NULL, N'Adrian Japsio', 1, 1, N'Clearance', 1, CAST(N'2024-01-23 11:24:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2046, N'~/Attachment/Clearance/Adrian Japsio/938dfbc9-59a6-4b45-aba2-5918ae28556b.png', N'mayogrouplogo.png', NULL, N'Adrian Japsio', 1, 1, N'logo', 1, CAST(N'2024-01-29 10:33:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2047, N'~/Attachment/Communication/Adrian Japsio/357499a5-b53d-475f-a561-b27af9845af6.jpg', N'noimage.jpg', NULL, N'Adrian Japsio', 1, 2, N'ad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2048, N'~/Attachment/Clearance/Adrian Japsio/2d9f3a5b-cbb6-4bdc-a5fd-5f847cef2a2a.png', N'logo.png', NULL, N'Adrian Japsio', 1, 1, N'adad', 1, CAST(N'2024-01-29 10:34:00.000' AS DateTime), CAST(N'2024-01-29 10:36:46.640' AS DateTime))
GO
INSERT [dbo].[tbl_Document] ([ID], [Path], [Filename], [QRCode], [ReceivedFrom], [Office], [Category], [Description], [Encoder], [Date], [Timestamp]) VALUES (2049, N'~/Attachment/Clearance/Micheal Jackson/7c86328a-de84-46cc-a3c2-294690a1e14d.jpg', N'noimage2.jpg', 7, N'Micheal Jackson', 1, 1, N'asdasdasdsa', 1, CAST(N'2024-01-30 11:13:00.000' AS DateTime), CAST(N'2024-01-30 11:13:22.867' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tbl_Document] OFF
GO
SET IDENTITY_INSERT [dbo].[tbl_Office] ON 

GO
INSERT [dbo].[tbl_Office] ([ID], [Office], [ContactNo], [Timestamp]) VALUES (1, N'Registrar', N'09194291969', CAST(N'2024-01-23 08:53:32.380' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tbl_Office] OFF
GO
SET IDENTITY_INSERT [dbo].[tbl_QRCode] ON 

GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (1, N'0202240001', 1, CAST(N'2024-02-02 14:36:16.627' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (2, N'0202240002', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (3, N'0202240003', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (4, N'0202240004', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (5, N'0202240005', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (6, N'0202240006', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (7, N'0202240007', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (8, N'0202240008', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (9, N'0202240009', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (10, N'0202240010', 1, CAST(N'2024-02-02 14:36:16.630' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (11, N'0202240011', 1, CAST(N'2024-02-02 15:24:26.960' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (12, N'0202240012', 1, CAST(N'2024-02-02 15:24:26.960' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (13, N'0202240013', 1, CAST(N'2024-02-02 15:24:26.960' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (14, N'0202240014', 1, CAST(N'2024-02-02 15:24:26.960' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (15, N'0202240015', 1, CAST(N'2024-02-02 15:24:26.960' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (16, N'0202240016', 1, CAST(N'2024-02-02 15:24:26.960' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (17, N'0202240017', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (18, N'0202240018', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (19, N'0202240019', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (20, N'0202240020', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (21, N'0202240021', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (22, N'0202240022', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (23, N'0202240023', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (24, N'0202240024', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (25, N'0202240025', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (26, N'0202240026', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (27, N'0202240027', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (28, N'0202240028', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (29, N'0202240029', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (30, N'0202240030', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
INSERT [dbo].[tbl_QRCode] ([ID], [QRCode], [Encoder], [Timestamp]) VALUES (31, N'0202240031', 1, CAST(N'2024-02-02 15:24:26.963' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tbl_QRCode] OFF
GO
SET IDENTITY_INSERT [dbo].[tbl_User] ON 

GO
INSERT [dbo].[tbl_User] ([ID], [Username], [Password], [Role], [Active], [fname], [mn], [lname], [gender], [email], [address], [Timestamp]) VALUES (1, N'admin', N'admin!!@@', 2, 1, N'Adrian', N'Aranilla', N'Jaspio', N'Male', N'adrianjaspio@gamil.com', N'94 Milagrosa, Calamba City
MAYO HOLDINGS AND CONSTRUCTION INC.', CAST(N'2024-01-23 08:46:26.873' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tbl_User] OFF
GO
USE [master]
GO
ALTER DATABASE [dbDocTrack] SET  READ_WRITE 
GO
