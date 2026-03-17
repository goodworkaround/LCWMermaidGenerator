function ConvertTo-WorkflowMarkdown {
    param(
        $WorkflowRecord
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("## $($WorkflowRecord.DisplayName)")
    $lines.Add('')
    $lines.Add('| Property | Value |')
    $lines.Add('| --- | --- |')
    $lines.Add("| ID | $(Format-NullableValue -Value $WorkflowRecord.Id) |")
    $lines.Add("| Description | $(Format-NullableValue -Value $WorkflowRecord.Description) |")
    $lines.Add("| Category | $(Format-NullableValue -Value $WorkflowRecord.Category) |")
    $lines.Add("| Enabled | $(Format-NullableValue -Value $WorkflowRecord.IsEnabled) |")
    $lines.Add("| Scheduling enabled | $(Format-NullableValue -Value $WorkflowRecord.IsSchedulingEnabled) |")
    $lines.Add("| Created | $(Format-NullableValue -Value $WorkflowRecord.CreatedDateTime) |")
    $lines.Add("| Last modified | $(Format-NullableValue -Value $WorkflowRecord.LastModifiedDateTime) |")
    $lines.Add("| Trigger | $(Format-NullableValue -Value $WorkflowRecord.TriggerSummary) |")
    $lines.Add("| Scope | $(Format-NullableValue -Value $WorkflowRecord.ScopeSummary) |")
    $lines.Add('')
    $lines.Add('### Tasks')
    $lines.Add('')

    if ($WorkflowRecord.Tasks.Count -eq 0) {
        $lines.Add('No tasks found.')
    }
    else {
        foreach ($task in $WorkflowRecord.Tasks) {
            $status = if ($task.IsEnabled) { 'enabled' } else { 'disabled' }
            $lines.Add("- [$($task.ExecutionSequence)] $(Format-NullableValue -Value $task.DisplayName) ($status)")
            $lines.Add("  Definition: $(Format-NullableValue -Value $task.DefinitionDisplayName)")

            if ($task.CustomExtension) {
                $lines.Add("  Custom extension: $(Format-NullableValue -Value $task.CustomExtension.DisplayName)")
                $logicAppLink = if ($task.CustomExtension.SubscriptionId -and $task.CustomExtension.ResourceGroupName -and $task.CustomExtension.LogicAppName) {
                    $url = "https://portal.azure.com/#resource/subscriptions/$([Uri]::EscapeDataString($task.CustomExtension.SubscriptionId))/resourceGroups/$([Uri]::EscapeDataString($task.CustomExtension.ResourceGroupName))/providers/Microsoft.Logic/workflows/$([Uri]::EscapeDataString($task.CustomExtension.LogicAppName))"
                    "[$($task.CustomExtension.LogicAppName)]($url)"
                }
                else {
                    Format-NullableValue -Value $task.CustomExtension.LogicAppName
                }
                $lines.Add("  Logic App: $logicAppLink")
                $lines.Add("  Resource group: $(Format-NullableValue -Value $task.CustomExtension.ResourceGroupName)")
                $lines.Add("  Subscription: $(Format-NullableValue -Value $task.CustomExtension.SubscriptionId)")
            }

            foreach ($argument in $task.Arguments.GetEnumerator()) {
                if ($argument.Key -eq 'customTaskExtensionID') {
                    continue
                }

                $lines.Add("  Argument: $($argument.Key) = $(Format-NullableValue -Value $argument.Value)")
            }

            $lines.Add('')
        }
    }

    $lines.Add('### Mermaid')
    $lines.Add('')
    $lines.Add('```mermaid')
    $lines.Add((ConvertTo-WorkflowMermaid -WorkflowRecord $WorkflowRecord))
    $lines.Add('```')
    $lines.Add('')

    return ($lines -join [Environment]::NewLine)
}