. ./variables.ps1
Import-Module -Name .\Modules\logging.psm1


WriteLog "DHCP Reservation Fetch Program Starts."
# Formats input directory
if ($outDir -notmatch '\\$') {
	$originalDir = $outDir
	$outDir += '\'
	WriteLog "Formatted directory from $originalDir to $outDir"
}


# Checks if machine has DHCP windows feature installed.
$feature = get-windowsfeature -Name 'dhcp' -Verbose
if ($feature.installed -eq $false) {
	WriteLog "Please install windows feature DHCP and try again."
	WriteLog "Exiting..."
  if ($debug -ne 1) {
    exit
  }
}
WriteLog "DHCP Windows feature is installed."


WriteLog "Collecting DHCP servers in domain..."

try {
	$totalDhcpServers = Get-DhcpServerInDc -Verbose
}
catch {
	WriteLog 'There are no DHCP servers authorized in this Domain. Add a DHCP server using "Add-DhcpServerInDC"'
	WriteLog "Exiting..."
  if ($debug -ne 1) {
    exit
  }
}

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
  $rawdata = Get-DhcpServerv4Scope -ComputerName $server | Get-DhcpServerv4Reservation -ComputerName $server
	WriteLog "Collected DHCP Scopes and Reservations Data for $server."

	$finalpath = "$outDir$server-$scopeids.csv"
	WriteLog "Outputting data for server $server to file `"$finalpath`"."
  $rawData | Select-Object ipAddress, scopeId, clientId, Name, Type, Description |	Export-Csv -Path $finalpath -Append -Verbose -NoTypeInformation
}


WriteLog "Exiting DHCP reservation fetch program..."
if ($debug -ne 1) {
  exit
}
