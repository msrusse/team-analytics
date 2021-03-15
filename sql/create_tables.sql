USE [teamAnalytics]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[electionResult]') AND type in (N'U'))
DROP TABLE [dbo].[electionResult]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[candidate]') AND type in (N'U'))
DROP TABLE [dbo].[candidate]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[party]') AND type in (N'U'))
DROP TABLE [dbo].[party]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[countyPopulation]') AND type in (N'U'))
DROP TABLE [dbo].[countyPopulation]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[icuBeds]') AND type in (N'U'))
DROP TABLE [dbo].[icuBeds]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[caseInfo]') AND type in (N'U'))
DROP TABLE [dbo].[caseInfo]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deathInfo]') AND type in (N'U'))
DROP TABLE [dbo].[deathInfo]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[countyInfo]') AND type in (N'U'))
DROP TABLE [dbo].[countyInfo]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[state]') AND type in (N'U'))
DROP TABLE [dbo].[state]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[state](
	[stateAbbrev] [char](2) NOT NULL,
	[stateName] [char](25) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[state] ADD PRIMARY KEY CLUSTERED 
(
	[stateAbbrev] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


CREATE TABLE [dbo].[countyInfo](
	[FIPSCode] [char](5) NOT NULL,
	[stateFIPS] [char](2) NOT NULL,
	[countyFIPS] [char](3) NOT NULL,
	[stateAbbrev] [char](2) NOT NULL,
	[countyName] [varchar](30) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countyInfo] ADD PRIMARY KEY CLUSTERED 
(
	[FIPSCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countyInfo]  WITH CHECK ADD FOREIGN KEY([stateAbbrev])
REFERENCES [dbo].[state] ([stateAbbrev])
GO

CREATE TABLE [dbo].[deathInfo](
	[deathID] [int] IDENTITY(1,1) NOT NULL,
	[FIPSCode] [char](5) NOT NULL,
	[recordedDate] [date] NOT NULL,
	[totalToDate] [int] NOT NULL,
	[amountChange] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deathInfo] ADD PRIMARY KEY CLUSTERED 
(
	[deathID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deathInfo] ADD  DEFAULT ((0)) FOR [amountChange]
GO
ALTER TABLE [dbo].[deathInfo]  WITH CHECK ADD FOREIGN KEY([FIPSCode])
REFERENCES [dbo].[countyInfo] ([FIPSCode])
GO

CREATE TABLE [dbo].[caseInfo](
	[caseID] [int] IDENTITY(1,1) NOT NULL,
	[FIPSCode] [char](5) NOT NULL,
	[recordedDate] [date] NOT NULL,
	[totalToDate] [int] NOT NULL,
	[amountChange] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[caseInfo] ADD PRIMARY KEY CLUSTERED 
(
	[caseID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[caseInfo] ADD  DEFAULT ((0)) FOR [amountChange]
GO
ALTER TABLE [dbo].[caseInfo]  WITH CHECK ADD FOREIGN KEY([FIPSCode])
REFERENCES [dbo].[countyInfo] ([FIPSCode])
GO

CREATE TABLE [dbo].[icuBeds](
	[FIPSCode] [char](5) NOT NULL,
	[icuBedCount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icuBeds] ADD PRIMARY KEY CLUSTERED 
(
	[FIPSCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icuBeds]  WITH CHECK ADD FOREIGN KEY([FIPSCode])
REFERENCES [dbo].[countyInfo] ([FIPSCode])
GO


CREATE TABLE [dbo].[countyPopulation](
	[FIPSCode] [char](5) NOT NULL,
	[totalPopulation] [int] NOT NULL,
	[totalPopulationOver60] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countyPopulation] ADD PRIMARY KEY CLUSTERED 
(
	[FIPSCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countyPopulation]  WITH CHECK ADD FOREIGN KEY([FIPSCode])
REFERENCES [dbo].[countyInfo] ([FIPSCode])
GO

CREATE TABLE [dbo].[party](
	[partyID] [char](3) NOT NULL,
	[partyName] [varchar](35) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[party] ADD PRIMARY KEY CLUSTERED 
(
	[partyID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


CREATE TABLE [dbo].[candidate](
	[candidateID] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](25) NULL,
	[lastName] [varchar](35) NULL,
	[partyID] [char](3) NULL,
	[candidateType] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[candidate] ADD PRIMARY KEY CLUSTERED 
(
	[candidateID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[candidate]  WITH CHECK ADD FOREIGN KEY([partyID])
REFERENCES [dbo].[party] ([partyID])
GO

CREATE TABLE [dbo].[electionResult](
	[electionResultID] [int] IDENTITY(1,1) NOT NULL,
	[FIPSCode] [char](5) NOT NULL,
	[candidateID] [int] NOT NULL,
	[totalVotes] [int] NOT NULL,
	[won] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[electionResult] ADD PRIMARY KEY CLUSTERED 
(
	[electionResultID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[electionResult]  WITH CHECK ADD FOREIGN KEY([candidateID])
REFERENCES [dbo].[candidate] ([candidateID])
GO
ALTER TABLE [dbo].[electionResult]  WITH CHECK ADD FOREIGN KEY([FIPSCode])
REFERENCES [dbo].[countyInfo] ([FIPSCode])
GO