function ConvertTo-WorkflowMermaid {
    param(
        $WorkflowRecord
    )

    $workflowNodeId = ConvertTo-MermaidNodeId -Seed ("workflow_$($WorkflowRecord.Id)")
    $triggerNodeId = ConvertTo-MermaidNodeId -Seed ("trigger_$($WorkflowRecord.Id)")
    $scopeNodeId = ConvertTo-MermaidNodeId -Seed ("scope_$($WorkflowRecord.Id)")
    $diagramLines = [System.Collections.Generic.List[string]]::new()

    $diagramLines.Add('flowchart TD')
    $diagramLines.Add(('    {0}["{1}<br/>{2}"]' -f $workflowNodeId, (ConvertTo-MermaidSafeText -Value $WorkflowRecord.DisplayName), (ConvertTo-MermaidSafeText -Value $WorkflowRecord.Category)))
    $diagramLines.Add(('    {0}["Trigger<br/>{1}"]' -f $triggerNodeId, (ConvertTo-MermaidSafeText -Value $WorkflowRecord.TriggerSummary)))
    $diagramLines.Add(('    {0}["Scope<br/>{1}"]' -f $scopeNodeId, (ConvertTo-MermaidSafeText -Value $WorkflowRecord.ScopeSummary)))
    $diagramLines.Add("    $workflowNodeId --> $triggerNodeId")
    $diagramLines.Add("    $workflowNodeId --> $scopeNodeId")

    $previousTaskNodeId = $null
    foreach ($task in $WorkflowRecord.Tasks) {
        $taskNodeId = ConvertTo-MermaidNodeId -Seed ("task_$($WorkflowRecord.Id)_$($task.ExecutionSequence)")
        $taskType = if ($task.CustomExtension) {
            'Custom extension'
        }
        else {
            $task.DefinitionDisplayName
        }

        $taskLabelParts = [System.Collections.Generic.List[string]]::new()
        $taskLabelParts.Add("[$($task.ExecutionSequence)] $(ConvertTo-MermaidSafeText -Value $task.DisplayName)")
        $taskLabelParts.Add((ConvertTo-MermaidSafeText -Value $taskType))
        $logicAppUrl = $null
        if ($task.CustomExtension) {
            $taskLabelParts.Add("Logic App: $(ConvertTo-MermaidSafeText -Value $task.CustomExtension.LogicAppName)")
            if ($task.CustomExtension.SubscriptionId -and $task.CustomExtension.ResourceGroupName -and $task.CustomExtension.LogicAppName) {
                $logicAppUrl = "https://portal.azure.com/#resource/subscriptions/$([Uri]::EscapeDataString($task.CustomExtension.SubscriptionId))/resourceGroups/$([Uri]::EscapeDataString($task.CustomExtension.ResourceGroupName))/providers/Microsoft.Logic/workflows/$([Uri]::EscapeDataString($task.CustomExtension.LogicAppName))"
            }
        }

        $diagramLines.Add(('    {0}["{1}"]' -f $taskNodeId, ($taskLabelParts -join '<br/>')))
        if ($null -eq $previousTaskNodeId) {
            $diagramLines.Add("    $workflowNodeId --> $taskNodeId")
        }
        else {
            $diagramLines.Add("    $previousTaskNodeId --> $taskNodeId")
        }

        $className = if ($task.IsEnabled) { 'enabledTask' } else { 'disabledTask' }
        if ($task.CustomExtension) {
            $className = 'customTask'
        }

        $diagramLines.Add("    class $taskNodeId $className")
        if ($logicAppUrl) {
            $diagramLines.Add("    click $taskNodeId href `"$logicAppUrl`" _blank")
        }
        $previousTaskNodeId = $taskNodeId
    }

    $diagramLines.Add("    class $workflowNodeId workflowNode")
    $diagramLines.Add("    class $triggerNodeId metaNode")
    $diagramLines.Add("    class $scopeNodeId metaNode")
    $diagramLines.Add('    classDef workflowNode fill:#16324f,color:#ffffff,stroke:#16324f,stroke-width:2px')
    $diagramLines.Add('    classDef metaNode fill:#eef4ed,color:#132a13,stroke:#4f772d,stroke-width:1px')
    $diagramLines.Add('    classDef enabledTask fill:#d9f2e6,color:#0b3d2e,stroke:#2d6a4f,stroke-width:1px')
    $diagramLines.Add('    classDef disabledTask fill:#f3f4f6,color:#3f3f46,stroke:#a1a1aa,stroke-dasharray: 5 5')
    $diagramLines.Add('    classDef customTask fill:#ffe8cc,color:#7c2d12,stroke:#c2410c,stroke-width:1px')

    return ($diagramLines -join [Environment]::NewLine)
}