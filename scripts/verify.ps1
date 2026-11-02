param([string]$FlutterSdk,[switch]$Build,[switch]$UseJitAnalyzer,[switch]$Diagnostics)
$ErrorActionPreference='Stop'
. "$PSScriptRoot/flutter-environment.ps1"
$FlutterSdk=Resolve-FlutterSdk -FlutterSdk $FlutterSdk
function Invoke-CheckedTool {
  param([string]$Program,[string[]]$Arguments)
  for($attempt=1;$attempt -le 3;$attempt++){
    & $Program @Arguments
    $result=$LASTEXITCODE
    if($result -eq 0){return}
    if($result -ne -1073741816 -or $attempt -eq 3){
      throw "$Program failed with exit code $result"
    }
    Write-Warning 'Toolchain invalid-handle failure; retrying the same check.'
  }
}
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
  & "$PSScriptRoot/check-architecture.ps1"
  $env:PUB_CACHE=Join-Path $env:LOCALAPPDATA 'Pub/Cache'
  $env:TEMP=Join-Path $root 'work/temp'
  $env:TMP=$env:TEMP
  New-Item -ItemType Directory -Force $env:TEMP | Out-Null
  $flutter=Join-Path $FlutterSdk 'bin/flutter.bat'
  $dart=Join-Path $FlutterSdk 'bin/dart.bat'
  Invoke-CheckedTool -Program $dart -Arguments @('format','--output=none','--set-exit-if-changed','lib','test')
  if($UseJitAnalyzer){
    & "$PSScriptRoot/analyze.ps1" -FlutterSdk $FlutterSdk
  } else {
    Invoke-CheckedTool -Program $flutter -Arguments @('analyze','--no-pub')
  }
  Invoke-CheckedTool -Program $flutter -Arguments @('test','--no-pub','--concurrency=1')
  if($Build){
    Invoke-CheckedTool -Program $flutter -Arguments @('build','windows','--release','--no-pub','--no-tree-shake-icons')
  }
  Write-Output 'Verification passed.'
} finally { Pop-Location }
