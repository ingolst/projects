#Supress errors & warnings

Import-PSSession -session -disablenamechecking
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

# Checks for Active Directory, Microsoft Teams and Azure AD modules

Import-Module ActiveDirectory
Import-Module AzureAD
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.6

Clear-Host

# Set the domain and path to the Ex Employees folder. Rename 'Ex Employees' with location where you would like to move the user
# Rename OU with distination path, rename $domain and 'CUSTOM' to domain name

$domain = "CUSTOM.local"
$exEmployeesPath = "OU=Ex Employees,OU=CHANGE,OU=CHANGE DOMAIN,DC=CUSTOM,DC=local"

# Requests input for display name of user to offboard

Clear-Host
$UserDisable = Read-Host "Enter username of user to disable and move to Ex Employees folder. E.g. ingolst.test"

Clear-Host

# Connect to AzureAD

Connect-AzureAD

# Verify user exists, move and disable user, error handle if does not exist

$user = $(try{get-aduser $UserDisable} catch {$null})

if (-not $user) {
    Write-Host "User does not exist"
    exit
}

# Move the user to the Ex Employees folder

Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=Ex Employees,OU=CHANGE,OU=CHANGE DOMAIN,DC=CUSTOM,DC=local"

# Confirm that the move was successful

Write-Output "Successfully moved user to Ex Employees folder"

# Disable the user's account

Disable-ADAccount -Identity $UserDisable
Get-ADUser -Identity $UserDisable | Select-Object SamAccountName, Enabled

# Remove all licenses from the user in Office 365

Set-AzureADUserLicense -ObjectId $user.ObjectId -RemoveLicenses "*"

# Strip the user of all groups except for the 'Domain Users' group

$groups = Get-ADPrincipalGroupMembership -Identity $UserDisable | select-object -ExpandProperty Name
foreach ($group in $groups)
{
    if($group.Name -ne 'Domain Users')
    {
        Remove-ADPrincipalGroupMembership -Identity $UserDisable -MemberOf $group -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# Removes user from MS Teams sites

Connect-MicrosoftTeams

$teams = Get-Team | Get-TeamUser -User $UserDisable
foreach ($team in $teams) {
    Remove-TeamUser -GroupID $team.GroupID -User $UserDisable
}
Write-Host "Successfully removed user from Teams"

# Initiate Dirsync Delta sync. Replace 'az-dirsync' with name of dirsync server. You will require appropriate permissions.

$dirsync = Read-Host "Would you like to run dirsync? Please answer 'yes' or 'no'"
Clear-Host
If($dirsync -eq 'yes') {
    Invoke-Command -ComputerName "az-dirsync" -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }

    Write-Host "Dirsync successful."

}   Else {
    Write-Output "Exited Script"
    exit
}