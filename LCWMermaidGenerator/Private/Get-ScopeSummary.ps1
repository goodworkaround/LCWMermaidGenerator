function Get-ScopeSummary {
    param(
        [AllowNull()]
        $Scope
    )

    if ($null -eq $Scope) {
        return 'None'
    }

    if ($Scope.rule) {
        return "Rule: $($Scope.rule)"
    }

    return ($Scope | ConvertTo-Json -Depth 10 -Compress)
}