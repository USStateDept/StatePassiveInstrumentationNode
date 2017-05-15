#SPIN V3
## StatePassiveInstrumentationNode
State Passive Instrumentation Node (SPIN) - PowerShell Version

Rough proof of concept for PowerShell backend.  

To test:

Run New_Spin.SQL on your SQL server to create SQL DB named SPIN -- first make sure you do not have another DB named SPIN.

Edit $ConnectionString variable in both ImportNodesFromAD.ps1 and PingUpdate.ps1.

Run ImportNodesFromAD.ps1 to add all your servers from AD to the DB.

Run PingUpdate.ps1 to ping all servers and update the DB--this could be configured to either loop or run as a scheduled task.

- PingUpdate.ps1 requires Windows 8/Server 2012 or later.

Needs web front end.  You can see the ping updates if you run the following query against the SPIN DB: 

SELECT TOP 1000 [NodeID]
      ,[Name]
      ,[PingSucceeded]
      ,[PingTime]
      ,[HopCount]
      ,[RemoteAddress]
      ,[LastModified]
  FROM [SPIN].[dbo].[NodePing]
