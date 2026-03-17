function ConvertTo-OrderedArgumentMap {
    param(
        [AllowNull()]
        $Arguments
    )

    $map = [ordered]@{}
    foreach ($argument in @($Arguments)) {
        $map[$argument.Name] = $argument.Value
    }

    return $map
}