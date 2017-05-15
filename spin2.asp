<%@ Language=VBScript %>

<html>

<head>
<meta http-equiv="refresh" content="15">

<style type="text/css">
.style1 {
	text-align: left;
}
</style>

</head>
<body>
<basefont face="Arial">
     

<%
dim strUTCTime, objcomputer

ON ERROR RESUME NEXT
strUTCTime = now
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colTime = objWMIService.ExecQuery("Select * from Win32_UTCTime")
For Each objTime in colTime
	If Len(objTime.Hour) < 2 Then strZhour = "0" & objTime.Hour Else strZhour = objTime.Hour
	If Len(objTime.Minute) < 2 Then strZminute = "0" & objTime.Minute Else strZminute = objTime.Minute
strUTCtime = strZhour & ":" & strZminute
DCTime = DateAdd("h",-12,now)
DCTime = DateAdd("n",,DCTime)
NEXT
%>


<!---------------------CLOCK TOWER------------------------------->

<table width=100% bgcolor=black>
<tr align=center>
	<td> <font color=white> <b> <font color=white size=6><% response.Write(formatdatetime(time,4)) %> </font> </b>  </td>
	<td> <b> <font color=white size=6> <% response.Write(strUTCtime) %> </font> </b>  </td>
	<td> <font color=white size=6><b>    <% response.Write(formatdatetime(DCTime,4)) %> </b></font> </td>
</tr>
<tr align=center>
	
<td><b><font color=white size=6>POSTNAME</td>

	<td><b><font color=white size=6>ZULU</td>

	<td><b><font color=white size=6>EDT</td>
</tr>

</table>

<!-----------------END CLOCK TOWER------------------------------->

<table width=100% style='filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr=#ffffff, startColorstr=#000000, gradientType='2');'>
	<tr><td align=right colspan="3"><font size=5 color=red>SPIN</font><font size=5 color=red> | POSTNAME </td></tr>
	<tr><td align=right colspan="3">State Passive Instrumentation Node </font></td></tr>
</table>

<!-----------------OPEN MASTER TABLES----------------------------->

<table><tr><td valign=top>

<% 
Dim strSite,arrLatency

'------------------------------------------
'------------------------------------------
'------------------------------------------
'------------------------------------------
'------------Returns Latency as strLatency
Dim arrSite(14,1) '-------- Set the first number to the total number of sites you are pinging below, starting with 0

ON ERROR RESUME NEXT


arrSite(0,0) = "displaynameofobject"
arrSite(0,1) = "DestinationName/IP" 

arrSite(1,0) = "displaynameofobject"
arrSite(1,1) = "DestinationName/IP"

arrSite(2,0) = "displaynameofobject"
arrSite(2,1) = "DestinationName/IP"

arrSite(3,0) = "displaynameofobject"
arrSite(3,1) = "DestinationName/IP"

arrSite(4,0) = "displaynameofobject"
arrSite(4,1) = "DestinationName/IP"

arrSite(5,0) = "displaynameofobject"
arrSite(5,1) = "DestinationName/IP"

arrSite(6,0) = "displaynameofobject"
arrSite(6,1) = "DestinationName/IP"

arrSite(7,0) = "displaynameofobject"
arrSite(7,1) = "DestinationName/IP"

arrSite(8,0) = "displaynameofobject"
arrSite(8,1) = "DestinationName/IP"

arrSite(9,0) = "displaynameofobject"
arrSite(9,1) = "DestinationName/IP"

arrSite(10,0) = "displaynameofobject"
arrSite(10,1) = "DestinationName/IP"

arrSite(11,0) = "displaynameofobject"
arrSite(11,1) = "DestinationName/IP"

arrSite(12,0) = "displaynameofobject"
arrSite(12,1) = "DestinationName/IP"

arrSite(13,0) = "displaynameofobject"
arrSite(13,1) = "DestinationName/IP"

arrSite(14,0) = "displaynameofobject"
arrSite(14,1) = "DestinationName/IP"

'------------------------------------------
'------------------------------------------
'------------------------------------------
'------------------------------------------


Set objShell = CreateObject("WScript.Shell")

For x = 0 to Ubound(arrSite,1)


	Set objExec = objShell.Exec("ping -n 1 -w 1000 " & arrSite(x,1))

	strPingResults = LCase(objExec.StdOut.ReadAll)
	Err.Clear
	arrLatency = split(strPingResults,"average = ")
        
        

	strLatency = arrLatency(1)
	strSpeed = split(strLatency,"ms")
		If strSpeed(0) > 175 then
			strBGColor = "red" 
		elseIf strSpeed(0) > 150 then
			strBGColor = "yellow" 
		else strBGColor = "7dc623"
		End If

	if Err.Number <> 0 Then
		strLatency = "Unreachable"
		strBGColor = "red"
	End If

	
	tblLatency = tblLatency & "<tr height='15'><td align=center bgcolor=white style='filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr=#00aaeed, startColorstr=#ffffff, gradientType='2');'><font size=4>" & arrSite(x,0) & "</font></td></tr>" & "<tr><td bgcolor=" & strBGColor & ">" & strLatency & "</td></tr>"

Next 

'------------------------------------------
'------------------------------------------
'------------------------------------------
'------------------------------------------
strComputer = array("displaynameofobject","displaynameofobject","displaynameofobject", "displaynameofobject", "displaynameofobject", "displaynameofobject", "displaynameofobject", "displaynameofobject", "displaynameofobject", "displaynameofobject", "displaynameofobject")



 'REM out the strComputer line above and unrem the below lines and set the server OU path if you want the script to find all your servers for you.
 'dim strComputer()
 'Set objServers = GetObject("LDAP://OU=localname,OU=postOU,DC=domain,DC=domain,DC=domain")
 'objServers.Filter = Array("Computer")
 'w=0
 'For Each objServer in objServers
 'redim preserve strComputer(w)
 'strComputer(w) = objServer.CN
 'w=w+1
 'Next

'------------------------------------------
'------------------------------------------
'------------------------------------------
'------------------------------------------


	Dim objWMIService, objItem, colItems
	Dim strDriveType, strDiskSize, txt


z=0
For each objComputer in strComputer

	Set objWMIService = GetObject("winmgmts:\\" & objComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery("Select * from Win32_LogicalDisk WHERE DriveType=3")
	txt = "<table><tr height='15'><td align=top colspan='10' bgcolor=white style='filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr=#00aaeed, startColorstr=#ffffff, gradientType='2');'><font size='4px'>" & objComputer & "</font></td></tr><tr><td width=30px> DL</td><td width=40px> Size</td><td width=50px> Free</td></tr> " 

	For Each objItem in colItems
	
		DIM pctFreeSpace,strFreeSpace,strusedSpace
		strBGColor="7dc623"
		'pctFreeSpace = INT((objItem.FreeSpace / objItem.Size) * 1000)/10
		strDiskSize = Int(objItem.Size /1073741824)
		strFreeSpace = Int(objItem.FreeSpace /1073741824) 
			If strFreeSpace < 5 then
				strBGColor = "red" 
			elseIf strFreeSpace < 10 then
				strBGColor = "yellow" 
			end if
		txt = txt & "<tr><td> " & objItem.Name & "<td> " & strDiskSize & "<td bgcolor='" & strBGColor & "'>" & strFreeSpace & "<td></tr> "
		

	Next
	  txt = txt & "</table>"


If not Err.Number = 0 Then txt = "<table width='100%'><tr height='15'><td align=top bgcolor=white style='filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr=#00aaeed, startColorstr=#ffffff, gradientType='2');'><font size='4px'>" & objComputer & "</font></td></tr><tr><td bgcolor=red>Error: " & error.number & "</td></tr>"
Err.Clear
z=z+1
If z=4 then txt=txt & "<td valign=top><table>"
	response.Write(txt)
    
if z=4 then z=0

Next



%>
</td>

<td valign=top>
<table>



<%



'response.Write(tblLatency)


%>



</td>

<td valign=top>

<table>

<%

strsqlComputer = array("webservername", "SQLservername")
dim strname, strstate
z=0
For each objComputer in strsqlComputer

	Set objWMIService = GetObject("winmgmts:\\" & objComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery("Select * from Win32_Service where displayname like 'SQL Server Agent%' or displayname like 'WEBPASS%'  ")
	txt = "WEBPASS and SQLSERVER<table ><tr height='15'><td align=center colspan='10'bgcolor=white style='filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr=#00aaeed, startColorstr=#ffffff, gradientType='2');'><font size='4px'>" & objComputer & "</font></td></tr><tr></tr> " 

	For Each objItem in colItems
	
				
		strname = objitem.displayname
		strstate = objitem.state
		If strstate = "Running" then
			strBGColor = "7dc623" 
		
		else
 			strBGColor = "RED"
		End If
		
                
		txt = txt & "<tr><td> " & objItem.displayname & "<td> " &  "<td bgcolor='" & strBGColor & "'>" & strstate & "<td></tr> "

	Next
	txt = txt & "</table>"

If not Err.Number = 0 Then txt = "<table width='100%'><tr height='15'><td align=center bgcolor=white style='filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr=#00aaeed, startColorstr=#ffffff, gradientType='2');'><font size='4px'>" & objComputer & "</font></td></tr><tr><td bgcolor=red>Error: " & error.number & "</td></tr>"
Err.Clear
z=z+1
If z=2 then txt=txt & "<td valign=top><table>"

	response.Write(txt)
if z=2 then z=0

Next
%>
</table>
</td></tr></table>

<td valign=top>
<table>
<%

response.Write(tblLatency)

%>
</table>
</td>
</font>
</body>
</html>
