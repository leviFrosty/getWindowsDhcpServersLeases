<#
- Author:
Levi Wilkerson
https://github.com/levifrosty

- CompanyName: 
LightChange Technologies

- Name:
Get-DHCPLeasesinDomain

- Synopsis:
Retrieves all DHCP leases scopes.

- Description:
Retrieves all DHCP leases and scopes from all available DHCP servers the current machine can access.
Outputs data into formatted CSV files.

- Version: 0.1

- Help:
You must run as domain administrator.
The script outputs a log file in the $outDir specified.
If you'd like the PowerShell terminal to stay open after running, change $debug to 1.
#>
$outDir = 'c:\'
$debug = 1




# ======= SCRIPT START =======
# Admin Check
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
    Read-Host 'Press enter to exit'
    exit
}

Set-ExecutionPolicy bypass

$logfilepath = "$outDir\dhcpLeasesFetch.log"
function WriteLog ($message) {
	Add-Content $logfilepath -Value $message -Verbose
}
if (Test-Path $logfilepath) {
	Remove-Item $logfilepath -Verbose
}
WriteLog "======= SCRIPT START ======="
WriteLog "DHCP Lease Fetch Program Starts."

# Formats input directory
if ($outDir -notmatch '\\$') {
	$originalDir = outDir
	$outDir += '\'
	WriteLog "Formatted directory from $originalDir to $outDir"
}

# Checks if machine has DHCP windows feature installed.
$feature = get-windowsfeature -Name 'dhcp' -Verbose
if ($feature.installed -eq $false) {
	WriteLog "Please install windows feature DHCP and try again."
	WrieLog "Exiting..."
  if ($debug -ne 1) {
    exit
  }
}
WriteLog "DHCP Windows feature is installed."


WriteLog "Collecting DHCP servers in domain..."
$totalDhcpServers = Get-DhcpServerInDc -Verbose
$validDhcpServers = New-Object System.Collections.ArrayList ($null)
foreach ($dhcpServer in $totalDhcpServers) {
  $name = $dhcpServer.DnsName
  $dhcpServer = Get-DhcpServerv4Statistics -ComputerName $name
	if ($dhcpServer.totalscopes -gt 0) {
		[void]($validDhcpServers.Add($name))
		WriteLog "$name is a valid DHCP server."
	}
  else { 
    WriteLog "$name is not configured with any DHCP scopes."
  }
}

# Validates there is at least 1 valid DHCP server before proceeding
$validDhcpServersCount = $validDhcpServers.count
if ($validDhcpServersCount -lt 1) {
	WriteLog "There are no DHCP server scopes via Windows Server in this domain."
	WriteLog "Exiting..."
  if ($debug -ne 1) {
    exit
  }
}
WriteLog "Collected $validDhcpServersCount valid DHCP Windows Servers in domain."

WriteLog "Collecting DHCP Scopes and Reservations for all valid DHCP servers..."
foreach ($server in $validDhcpServers) {
  $scopeids = New-Object System.Collections.ArrayList ($null)
	$scopes = Get-DhcpServerv4Scope -ComputerName $server -Verbose
	foreach ($scope in $scopes) {
		$scopeid = $scope.scopeid;
		[void]($scopeids.Add($scopeid))
	}
  $rawdata = Get-DhcpServerv4Scope -ComputerName ppsad04 | Get-DhcpServerv4Reservation -ComputerName ppsad04 
	WriteLog "Collected DHCP Scopes and Reservations Data for $server."

	$finalpath = "$outDir$server-$scopeids.csv"
	WriteLog "Outputting data for server $server to file `"$finalpath`"."
  $rawData | Select-Object ipAddress, scopeId, clientId, Name, Type, Description |	Export-Csv -Path $finalpath -Append -Verbose -NoTypeInformation
}


WriteLog "Exiting..."
WriteLog "======= SCRIPT END ======="
if ($debug -ne 1) {
  exit
}
