function Format-NullableValue {
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return '-'
    }

    if ($Value -is [datetime]) {
        return $Value.ToString('yyyy-MM-dd HH:mm:ss')
    }

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) {
        return '-'
    }

    return $text
}