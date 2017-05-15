USE [SPIN]
GO

/****** Object:  Table [dbo].[Nodes]    Script Date: 05/11/2017 16:04:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Nodes]') AND type in (N'U'))
DROP TABLE [dbo].[Nodes]
GO

USE [SPIN]
GO

/****** Object:  Table [dbo].[Nodes]    Script Date: 05/11/2017 16:04:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Nodes](
	[ID] [int] IDENTITY(1000000,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[DNSHostName] [varchar](100) NULL,
	[IPv4Address] [varchar](15) NULL,
	[ObjectGUID] [varchar](50) NULL,
	[SID] [varchar](50) NULL,
	[TypeID] [int] NULL,
	[Description] [nvarchar](150) NULL,
	[LastModified] [datetime2] NOT NULL DEFAULT(GETDATE()),
 CONSTRAINT [PK_Nodes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_DNSHostName] UNIQUE NONCLUSTERED 
(
	[DNSHostName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [SPIN]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_NodePing_PingTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[NodePing] DROP CONSTRAINT [DF_NodePing_PingTime]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_NodePing_HopCount]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[NodePing] DROP CONSTRAINT [DF_NodePing_HopCount]
END

GO

USE [SPIN]
GO

/****** Object:  Table [dbo].[NodePing]    Script Date: 05/11/2017 16:05:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NodePing]') AND type in (N'U'))
DROP TABLE [dbo].[NodePing]
GO

USE [SPIN]
GO

/****** Object:  Table [dbo].[NodePing]    Script Date: 05/11/2017 16:05:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[NodePing](
	[NodeID] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[PingSucceeded] [bit] NULL,
	[PingTime] [smallint] NOT NULL,
	[HopCount] [tinyint] NOT NULL,
	[RemoteAddress] [varchar](15) NULL,
	[LastModified] [datetime2] NOT NULL DEFAULT(GETDATE())
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[NodePing] ADD  CONSTRAINT [DF_NodePing_PingTime]  DEFAULT ((32767)) FOR [PingTime]
GO

ALTER TABLE [dbo].[NodePing] ADD  CONSTRAINT [DF_NodePing_HopCount]  DEFAULT ((255)) FOR [HopCount]
GO


USE [SPIN]
GO

/****** Object:  Table [dbo].[NodeTypes]    Script Date: 05/11/2017 16:06:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NodeTypes]') AND type in (N'U'))
DROP TABLE [dbo].[NodeTypes]
GO

USE [SPIN]
GO

/****** Object:  Table [dbo].[NodeTypes]    Script Date: 05/11/2017 16:06:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[NodeTypes](
	[ID] [int] IDENTITY(100,1) NOT NULL,
	[TypeName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_NodeTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [SPIN]
GO

/****** Object:  Table [dbo].[Services]    Script Date: 05/11/2017 16:14:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Services]') AND type in (N'U'))
DROP TABLE [dbo].[Services]
GO

USE [SPIN]
GO

/****** Object:  Table [dbo].[Services]    Script Date: 05/11/2017 16:14:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Services](
	[ID] [int] IDENTITY(1,1000) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[NodeID] [int] NULL,
 CONSTRAINT [PK_Services] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

Create TRIGGER dbo.SetLastModifiedNodes
ON [dbo].[Nodes]
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(LastModified)
    BEGIN
        UPDATE t
            SET t.LastModified = CURRENT_TIMESTAMP 
            FROM dbo.Nodes AS t
            INNER JOIN inserted AS i 
            ON t.ID = i.ID;
    END
END
GO

Create TRIGGER dbo.SetLastModifiedNodePing
ON [dbo].[NodePing]
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(LastModified)
    BEGIN
        UPDATE t
            SET t.LastModified = CURRENT_TIMESTAMP 
            FROM dbo.NodePing AS t
            INNER JOIN inserted AS i 
            ON t.NodeID = i.NodeID;
    END
END
GO