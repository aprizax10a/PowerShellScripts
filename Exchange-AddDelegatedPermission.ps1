Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$DatabaseName = "<database name>"
$DelegatedUser = "<DOMAIN\delegated username>"
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
