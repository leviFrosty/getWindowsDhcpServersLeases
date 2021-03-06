. ./variables.ps1
Import-Module -Name .\Modules\installPowerShell.psm1
Import-Module -Name .\Modules\logging.psm1

# Clears previous log file
if (Test-Path $logfilepath) {
	Remove-Item $logfilepath -Verbose
}

WriteLog "======= SCRIPT START ======="
# WriteLog "Checking PowerShell version..."
# if ($psversiontable.psversion.major -lt 6) {
# 	try {	WriteLog "PowerShell 5 or older detected. Attempting to install PowerShell..."
# 	InstallPowerShell
# 	}
# 	catch { 
# 		WriteLog "PowerShell failed to install. Verify network connectivity and try again."
# 		WriteLog "Exiting..."
# 		if ($debug -ne 1) {
# 			exit
# 		}
# 	}
# 	WriteLog "Success! PowerShell installed."
# }
# WriteLog "PowerShell version passes validation. Continuining..."

WriteLog "Clearing previous CSV files."
if ($deletePreviousResultOnRun -eq 1) {
	try {
		Remove-Item $outDir\*.csv -Force
		
	}
	catch {
		WriteLog "Failed to delete previous CSV files. Please make sure you do not have another process using the file."
		if ($debug -ne 1) {
			exit
		}
	}
}

WriteLog "Starting DHCP reservation fetch program..."
.(".\components\getAllDhcpReservations.ps1")
WriteLog "DHCP reservations fetch program completed. Back to main."

WriteLog "Starting Test Connections program..."
.(".\components\iteratePing.ps1")
WriteLog "Test Connections program completed. Back to main."


WriteLog "======= SCRIPT END ======="