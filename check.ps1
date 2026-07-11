Get-ChildItem 'c:\Users\user\Desktop\Drone Deliver System Simulation\lib' -Recurse -Filter *.dart | ForEach-Object { if (.Length -lt 200) { Write-Host (.FullName + ' : ' + .Length + ' bytes') } }
