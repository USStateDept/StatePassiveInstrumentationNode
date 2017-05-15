$localDC = (Get-ADDomainController -Discover).HostName[0]
$SearchBase = (Get-ADUser $env:USERNAME -Properties distinguishedname).distinguishedname | % {[regex]::match($_,"(OU=\w+,DC=.*)").Groups[1].Value}
$post = $SearchBase -replace '^OU=|,.*$'
$postSearch = $GLOBAL:post + "*"
$Servers = Get-ADComputer `
    -Server $GLOBAL:localDC `
    -Filter {(OperatingSystem -like "*Server*") -and (name -like $postSearch) -and (Enabled -eq $True)} `
    -Properties Name,DNSHostName,ObjectGUID,SID,IPv4Address,Description  |
    Select -Property `
    @{ Name = "Name" ; Expression = { $_.Name.ToUpper()} } `
    ,DNSHostName `
    ,ObjectGUID `
    ,SID `
    ,IPv4Address `
    ,@{ Name = "Description" ; Expression = { $_.Description.Replace("$GLOBAL:post |","").Trim(" ")} } 

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


foreach($s in $Servers)
{
    $query = "
    INSERT INTO [SPIN].[dbo].[Nodes]
           (
            [Name]
           ,[DNSHostName]
           ,[IPv4Address]
           ,[ObjectGUID]
           ,[SID]
           ,[Description]
            )
     VALUES
           (
            '$($s.Name)'
           ,'$($s.DNSHostName)'
           ,'$($s.IPv4Address)'
           ,'$($s.ObjectGUID)'
           ,'$($s.SID)'
           ,'$($s.Description)'
           )
    "
    invoke-SqlQry -Query $query -ConnectionString $ConnectionString
}
