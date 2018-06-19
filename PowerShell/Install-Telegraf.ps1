$servers = @(
	'server1', 'server2'
)
$servers | % {
	Write-Host "$($_)..."
	Write-Host "..Create folders and copy files..."

	New-Item -Path "\\$($_)\c$\Program Files\telegraf" -ItemType Directory -Force
	New-Item -Path "\\$($_)\c$\DBOps" -ItemType Directory -Force
	Copy-Item -Path "\\server\telegraf\telegraf.*" -Destination "\\$($_)\c$\Program Files\telegraf\" -Force
	Copy-Item -Path "\\server\telegraf\Start-Telegraf.ps1" -Destination "\\$($_)\c$\DBops\Start-Telegraf.ps1" -Force

	Invoke-Command -ComputerName $_ -ScriptBlock {
		Write-Host "..Install service..."
		Stop-Service -Name telegraf -ErrorAction SilentlyContinue
		& "c:\program files\telegraf\telegraf.exe" --service install -config "c:\program files\telegraf\telegraf.conf"
		SC.EXE Config telegraf Start=Delayed-Auto
		Start-Service -Name telegraf
		Start-Sleep 90
		
		# Make sure it starts
		$service = Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -eq "telegraf"}
		While($service.count -eq 0) {
    			Start-Service -Name "telegraf"
    			Start-Sleep 90
    			$service = Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -eq "telegraf"}
		}

		Write-Host "..Setup job to mark sure it autostarts..."
		#Create job to start job on startup
		$trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
		Register-ScheduledJob -Trigger $trigger -FilePath C:\DBOps\Start-Telegraf.ps1 -Name Start-Telegraf
	}
}
