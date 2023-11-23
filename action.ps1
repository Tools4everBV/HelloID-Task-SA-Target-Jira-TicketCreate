# HelloID-Task-SA-Target-Jira-TicketCreate
##########################################
# Form mapping
$formObject = @{
    fields = @{
        project = @{
            key = $form.projectId
        }
        summary = $form.summary
        description = $form.description
        issuetype = @{
            name = $form.type
        }
    }
}

try {
    Write-Information "Executing Jira action: [TicketCreate]"
    $auth = $($JiraUserName) + ':' + $($JiraApiToken)
    $encoded = [System.Text.Encoding]::UTF8.GetBytes($auth)
    $authorization = [System.Convert]::ToBase64String($Encoded)

    $splatParams = @{
        Uri         = "$($JiraBaseUrl)/rest/api/latest/issue"
        Method      = 'POST'
        ContentType = 'application/json'
        Body        = ([System.Text.Encoding]::UTF8.GetBytes(($formObject | ConvertTo-Json)))
        Headers     = @{
            'Authorization' = "Basic $($authorization)"
        }

    }
    $response = Invoke-RestMethod @splatParams

    $auditLog = @{
        Action            = 'CreateResource'
        System            = 'Jira'
        TargetIdentifier  = $response.id
        TargetDisplayName = ''
        Message           = "Jira action: [TicketCreate] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Information "Jira action: [TicketCreate] executed successfully"
} catch {
    $ex = $_
    $auditLog = @{
        Action            = 'CreateResource'
        System            = 'Jira'
        TargetIdentifier  = ''
        TargetDisplayName = ''
        Message           = "Could not execute Jira action: [TicketCreate], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute Jira action: [TicketCreate], error: $($ex.ErrorDetails.Message)"
        Write-Error "Could not execute Jira action: [TicketCreate], error: $($ex.ErrorDetails.Message)"
    } else {
        Write-Information -Tags "Audit" -MessageData $auditLog
        Write-Error "Could not execute Jira action: [TicketCreate], error: $($ex.Exception.Message)"
    }
}
########################################
