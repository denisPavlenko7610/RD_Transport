param([string] $TemplateProject = '../UnityTemplates')

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$worktree = Join-Path $projectRoot '.unitytemplates'
$revision = (Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'UnityTemplates.revision')).Trim()

if (-not (Test-Path -LiteralPath $worktree)) {
    if (-not [IO.Path]::IsPathRooted($TemplateProject)) {
        $TemplateProject = Join-Path $projectRoot $TemplateProject
    }
    $TemplateProject = [IO.Path]::GetFullPath($TemplateProject)
    git -C $TemplateProject worktree add --detach $worktree $revision
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the pinned UnityTemplates worktree.' }
}

if (-not (Test-Path -LiteralPath (Join-Path $worktree '.git'))) {
    throw "Expected a Git worktree at $worktree."
}
$head = git -C $worktree rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $head -ne $revision) {
    throw "Expected UnityTemplates revision $revision at $worktree."
}

$sourceRoot = Join-Path $worktree 'Assets/UnityTemplates'
$linkRoot = Join-Path $projectRoot 'Assets/TemplateSources'
$folders = @(
    'Foundation/Runtime',
    'Kits/Framework/Save/Runtime',
    'Kits/Framework/SceneFlow/Editor',
    'Kits/Framework/SceneFlow/Runtime',
    'Kits/Framework/Settings/Runtime',
    'Kits/Framework/Startup/Runtime'
)

foreach ($folder in $folders) {
    $source = Join-Path $sourceRoot $folder
    $link = Join-Path $linkRoot $folder
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        throw "Template source is missing: $source"
    }
    $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($existing -and ($existing.LinkType -ne 'Junction' -or
        [IO.Path]::GetFullPath([string] @($existing.Target)[0]) -ne [IO.Path]::GetFullPath($source))) {
        throw "Destination already exists and points elsewhere: $link"
    }
}

# Preserve the source folder GUIDs alongside the local junctions.
foreach ($folder in $folders) {
    $relative = $folder
    while ($relative) {
        $destination = Join-Path $linkRoot "$relative.meta"
        if (-not (Test-Path -LiteralPath $destination)) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath (Join-Path $sourceRoot "$relative.meta") -Destination $destination
        }
        $relative = Split-Path -Parent $relative
    }
}
if (-not (Test-Path -LiteralPath "$linkRoot.meta")) {
    Copy-Item -LiteralPath "$sourceRoot.meta" -Destination "$linkRoot.meta"
}

foreach ($folder in $folders) {
    $link = Join-Path $linkRoot $folder
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $link) | Out-Null
    if (-not (Test-Path -LiteralPath $link)) {
        New-Item -ItemType Junction -Path $link -Target (Join-Path $sourceRoot $folder) | Out-Null
    }
}

Write-Host 'RD_Transport template sources linked.'
