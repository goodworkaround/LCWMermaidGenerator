function ConvertTo-MermaidNodeId {
    param(
        [string]$Seed
    )

    return ([regex]::Replace($Seed, '[^A-Za-z0-9_]', '_'))
}