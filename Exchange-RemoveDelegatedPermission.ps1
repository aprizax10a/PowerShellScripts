Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$DatabaseName = "<Database Name>"
$DelegatedUser = "<DOMAIN\delegated user account>"
$AllMailbox = Get-MailboxDatabase -Identity $DatabaseName | Get-Mailbox

foreach($Mailbox in $AllMailbox)
{
    $MailboxUPN = $Mailbox.UserPrincipalName
    $CurrentPermission = Get-MailboxPermission -Identity $MailboxUPN -User $DelegatedUser
    $AsabaPermission = $CurrentPermission | Where-Object {$_.IsInherited -eq $False -and $_.Deny -eq $False}
    If([string]::IsNullOrEmpty($AsabaPermission))
    {
        Write-Host "$($DelegatedUser) has no permission on $($MailboxUPN) mailbox" -ForegroundColor Yellow
    }
    Else
    {
        Write-Host "$($DelegatedUser) has permission on $($MailboxUPN) mailbox" -ForegroundColor Green
        Write-Host "Removing $($DelegatedUser) permission on $($MailboxUPN) mailbox" -ForegroundColor Green
        Remove-MailboxPermission -Identity $MailboxUPN -User $DelegatedUser -AccessRights FullAccess
    }
}
