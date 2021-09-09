# example format
Import-Csv $outDir | Foreach-Object { 

  foreach ($property in $_.PSObject.Properties)
  {
      doSomething $property.Name, $property.Value
  } 

}