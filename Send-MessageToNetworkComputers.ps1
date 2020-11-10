<# Script to send message to Client computers using MSG utility.
The script will prompt you to enter the following information.
Message :-  Type your message which you want to send to the computers. Like "Your computer is pending reboot after Windows updates, please reboot.."
Computer Name :- Type the computer name to which you want to send the Message, if you type PC1, it will send message to PC1 computer.
You can type multiple computer names separated by the comma “,” like PC1, PC2, PC3 or you can give the path of the txt file with computer names, one in each line.
Like below.
PC1
PC2
PC3

Time :- Type time in SECONDS, duration till message pop up will remain on computer. After this time, the message pop up will disappear.
For example if you provide 5 in time prompt, the pop up will remain till 5 seconds on user’s desktop.
#>

# Variable declaration
$Start_Time       =       Get-Date -Format T
$logFile          =       ‘Not_Reachable_PCs.txt’
$Message          =       Read-Host -Prompt “Type Your Message Here”      
$ComputerName     =       Read-Host -Prompt “Type Computer Name Here”    
$Time             =       Read-Host -Prompt “Type Time Here” 
$Session          =       “*”
$ComputerName     =       $ComputerName -split ‘,’

if ($ComputerName -match “:”)

                      {
                      $Path = $ComputerName
                      $ComputerName = Get-Content $path
          }
                      $Total = $ComputerName.count 
                                foreach ($Computer in $ComputerName )
                                                {
                                                             if (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction 0)
                                {
                                                                Write-Host “Sending Message to $Computer…….” -ForegroundColor yellow
                                msg $Session /Server:$Computer /Time:$Time $Message
                                                                Write-Host “Message Successfully Sent to $Computer” -ForegroundColor Green
                                                                }
                                                                else
                                                                                {

                                                                Out-File -FilePath $logFile -InputObject $Computer -Append -Force

                                                                                                Write-Host “$Computer is not Reachable…” -ForegroundColor red

                                                                                }

                                                }

        $Not_Reachable_Count  = @(Get-Content $logFile).count
        $End_Time   =    Get-Date -Format T
        $Minute = (New-TimeSpan -Start $Start_Time -End $End_Time).Minutes
        $Second = (New-TimeSpan -Start $Start_Time -End $End_Time).Seconds
        Write-Host Start at $Start_Time, End At $End_Time, Took About $Minute Minutes $seconds Seconds
        Write-Host “Total $Total Computer Processed, $Not_Reachable_Count computers were offline. The list is stored in $logFile” -ForegroundColor white