# Testing. Hardcoded items for now.
. .\variables.ps1
Import-Module -Name .\modules\logging.psm1

try {
  WriteLog "Attempting to import all CSV files from $outDir"
  $allCsvs = Get-Item -Path $outDir\*.csv
}
catch {
  WriteLog "Failed to import CSV files from $outDir. Validate CSV files are not missing."
  if ($debug -ne 1) {
    exit
  }
}
WriteLog "CSV files imported to ping iterator program."

WriteLog "Iterating over CSV files. Pinging..."
foreach ($csv in $allCsvs) {
  $name = $csv.name
  WriteLog "Selected $name. Pinging all available reservations..."
  $csv = Import-Csv -Path $csv.FullName -Delimiter "," -Verbose 
  $csv | Select-Object *,"pingSucceeded" | Export-Csv ".\temp\temp.csv"
  $tempCsv = Import-Csv -path ".\temp\temp.csv" -Delimiter "," -Verbose
  $tempcsv | ForEach-Object {
    $ip = $_.IPAddress
    $connection = Test-Connection $ip -Count 1 -Verbose
    if ($connection.status -eq "Success") {
      WriteLog "$ip pinged."
      $_.pingSucceeded = $true
    }
    else {
      WriteLog "$ip did not respond."
      $_.pingSucceeded = $false
    }
  }
  WriteLog "Outputting results of $name to $outDir..."
  $tempCsv | Export-Csv ".\$outDir\$name-RESULT.csv" -Force -Verbose
  Remove-Item -Path ".\temp\temp.csv" -Force -Verbose
}
WriteLog "Succeeded! All CSVs complete. Exiting Test Connections program..."
if ($debug -ne 1) {
  exit
}