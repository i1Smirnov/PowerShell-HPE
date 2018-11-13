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
        [SecureString] 
        $Password
    )
    begin
    {        
        $encPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

        $body = [Ordered]@{
            'authLoginDomain' = $Domain.ToUpper()
            'password'        = $encPassword
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

function Remove-HPEOVAlert
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String] 
        $OVApplianceIP,
        
        [Parameter(Mandatory         = $true,
                   ValueFromPipeline = $true)]
        [String] 
        $Auth,
        
        [Parameter(Mandatory = $true)]
        [String] 
        $AlertID
    )
    begin
    {
        $headers = [Ordered]@{
            'X-Api-Version' = '200'
            'Auth'          = $Auth}   
        $alerts = $AlertID.Split(',')
    }
    process
    {
        foreach ($alert in $alerts)
        {
            try
            {
                $uri = 'https://' + $OVApplianceIP + '/rest/alerts/' + $alert + '?force=true'
                Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers | Out-Null
            }
            catch
            {
                $_.Exception.Message
            }
        }
    
    }
}