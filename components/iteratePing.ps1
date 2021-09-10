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
$i = 0
WriteLog "Iterating over CSV files."
foreach ($csv in $allCsvs) {
  $csv = Import-Csv -Path $csv.FullName -Delimiter "," -Verbose 
  $csv | Select-Object *,"pingSucceeded" | Export-Csv ".\temp\temp.csv"
  $tempCsv = Import-Csv -path ".\temp\temp.csv" -Delimiter "," -Verbose
  $tempcsv | ForEach-Object {
    $connection = Test-Connection $_.IPAddress -Count 1 -Verbose
    if ($connection.status -eq "Success") {
      $_.pingSucceeded = $true
    }
    else {
      $_.pingSucceeded = $false
    }
  }
  $filename = $i
  $i++
  $tempCsv | Export-Csv ".\$outDir\$filename-RESULT.csv" -Force -Verbose
  Remove-Item -Path ".\temp\temp.csv" -Force -Verbose
}
