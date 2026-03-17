function Get-TriggerSummary {
    param(
        [AllowNull()]
        $Trigger
    )

    if ($null -eq $Trigger) {
        return 'None'
    }

    $triggerType = $Trigger.'@odata.type'
    switch ($triggerType) {
        '#microsoft.graph.identityGovernance.timeBasedAttributeTrigger' {
            return "Time-based: $($Trigger.timeBasedAttribute) ($($Trigger.offsetInDays) days)"
        }
        '#microsoft.graph.identityGovernance.attributeChangeTrigger' {
            $attributeNames = @($Trigger.triggerAttributes | ForEach-Object { $_.name }) -join ', '
            if ([string]::IsNullOrWhiteSpace($attributeNames)) {
                $attributeNames = 'attribute change'
            }

            return "Attribute change: $attributeNames"
        }
        default {
            return ($Trigger | ConvertTo-Json -Depth 10 -Compress)
        }
    }
}