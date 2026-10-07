param([int]$Port = 8877)
$ErrorActionPreference = 'Stop'
$webRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'web'))
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $Port)
$listener.Start()
$mime = @{'.html'='text/html; charset=utf-8';'.js'='text/javascript';'.wasm'='application/wasm';'.pck'='application/octet-stream';'.png'='image/png';'.svg'='image/svg+xml'}
$idleTimer = [Diagnostics.Stopwatch]::StartNew()
try {
    while ($idleTimer.Elapsed.TotalMinutes -lt 30) {
        if (-not $listener.Pending()) { Start-Sleep -Milliseconds 50; continue }
        $client = $listener.AcceptTcpClient()
        $idleTimer.Restart()
        try {
            $stream = $client.GetStream()
            $stream.ReadTimeout = 3000
            $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            do { $line = $reader.ReadLine() } while ($null -ne $line -and $line.Length -gt 0)
            $requestPath = ($requestLine -split ' ')[1]
            $relative = [Uri]::UnescapeDataString(($requestPath -split '\?')[0]).TrimStart('/')
            if ($relative -eq '') { $relative = 'index.html' }
            $target = [IO.Path]::GetFullPath((Join-Path $webRoot $relative))
            $valid = $target.StartsWith($webRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
            if ($valid -and [IO.File]::Exists($target)) {
                $content = [IO.File]::ReadAllBytes($target)
                $type = $mime[[IO.Path]::GetExtension($target)]
                if (-not $type) { $type = 'application/octet-stream' }
                $header = "HTTP/1.1 200 OK`r`nContent-Type: $type`r`nContent-Length: $($content.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n`r`n"
            } else {
                $content = [Text.Encoding]::UTF8.GetBytes('Archivo no encontrado')
                $header = "HTTP/1.1 404 Not Found`r`nContent-Length: $($content.Length)`r`nConnection: close`r`n`r`n"
            }
            $headerBytes = [Text.Encoding]::ASCII.GetBytes($header)
            $stream.Write($headerBytes,0,$headerBytes.Length)
            $stream.Write($content,0,$content.Length)
            $stream.Flush()
        } catch {} finally { $client.Close() }
    }
} finally { $listener.Stop() }
