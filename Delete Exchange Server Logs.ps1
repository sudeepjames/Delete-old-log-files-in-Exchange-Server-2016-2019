
CLS

Write-Host "`n=================================================="

Write-Host "Script by Sudeep James"

Write-Host "==================================================`n`n"

Write-Host "Please wait.. Script is running. . . `n`n"

# Cleanup logs older than the set of days in numbers
$Days = 25

# Path of the logs
$IISLogPath = "C:\inetpub\logs\LogFiles\"
$ExchangeLoggingPath = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\"


# Get size of all logfiles
Function Get-LogfileSize ($TargetFolder) 
{
        if (Test-Path $TargetFolder) 
        {
            $Now = Get-Date
            $LastWrite = $Now.AddDays(-$days)
            $Files = Get-ChildItem $TargetFolder -Recurse | Where-Object { $_.Name -like "*.log" -or $_.Name -like "*.blg" } | Where-Object { $_.lastWriteTime -le "$lastwrite" }
            $SizeGB = ($Files | Measure-Object -Sum Length).Sum / 1GB
            $SizeGBRounded = [math]::Round($SizeGB,2)
            return $SizeGBRounded
        }
        Else 
        {
            Write-Output "The folder $TargetFolder doesn't exist! Check the folder path!"
        }
}

# Remove the logs
Function Remove-Logfiles ($TargetFolder) 
{
    if (Test-Path $TargetFolder) 
    {
        $Now = Get-Date
        $LastWrite = $Now.AddDays(-$days)
        $Files = Get-ChildItem $TargetFolder -Recurse | Where-Object { $_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl" } | Where-Object { $_.lastWriteTime -le "$lastwrite" }
        $FileCount = $Files.Count
        $Files | Remove-Item -force -ea 0
        return $FileCount
    }
    Else 
    {
        Write-Output "The folder $TargetFolder doesn't exist! Check the folder path!"
    }
}




# Get logs and traces and write some stats
$IISLogSize = Get-LogfileSize $IISLogPath
$ExchangeLogSize = Get-LogfileSize $ExchangeLoggingPath


$TotalLogSize = $IISLogSize + $ExchangeLogSize


Write-Host "Total Log File Size is $TotalLogSize GB"



#Ask if script should realy delete the logs
$Confirmation = Read-Host "Are you sure you want to DELETE Exchange Server log and trace files? [y/n]"

while($Confirmation -notmatch "[yYnN]") 
{
    if ($Confirmation -match "[nN]") 
    {
        exit
    }
    $Confirmation = Read-Host "Delete Exchange Server log and trace files? [y/n]"
}

# Delete logs (if confirmed) and write some stats
if ($Confirmation  -match "[yY]") 
{
    $DeleteIISFiles = Remove-Logfiles $IISLogPath
    $DeleteExchangeLogs = Remove-Logfiles $ExchangeLoggingPath
    $TotalDeletedFiles = $DeleteIISFiles + $DeleteExchangeLogs
    write-host "$TotalDeletedFiles files deleted"
}