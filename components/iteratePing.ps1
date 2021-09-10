# Testing. Hardcoded items for now.
. .\variables.ps1
Import-Module -Name .\modules\iteratePing.psm1

$example = ".\out\win-faquc4fpnkg.labforus.local-10.11.111.0.csv"
$reservationCsv = Import-Csv -Path $example -Delimiter ","
$reservationCsv | Select-Object *,"pingSucceeded" | Export-Csv ".\out\temp.csv"
$tempCsv = Import-Csv -path ".\out\temp.csv" -Delimiter ","
$tempcsv | foreach {
  $connection = Test-Connection $_.IPAddress -Count 1
  if (($connection.status -eq "Success") -and $true) {
    $_.pingSucceeded = "PINGED"
  }

}
$tempCsv | Export-Csv ".\out\temp2.csv"