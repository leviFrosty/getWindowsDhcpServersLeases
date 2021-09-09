function InstallPowerShell() {
  if (!(test-path "$env:TEMP\PowerShell-7.1.4-win-x64.msi")) {
    Invoke-WebRequest -uri "https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/PowerShell-7.1.4-win-x64.msi" -OutFile "$env:TEMP\PowerShell-7.1.4-win-x64.msi"
  }
  $params = "/package PowerShell-7.1.4-win-x64.msi", "/quiet", "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1", "ENABLE_PSREMOTING=1", "REGISTER_MANIFEST=1"
  Start-Process 'msiexec.exe' -ArgumentList $params -NoNewWindow -Wait -PassThru
  return
}