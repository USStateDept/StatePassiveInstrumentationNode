#replace with your SQL connection info. Make sure you replace 1433 with the appropriate port.
$ConnectionString = "Server=SQLSERVER\INSTANCENAME,1433;Database=SPIN;Integrated Security=True"

function invoke-SQLqry{
<# 
    .Synopsis
    Uses ADO .NET to query SQL

    .Description
    Queries a SQL Database and returns a datatable of results

    .Parameter query
    The SQL Query to run
 
    .Parameter parameters
    A list of SQLParameters to pass to the query

    .Parameter connectionString
    Sql Connection string for the DB to connect to

    .Parameter timeout
    timeout property for SQL query. Default is 60 seconds

    .Example
    # run a simple query

    $connectionString = ""
    $parameters = @{}
    Invoke-SqlQuery -query "SELECT GroupID, GroupName From [dbo].[Group] WHERE GroupName=@GroupName" -parameters @{"@GroupName"="genmills\groupName"} -connectionString $connectionString;
    Invoke-SqlQuery -query "SELECT GroupID, GroupName From [dbo].[Group]" -parameters @{} -connectionString $connectionString;
   
#>
    param(
    [string]$query,
    [System.Collections.Hashtable] $parameters,
    [string] $connectionString,
    [int]$timeout=60
    )
    $sqlConnection = new-object System.Data.SqlClient.SqlConnection $connectionString
    $sqlConnection.Open()

    #Create a command object
    $sqlCommand = $sqlConnection.CreateCommand()
    $sqlCommand.CommandText = $query;
    if($parameters)
    {
        foreach($key in $parameters.Keys)
        {
            $sqlCommand.Parameters.AddWithValue($key, $parameters[$key]) | Out-Null
        }
    }
		
	$sqlCommand.CommandTimeout = $timeout

    #Execute the Command
    $sqlReader = $sqlCommand.ExecuteReader()

    $Datatable = New-Object System.Data.DataTable
    $DataTable.Load($SqlReader)
 

    if($sqlConnection -and $sqlConnection.State -ne [System.Data.ConnectionState]::Closed)
    {
        $sqlConnection.Close();
    }
    return $DataTable;
}

$query = "
    SELECT 
       [ID]
      ,[Name]
      ,[DNSHostName]
      ,[IPv4Address]
      ,[ObjectGUID]
      ,[SID]
      ,[Description]
    FROM [SPIN].[dbo].[Nodes]
    "

$nodes = invoke-SqlQry -Query $query -ConnectionString $ConnectionString


$query = "DELETE FROM [SPIN].[dbo].[Nodes] WHERE ID NOT IN ($($nodes.id -join ','))"
invoke-SqlQry -Query $query -ConnectionString $ConnectionString

foreach($n in $nodes)
{
    $n.name
    $scriptBlock = {
        try
        {
            Test-NetConnection $a –TraceRoute -Hops 30 -ErrorAction SilentlyContinue | select RemoteAddress,PingSucceeded,@{name='PingTime';Expression={$_.PingReplyDetails.RoundtripTime}},@{name='HopCount';Expression={$_.TraceRoute.count}}
        }
        catch
        {
            $_.ExceptionMessage
        }
    }
        
    $address = if($n.DNSHostName)
        {
            (Resolve-DnsName $n.DNSHostName -Type A).IPAddress | Where-Object {$_ -match '^10\.'}
        }
        elseif($n.IPv4Address)
        {
            $n.IPv4Address
        } 
    
    $address
    foreach($a in $address)
    {
        $results = . $scriptblock

        $query = "
        SELECT [NodeID]
            ,[Name]
            ,[PingSucceeded]
            ,[PingTime]
            ,[HopCount]
            ,[RemoteAddress]
            ,[LastModified]
        FROM [SPIN].[dbo].[NodePing]
        WHERE [NodeID] = '$($n.ID)' 
            AND [RemoteAddress] = '$a'
        "

        $checkExist = invoke-SqlQry -Query $query -ConnectionString $ConnectionString
        $query = 
            if($checkExist -and $results)
            {
                "
                UPDATE [SPIN].[dbo].[NodePing]
                    SET [Name] = '$($n.Name)'
                        ,[PingSucceeded] = '$($results.PingSucceeded)'
                        ,[PingTime] = '$(if($results.PingSucceeded){$results.PingTime}else{-1})'
                        ,[HopCount] = '$($results.HopCount)'
                        ,[RemoteAddress] = '$($results.RemoteAddress)'
                    WHERE [NodeID] = '$($n.ID)'
                    AND [RemoteAddress] = '$a'
                "
            }
            elseif(!$checkExist -and $results)
            {
                "
                INSERT INTO [SPIN].[dbo].[NodePing]
                    ([NodeID]
                    ,[Name]
                    ,[PingSucceeded]
                    ,[PingTime]
                    ,[HopCount]
                    ,[RemoteAddress])
                VALUES
                    (
                    '$($n.ID)'
                    ,'$($n.Name)'
                    ,'$($results.PingSucceeded)'
                    ,'$(if($results.PingSucceeded){$results.PingTime}else{-1})'
                    ,'$($results.HopCount)'
                    ,'$($results.RemoteAddress)'
                    )
                "
            }
        invoke-SqlQry -Query $query -ConnectionString $ConnectionString
    }
}
