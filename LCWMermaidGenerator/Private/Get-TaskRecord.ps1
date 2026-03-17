function Get-TaskRecord {
    param(
        $Workflow,
        $Task,
        $TaskDefinitions,
        $CustomTaskExtensions
    )

    $taskDefinition = $TaskDefinitions[$Task.TaskDefinitionId]
    $arguments = ConvertTo-OrderedArgumentMap -Arguments $Task.Arguments
    $isCustomExtensionTask = $Task.TaskDefinitionId -eq '4262b724-8dba-4fad-afc3-43fcbb497a0e'
    $customExtension = $null

    if ($isCustomExtensionTask) {
        $customTaskExtensionId = $arguments['customTaskExtensionID']
        if ([string]::IsNullOrWhiteSpace($customTaskExtensionId)) {
            Write-Warning "Unable to find custom task extension ID for task $($Task.Id) in workflow $($Workflow.DisplayName)."
        }
        else {
            $customExtension = $CustomTaskExtensions[$customTaskExtensionId]
        }
    }

    return [pscustomobject]@{
        Id = $Task.Id
        DefinitionId = $Task.TaskDefinitionId
        DefinitionDisplayName = $taskDefinition.DisplayName
        DisplayName = $Task.DisplayName
        IsEnabled = [bool]$Task.IsEnabled
        ExecutionSequence = [int]$Task.ExecutionSequence
        Arguments = $arguments
        CustomExtension = if ($customExtension) {
            [pscustomobject]@{
                Id = $customExtension.Id
                DisplayName = $customExtension.DisplayName
                Description = $customExtension.Description
                LogicAppName = $customExtension.EndpointConfiguration.AdditionalProperties.logicAppWorkflowName
                ResourceGroupName = $customExtension.EndpointConfiguration.AdditionalProperties.resourceGroupName
                SubscriptionId = $customExtension.EndpointConfiguration.AdditionalProperties.subscriptionId
            }
        }
        else {
            $null
        }
    }
}