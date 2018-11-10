<#
.SYNOPSIS
    CmdLets for administration HPE OneView through RESTful API  
.NOTES
    Version:        1.0
    Author:         Ivan V. Smirnov (ione.smirnoff@gmail.com)
    Company:        Transneft Technology, LLC
    Creation Date:  09.11.2018  
#>

function Get-HPEOVAuthToken
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String] 
        $OVApplianceIP,

        [Parameter(Mandatory = $true)]
        [String] 
        $Domain,
        
        [Parameter(Mandatory = $true)]
        [String] 
        $UserName,
        
        [Parameter(Mandatory = $true)]
        [String] 
        $Password
    )
    begin
    {        
        $body = [Ordered]@{
            'authLoginDomain' = $Domain.ToUpper()
            'password'        = $Password
            'userName'        = $UserName
            'loginMsgAck'     = 'true'}

        $headers = [Ordered]@{
            'X-Api-Version' = '600'
            'Content-Type'  = 'application/json'}
        
        $jsonBody = ConvertTo-Json $body
        $uri      = 'https://' + $OVApplianceIP + '/rest/login-sessions'
    }
    process
    {
        try
        {
            $session = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $jsonBody
        }
        catch
        {
            $_.Exception.Message
        }        
        $session.sessionID
    }
}

function Delete-HPEOVAlert
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        ValueFromPipeline    = $true)]
        [String] 
        $OVApplianceIP,
        
        [Parameter(Mandatory = $true,
        ValueFromPipeline    = $true)]
        [String] 
        $Auth,
        
        [Parameter(Mandatory = $true,
        ValueFromPipeline    = $true)]
        [String] 
        $AlertID
    )
    begin
    {
        $headers = [Ordered]@{
            'X-Api-Version' = '200'
            'Auth'          = $Auth}

        $uri = 'https://' + $OVApplianceIP + '/rest/alerts/' + $AlertID + '?force=true'
    }
    process
    {
        try
        {
            Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers | Out-Null
            Write-Host "Alert $AlertID cleared"
        }
        catch
        {
            $_.Exception.Message
        }    
    }
}