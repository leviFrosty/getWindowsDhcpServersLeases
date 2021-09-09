. ./variables.ps1
function WriteLog ($message) {
	Add-Content $logfilepath -Value $message
}
