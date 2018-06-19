$service = Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -eq "telegraf"}
while ($service.count -eq 0) {
    Start-Service -Name "telegraf"
    start-sleep 90
    $service = Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -eq "telegraf"}
}