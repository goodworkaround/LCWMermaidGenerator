function ConvertTo-WorkflowConsoleText {
    param(
        $WorkflowRecord
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('-----------------------------------')
    $lines.Add("Name: $(Format-NullableValue -Value $WorkflowRecord.DisplayName)")
    $lines.Add("ID: $(Format-NullableValue -Value $WorkflowRecord.Id)")
    $lines.Add("Description: $(Format-NullableValue -Value $WorkflowRecord.Description)")
    $lines.Add("Category: $(Format-NullableValue -Value $WorkflowRecord.Category)")
    $lines.Add("Enabled: $(Format-NullableValue -Value $WorkflowRecord.IsEnabled)")
    $lines.Add("Scheduling enabled: $(Format-NullableValue -Value $WorkflowRecord.IsSchedulingEnabled)")
    $lines.Add("Created: $(Format-NullableValue -Value $WorkflowRecord.CreatedDateTime)")
    $lines.Add("Last modified: $(Format-NullableValue -Value $WorkflowRecord.LastModifiedDateTime)")
    $lines.Add("Trigger: $(Format-NullableValue -Value $WorkflowRecord.TriggerSummary)")
    $lines.Add("Scope: $(Format-NullableValue -Value $WorkflowRecord.ScopeSummary)")
    $lines.Add('Tasks:')

    foreach ($task in $WorkflowRecord.Tasks) {
        $status = if ($task.IsEnabled) { 'enabled' } else { 'disabled' }
        $definitionName = Format-NullableValue -Value $task.DefinitionDisplayName
        $taskName = Format-NullableValue -Value $task.DisplayName
        $lines.Add("  [$($task.ExecutionSequence)] $taskName ($definitionName, $status)")

        if ($task.CustomExtension) {
            $lines.Add("      Custom extension: $(Format-NullableValue -Value $task.CustomExtension.DisplayName)")
            $lines.Add("      Logic App: $(Format-NullableValue -Value $task.CustomExtension.LogicAppName)")
            $lines.Add("      Resource group: $(Format-NullableValue -Value $task.CustomExtension.ResourceGroupName)")
        }

        foreach ($argument in $task.Arguments.GetEnumerator()) {
            if ($argument.Key -eq 'customTaskExtensionID') {
                continue
            }

            $lines.Add("      $($argument.Key): $(Format-NullableValue -Value $argument.Value)")
        }
    }

    return ($lines -join [Environment]::NewLine)
}