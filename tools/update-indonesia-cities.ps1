$ErrorActionPreference = 'Stop'

$sourceUrl = 'https://download.geonames.org/export/dump/ID.zip'
$temporaryDirectory = Join-Path $env:TEMP 'astroguide-geonames'
$archivePath = Join-Path $temporaryDirectory 'ID.zip'
$outputPath = Join-Path $PSScriptRoot '..\apps\astroguide\assets\data\indonesia_cities.json'

New-Item -ItemType Directory -Path $temporaryDirectory -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
Invoke-WebRequest -Uri $sourceUrl -OutFile $archivePath

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    $entry = $archive.GetEntry('ID.txt')
    if ($null -eq $entry) {
        throw 'The GeoNames archive does not contain ID.txt.'
    }

    $reader = [System.IO.StreamReader]::new($entry.Open(), [System.Text.Encoding]::UTF8)
    $cities = [System.Collections.Generic.List[object]]::new()
    try {
        while ($null -ne ($line = $reader.ReadLine())) {
            $fields = $line.Split("`t")
            if ($fields.Length -lt 18 -or $fields[6] -ne 'P') {
                continue
            }

            $population = 0
            [void][int]::TryParse($fields[14], [ref]$population)
            if ($population -lt 500 -and $fields[7] -notmatch '^PPLA|^PPLC') {
                continue
            }

            $latitude = 0.0
            $longitude = 0.0
            if (-not [double]::TryParse(
                $fields[4],
                [System.Globalization.NumberStyles]::Float,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [ref]$latitude
            ) -or -not [double]::TryParse(
                $fields[5],
                [System.Globalization.NumberStyles]::Float,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [ref]$longitude
            )) {
                continue
            }

            if ([string]::IsNullOrWhiteSpace($fields[17])) {
                continue
            }

            $cities.Add([ordered]@{
                id = [int]$fields[0]
                name = $fields[1]
                regionCode = $fields[10]
                latitude = $latitude
                longitude = $longitude
                timeZone = $fields[17]
                population = $population
            })
        }
    } finally {
        $reader.Dispose()
    }
} finally {
    $archive.Dispose()
}

$orderedCities = @($cities | Sort-Object -Property @{ Expression = 'population'; Descending = $true }, name, id)
$json = ConvertTo-Json -InputObject $orderedCities -Depth 3 -Compress
[System.IO.File]::WriteAllText(
    [System.IO.Path]::GetFullPath($outputPath),
    $json,
    [System.Text.UTF8Encoding]::new($false)
)
Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
Write-Output "Wrote $($orderedCities.Count) Indonesia city records to $outputPath"
