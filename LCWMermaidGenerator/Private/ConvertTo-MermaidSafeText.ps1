function ConvertTo-MermaidSafeText {
    param(
        [AllowNull()]
        [string]$Value
    )

    $text = Format-NullableValue -Value $Value
    $text = $text.Replace('"', "'")
    $text = $text.Replace('[', '(')
    $text = $text.Replace(']', ')')
    $text = $text.Replace('{', '(')
    $text = $text.Replace('}', ')')
    $text = $text.Replace("`r", ' ')
    $text = $text.Replace("`n", '<br/>')
    return $text
}