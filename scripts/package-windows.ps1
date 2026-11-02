param(
  [string]$ReleaseDirectory = (Join-Path $PSScriptRoot '..\build\windows\x64\runner\Release'),
  [Parameter(Mandatory=$true)][string]$RuntimeDirectory,
  [Parameter(Mandatory=$true)][string]$FlutterSdk,
  [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\dist')
)
$ErrorActionPreference='Stop'
$release=(Resolve-Path -LiteralPath $ReleaseDirectory).Path
$runtime=(Resolve-Path -LiteralPath $RuntimeDirectory).Path
foreach ($file in @('focustrack.exe','flutter_windows.dll','data\app.so','data\icudtl.dat')) {
  if (-not (Test-Path -LiteralPath (Join-Path $release $file))) { throw "Missing release file: $file" }
}
foreach ($file in @('msvcp140.dll','vcruntime140.dll','vcruntime140_1.dll')) {
  if (-not (Test-Path -LiteralPath (Join-Path $runtime $file))) { throw "Missing release CRT: $file" }
}
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$package=Join-Path $OutputDirectory 'FocusTrack-1.2.2-Windows-x64'
if (Test-Path -LiteralPath $package) { throw 'Choose a fresh output directory to avoid packaging stale files.' }
New-Item -ItemType Directory -Path $package | Out-Null
$package=(Resolve-Path -LiteralPath $package).Path
Copy-Item -LiteralPath (Join-Path $release 'focustrack.exe'),(Join-Path $release 'flutter_windows.dll'),(Join-Path $release 'data') -Destination $package -Recurse
Get-ChildItem -LiteralPath $runtime -Filter '*.dll' | Copy-Item -Destination $package
Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\LICENSE') -Destination $package
Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\packaging\START-HERE.txt'),(Join-Path $PSScriptRoot '..\packaging\THIRD-PARTY-NOTICES.txt') -Destination $package
Copy-Item -LiteralPath (Join-Path $FlutterSdk 'bin\cache\artifacts\engine\windows-x64-release\license.windows_flutter.md') -Destination (Join-Path $package 'FLUTTER-LICENSES.md')
Copy-Item -LiteralPath (Join-Path $FlutterSdk 'bin\cache\artifacts\material_fonts\materialicons_license.txt') -Destination (Join-Path $package 'MATERIAL-ICONS-LICENSE.txt')
Get-ChildItem -LiteralPath $package -Recurse -File | ForEach-Object { '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName).Hash, $_.FullName.Substring($package.Length+1) } | Set-Content -Encoding ascii (Join-Path $package 'SHA256SUMS.txt')
Compress-Archive -LiteralPath $package -DestinationPath "$package.zip" -CompressionLevel Optimal
Get-FileHash -LiteralPath "$package.zip"
