	Write-Host "..Create folders and copy files..."

	New-Item -Path "C:\Program Files\telegraf" -ItemType Directory -Force
	New-Item -Path "C:\DBOps" -ItemType Directory -Force
	Copy-Item -Path "C:\Telegraf\telegraf.*" -Destination "C:\Program Files\telegraf\" -Force
	Copy-Item -Path "C:\Telegraf\Start-Telegraf.ps1" -Destination "C:\DBops\Start-Telegraf.ps1" -Force


	Write-Host '..Install service...'
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

	Write-Host '..Setup job to mark sure it autostarts...'
	#Create job to start job on startup
	$trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
	Register-ScheduledJob -Trigger $trigger -FilePath C:\DBOps\Start-Telegraf.ps1 -Name Start-Telegraf
	

