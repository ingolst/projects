# Creates function, requests user input for keyword to search domain for group policy objects
Function GetString {
    Param ([string]$global:userstring=(Read-Host "What do you want from me?"))
    write-host "You wanted me to find $global:userstring"
    return $global:userstring
    }
    
    $string = GetString
    
    # Obtain domain name of the environment of current user session, e.g. environment.local
    
    $DomainName = $env:USERDNSDOMAIN
    
    # Import grouppolicy module to allow Get-GPO which in this scenario fetches all group policy objects in your domain
    
    Import-Module grouppolicy
    $allGposInDomain = Get-GPO -All -Domain $DomainName | Sort-Object DisplayName
    
    # For loop returns GPO objects that match the users' keyword in $string
    
    foreach ($gpo in $allGposInDomain) {
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    if ($report -match $string) {
    write-host "$($gpo.DisplayName)"
    }
    else {
    
    }
    }