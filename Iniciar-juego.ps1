$ErrorActionPreference = 'Stop'
$gamePort = 8877
$gameUrl = "http://127.0.0.1:$gamePort/index.html"
$responds = $false
try {
    $response = Invoke-WebRequest -Uri $gameUrl -UseBasicParsing -TimeoutSec 2
    $responds = $response.StatusCode -eq 200 -and $response.Content.Contains('Cheesekeep')
} catch {}
if (-not $responds) {
    $serverFile = Join-Path $PSScriptRoot 'Servidor-local.ps1'
    Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $serverFile + '"'), '-Port', $gamePort)
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        Start-Sleep -Milliseconds 200
        try {
            $response = Invoke-WebRequest -Uri $gameUrl -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) { $responds = $true; break }
        } catch {}
    }
}
if ($responds) { Start-Process $gameUrl }
else { Write-Host 'No se pudo abrir el servidor local. Consulta LEEME.md.'; Read-Host 'Pulsa Intro para cerrar' }
