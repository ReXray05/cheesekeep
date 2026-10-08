$ErrorActionPreference = 'Stop'
$projectFile = Join-Path $PSScriptRoot 'project.godot'
if (-not (Test-Path -LiteralPath $projectFile)) { $projectFile = Join-Path $PSScriptRoot 'project/project.godot' }
if (-not (Test-Path -LiteralPath $projectFile)) { throw 'No se encuentra project.godot junto al lanzador.' }
$projectDirectory = Split-Path -Parent $projectFile
$editorCandidates = @()
foreach ($commandName in @('godot','godot4')) {
    $editorCommand = Get-Command $commandName -ErrorAction SilentlyContinue
    if ($editorCommand) { $editorCandidates += $editorCommand.Source }
}
$searchFolders = @($PSScriptRoot, (Join-Path $env:USERPROFILE 'Downloads'))
$downloadsFolder = Join-Path $env:USERPROFILE 'Downloads'
if (Test-Path -LiteralPath $downloadsFolder) {
    $searchFolders += @(Get-ChildItem -LiteralPath $downloadsFolder -Directory -Filter 'Godot*' | ForEach-Object FullName)
}
foreach ($searchFolder in $searchFolders) {
    if (Test-Path -LiteralPath $searchFolder) {
        $editorCandidates += @(Get-ChildItem -LiteralPath $searchFolder -File -Filter 'Godot*.exe' | Where-Object Name -NotMatch '_console' | ForEach-Object FullName)
    }
}
$editorPath = $editorCandidates | Select-Object -First 1
if (-not $editorPath) { throw 'No se encuentra Godot. Descarga Godot 4.4.1 para Windows desde godotengine.org y extrae el ZIP en Descargas.' }
Start-Process -FilePath $editorPath -ArgumentList @('--editor','--path',('"' + $projectDirectory + '"')) -WindowStyle Normal
