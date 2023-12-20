function Get-HuduActivityLog {  
    [CmdletBinding()]
    Param (
        [Alias('user_id')]
        [Int]$UserId,
        [Alias('user_email')]
        [String]$UserEmail,
        [Alias('resource_id')]
        [Int]$ResourceId,
        [Alias('resource_type')]
        [ArgumentCompletions('Article', 'Asset', 'AssetPassword', 'Company', 'Procedure', 'User', 'Website')]
        [String]$ResourceType,
        [Alias('action_message')]
        [ArgumentCompletions('archived', 'changed sharing', 'commented', 'completed task', 'created', 'deleted article', 'deleted asset', 'deleted global process template', 'deleted password', 'deleted process', 'deleted website', 'set expiration date', 'shared password', 'signed in', 'started export', 'unarchived', 'uncompleted task', 'updated', 'updated assignment', 'updated due date', 'updated priority', 'uploaded file', 'uploaded photo', 'viewed', 'viewed otp', 'viewed password', 'viewed PDF', 'viewed shared secure note')]
        [String]$ActionMessage,
        [Alias('start_date')]
        [DateTime]$StartDate,
        [Alias('end_date')]
        [DateTime]$EndDate
    )

    $Params = @{}

    if ($UserId) { $Params.user_id = $UserId }
    if ($UserEmail) { $Params.user_email = $UserEmail }
    if ($ResourceId) { $Params.resource_id = $ResourceId }
    if ($ResourceType) { $Params.resource_type = $ResourceType }
    if ($ActionMessage) { $Params.action_message = $ActionMessage }
    if ($StartDate) {
        $ISO8601Date = $StartDate.ToString('o');
        $Params.start_date = $ISO8601Date
    }
    Write-Verbose "Params: $($Params | ConvertTo-Json -Depth 5 -Compress)"
    $HuduRequest = @{
        Method   = 'GET'
        Resource = '/api/v1/activity_logs'
        Params   = $Params
    }

    $AllActivity = Invoke-HuduRequestPaginated -HuduRequest $HuduRequest

    if ($EndDate) {
        $AllActivity = $AllActivity | Where-Object { $([DateTime]::Parse($_.created_at)) -le $EndDate }
    }

    return $AllActivity
}