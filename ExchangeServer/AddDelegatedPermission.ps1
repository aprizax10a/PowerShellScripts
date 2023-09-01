#Add Delegated Permission to all mailboxes in Database 

Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

#Put your database name here
$DatabaseName = "<Database Name>"

$Put your delegated user account here
$DelegatedUser = "<DOMAIN\delegated user account>"

#Adding Delegated Permission to all mailboxes in database
$AllMailbox = Get-MailboxDatabase -Identity $DatabaseName | Get-Mailbox
foreach($Mailbox in $AllMailbox)
{
    $MailboxUPN = $Mailbox.UserPrincipalName
    $CurrentPermission = Get-MailboxPermission -Identity $MailboxUPN -User $DelegatedUser
    $AsabaPermission = $CurrentPermission | Where-Object {$_.IsInherited -eq $False -and $_.Deny -eq $False}
    If([string]::IsNullOrEmpty($AsabaPermission))
    {
        Write-Host "$($DelegatedUser) has no permission on $($MailboxUPN) mailbox" -ForegroundColor Yellow
        Write-Host "Added $($DelegatedUser) permission on $($MailboxUPN) mailbox" -ForegroundColor Yellow
        Add-MailboxPermission -Identity $MailboxUPN -AccessRights FullAccess -User $DelegatedUser
    }
    Else
    {
        Write-Host "$($DelegatedUser) already has permission on $($MailboxUPN) mailbox" -ForegroundColor Green
    }
}
