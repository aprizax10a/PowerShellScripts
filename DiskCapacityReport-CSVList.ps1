##################################################
#Script: Disk Capacity Report
#Date: 2021/10/27
##################################################
#Define Disk Free Space Threshold
$Warning = 25
$Critical = 15

#Get Current Date and Time
$DateTime = (Get-Date).ToString("yyyyMMdd-HHmm")

#Define Server List CSV File Path
$ServerListFilePath = "<CSV File path>"

#Import Server List
$ServersList = Import-Csv -Path $ServerListFilePath

#Define Report Path and Report Name
$ReportPath = "C:\Scripts\Reports\DiskCapacityReport"
$ReportName = "DiskSpaceReport_$DateTime.htm"
$ReportFilePath = "$ReportPath\$ReportName"

#Create File
New-Item -ItemType File $ReportFilePath -Force | Out-Null

#Set Working Path
$WorkingPath = $ReportPath
Set-Location -Path $WorkingPath

#Function to write the HTML Header to the file 
Function WriteHtmlHeader 
{ 
    param($FileName) 
    $Date = (get-date).ToString("yyyy/MM/dd")
    $Time = (get-date).ToString("HH:mm")
    Add-Content $FileName "<html>" 
    Add-Content $FileName "<head>" 
    Add-Content $FileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
    Add-Content $FileName '<title>DiskSpace Report</title>' 
    Add-Content $FileName '<STYLE TYPE="text/css">' 
    Add-Content $FileName  "<!--" 
    Add-Content $FileName  "td {" 
    Add-Content $FileName  "font-family: Tahoma;" 
    Add-Content $FileName  "font-size: 11px;" 
    Add-Content $FileName  "border-top: 1px solid #999999;" 
    Add-Content $FileName  "border-right: 1px solid #999999;" 
    Add-Content $FileName  "border-bottom: 1px solid #999999;" 
    Add-Content $FileName  "border-left: 1px solid #999999;"
    Add-Content $FileName  "padding-top: 0px;" 
    Add-Content $FileName  "padding-right: 0px;" 
    Add-Content $FileName  "padding-bottom: 0px;" 
    Add-Content $FileName  "padding-left: 0px;" 
    Add-Content $FileName  "}" 
    Add-Content $FileName  "body {" 
    Add-Content $FileName  "margin-left: 5px;" 
    Add-Content $FileName  "margin-top: 5px;" 
    Add-Content $FileName  "margin-right: 0px;" 
    Add-Content $FileName  "margin-bottom: 10px;"
    Add-Content $FileName  "" 
    Add-Content $FileName  "table {" 
    Add-Content $FileName  "border: thin solid #000000;" 
    Add-Content $FileName  "border-collapse: collapse;" 
    Add-Content $FileName  "}" 
    Add-Content $FileName  "-->" 
    Add-Content $FileName  "</style>" 
    Add-Content $FileName "</head>" 
    Add-Content $FileName "<body>" 
    Add-Content $FileName  "<table width='100%'>" 
    Add-Content $FileName  "<tr bgcolor=Black>" 
    Add-Content $FileName  "<td colspan='7' height='25' align='center'>" 
    Add-Content $FileName  "<font face='tahoma' color=White size='4'><strong>DiskSpace Report - $Date</strong></font>" 
    Add-Content $FileName  "<br><font face='tahoma' color=White size='1'><strong>Generated at  - $Time</strong></font></br>" 
    Add-Content $FileName  "</td>" 
    Add-Content $FileName  "</tr>" 
    Add-Content $FileName  "</table>" 
} 
 
#Function to write the HTML Table Header to the file 
Function WriteTableHeader 
{ 
    param($FileName) 
    Add-Content $FileName "<tr bgcolor=LightBlue>"
    Add-Content $FileName "<td width='5%' align='center'><font Color=DarkBlue><b>Drive</b></font></td>"
    Add-Content $FileName "<td width='43%' align='center'><font Color=DarkBlue><b>Label</b></font></td>" 
    Add-Content $FileName "<td width='8%' align='center'><font Color=DarkBlue><b>FileSystem</b></font></td>"
    Add-Content $FileName "<td width='8%' align='center'><font Color=DarkBlue><b>BlockSize</b></font></td>" 
    Add-Content $FileName "<td width='10%' align='center'><font Color=DarkBlue><b>Total Capacity (GB)</b></font></td>" 
    Add-Content $FileName "<td width='10%' align='center'><font Color=DarkBlue><b>Used Capacity (GB)</b></font></td>" 
    Add-Content $FileName "<td width='8%' align='center'><font Color=DarkBlue><b>Free Space (GB)</b></font></td>" 
    Add-Content $FileName "<td width='8%' align='center'><font Color=DarkBlue><b>Free Space (%)</b></font></td>" 
    Add-Content $FileName "</tr>" 
} 

#Function to write the HTML Table Header to the file 
Function WriteHtmlFooter 
{ 
    param($FileName) 
    Add-Content $FileName "</body>" 
    Add-Content $FileName "</html>" 
} 

#Function to write Disk Info to the file 
Function WriteDiskInfo 
{ 
    param($FileName,$DriveLetter,$Label,$FreeSpace,$Capacity,$FileSystem,$BlockSize)
    #Convert parameters
    $TotalSpaceGB = [math]::Round(($Capacity/1GB),2)
    $FreeSpaceGB = [Math]::Round(($FreeSpace/1GB),2)
    $UsedSpaceGB = [Math]::Round(($TotalSpaceGB-$FreeSpaceGB),2)
    $FreeSpacePercent = [Math]::Round(($FreeSpace/$Capacity)*100,2)
    #Format number to show 2 decimals
    $TotalSpaceGB = "{0:n2}" -f $TotalSpaceGB
    $FreeSpaceGB = "{0:n2}" -f $FreeSpaceGB
    $UsedSpaceGB = "{0:n2}" -f $UsedSpaceGB
    $FreeSpacePercent = "{0:n2}" -f $FreeSpacePercent
    If($FreeSpacePercent -gt $Warning)
    { 
        Add-Content $FileName "<tr>" 
        Add-Content $FileName "<td align=Center>$DriveLetter</td>"
        Add-Content $FileName "<td align=Left>$Label</td>"
        Add-Content $FileName "<td align=Center>$FileSystem</td>"
        Add-Content $FileName "<td align=Right>$BlockSize</td>"
        Add-Content $FileName "<td align=Right>$TotalSpaceGB</td>"
        Add-Content $FileName "<td align=Right>$UsedSpaceGB</td>"
        Add-Content $FileName "<td align=Right>$FreeSpaceGB</td>"
        Add-Content $FileName "<td bgcolor=Green align=center><font Color=White>$FreeSpacePercent</font></td>" 
        Add-Content $FileName "</tr>" 
    }
    ElseIf($FreeSpacePercent -le $Critical)
    { 
        Add-Content $FileName "<tr>" 
        Add-Content $FileName "<td align=Center>$DriveLetter</td>"
        Add-Content $FileName "<td align=Left>$Label</td>"
        Add-Content $FileName "<td align=Center>$FileSystem</td>"
        Add-Content $FileName "<td align=Right>$BlockSize</td>"
        Add-Content $FileName "<td align=Right>$TotalSpaceGB</td>"
        Add-Content $FileName "<td align=Right>$UsedSpaceGB</td>"
        Add-Content $FileName "<td align=Right>$FreeSpaceGB</td>"
        Add-Content $FileName "<td bgcolor=Red align=center><font Color=White>$FreeSpacePercent</font></td>" 
        Add-Content $FileName "</tr>" 
    } 
    Else 
    { 
        Add-Content $FileName "<tr>" 
        Add-Content $FileName "<td align=Center>$DriveLetter</td>"
        Add-Content $FileName "<td align=Left>$Label</td>"
        Add-Content $FileName "<td align=Center>$FileSystem</td>"
        Add-Content $FileName "<td align=Right>$BlockSize</td>"
        Add-Content $FileName "<td align=Right>$TotalSpaceGB</td>"
        Add-Content $FileName "<td align=Right>$UsedSpaceGB</td>"
        Add-Content $FileName "<td align=Right>$FreeSpaceGB</td>"
        Add-Content $FileName "<td bgcolor=Yellow align=center><font Color=Black>$FreeSpacePercent</font></td>" 
        Add-Content $FileName "</tr>" 
    } 
} 

#Write HTML Header
WriteHtmlHeader -FileName $ReportFilePath 
Foreach($Server in $ServersList)
{ 
        #Add Table Header for each server in list
        $ServerName = $Server.ServerName
        Add-Content $ReportFilePath "<table width='100%'><tbody>" 
        Add-Content $ReportFilePath "<tr bgcolor=DarkBlue>"
        Add-Content $ReportFilePath "<td width='100%' align='center' colSpan=8><font face='tahoma' color=Yellow size='2'><strong> $ServerName </strong></font></td>" 
        Add-Content $ReportFilePath "</tr>" 
        
        #Write Table Header to file
        WriteTableHeader -FileName $ReportFilePath

        #Gather Disk Info
        $Disks = Get-CimInstance -Class Win32_Volume -ComputerName $ServerName | Where-Object {$_.DriveType -eq "3" -and $_.DriveLetter -ne $null} #| FL DriveLetter, Label, FreeSpace, Capacity, FileSystem, BlockSize
        Foreach($Disk in $Disks)
        {
            #Show results on screen
            Write-Host "$($ServerName): $($Disk.DriveLetter) $($Disk.Label) $($Disk.FreeSpace) $($Disk.Capacity) $($Disk.FileSystem) $($Disk.BlockSize)"
            #Write Disk Info to file
            WriteDiskInfo -FileName $ReportFilePath -DriveLetter $Disk.DriveLetter -Label $Disk.Label -FreeSpace $Disk.FreeSpace -Capacity $Disk.Capacity -FileSystem $Disk.FileSystem -BlockSize $Disk.BlockSize
        }
}
WriteHtmlFooter -FileName $ReportFilePath
