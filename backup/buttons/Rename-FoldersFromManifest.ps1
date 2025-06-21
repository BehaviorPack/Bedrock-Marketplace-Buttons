$root = Get-Location

Get-ChildItem -Recurse -Directory | ForEach-Object {
    $manifestPath = Join-Path $_.FullName "manifest.json"
    if (Test-Path $manifestPath) {
        try {
            $json = Get-Content $manifestPath -Raw | ConvertFrom-Json
            $name = $json.header.name

            if ($name -and ($_.Name -ne $name)) {
                # Sanitize name for Windows folder (remove invalid characters)
                $safeName = ($name -replace '[\\/:*?"<>|]', '_')

                $newPath = Join-Path $_.Parent.FullName $safeName

                if (-not (Test-Path $newPath)) {
                    Write-Host "Renaming '$($_.FullName)' to '$safeName'"
                    Rename-Item $_.FullName -NewName $safeName
                } else {
                    Write-Warning "Skipped: '$safeName' already exists."
                }
            }
        } catch {
            Write-Warning "Failed to read or parse: $manifestPath"
        }
    }
}
