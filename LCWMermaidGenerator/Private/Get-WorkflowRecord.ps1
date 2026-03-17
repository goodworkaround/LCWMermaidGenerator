function Get-WorkflowRecord {
    param(
        $Workflow,
        $TaskDefinitions,
        $CustomTaskExtensions
    )

    $fullWorkflow = Get-MgIdentityGovernanceLifecycleWorkflow -WorkflowId $Workflow.Id
    $trigger = $fullWorkflow.ExecutionConditions.AdditionalProperties.trigger
    $scope = $fullWorkflow.ExecutionConditions.AdditionalProperties.scope
    $tasks = @(
        $fullWorkflow.Tasks |
            Sort-Object ExecutionSequence |
            ForEach-Object {
                Get-TaskRecord -Workflow $fullWorkflow -Task $_ -TaskDefinitions $TaskDefinitions -CustomTaskExtensions $CustomTaskExtensions
            }
    )

    return [pscustomobject]@{
        Id = $fullWorkflow.Id
        DisplayName = $fullWorkflow.DisplayName
        Description = $fullWorkflow.Description
        Category = $fullWorkflow.Category
        IsEnabled = [bool]$fullWorkflow.IsEnabled
        IsSchedulingEnabled = [bool]$fullWorkflow.IsSchedulingEnabled
        CreatedDateTime = $fullWorkflow.CreatedDateTime
        LastModifiedDateTime = $fullWorkflow.LastModifiedDateTime
        Trigger = $trigger
        TriggerSummary = Get-TriggerSummary -Trigger $trigger
        Scope = $scope
        ScopeSummary = Get-ScopeSummary -Scope $scope
        Tasks = $tasks
    }
}