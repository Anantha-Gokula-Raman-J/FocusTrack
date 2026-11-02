param([string]$FlutterSdk)
$ErrorActionPreference='Stop'
. "$PSScriptRoot/flutter-environment.ps1"
$FlutterSdk=Resolve-FlutterSdk -FlutterSdk $FlutterSdk
$root=Split-Path $PSScriptRoot -Parent
$start=[System.Diagnostics.ProcessStartInfo]::new()
$start.FileName=Join-Path $FlutterSdk 'bin/cache/dart-sdk/bin/dart.exe'
$snapshot=Join-Path $FlutterSdk 'bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot'
$cache=Join-Path $root 'work/analysis-cache'
$start.Arguments='"'+$snapshot+'" --cache="'+$cache+'"'
$start.RedirectStandardInput=$true
$start.RedirectStandardOutput=$true
$start.RedirectStandardError=$true
$start.UseShellExecute=$false
$start.CreateNoWindow=$true
$process=[System.Diagnostics.Process]::Start($start)
$stderr=$process.StandardError.ReadToEndAsync()
try {
  $process.StandardInput.WriteLine('{"id":"1","method":"server.setSubscriptions","params":{"subscriptions":["STATUS"]}}')
  $process.StandardInput.WriteLine((@{id='2';method='analysis.setAnalysisRoots';params=@{included=@((Join-Path $root 'lib'),(Join-Path $root 'test'));excluded=@()}} | ConvertTo-Json -Compress -Depth 5))
  $active=$false
  $complete=$false
  $errors=@{}
  $deadline=[DateTime]::UtcNow.AddMinutes(2)
  while(-not $process.HasExited -and [DateTime]::UtcNow -lt $deadline) {
    $pending=$process.StandardOutput.ReadLineAsync()
    if(-not $pending.Wait(30000)){throw 'Analyzer timed out waiting for output'}
    $line=$pending.Result
    if(-not $line){break}
    $message=$line | ConvertFrom-Json
    if($message.error){throw "Analyzer protocol failure: $line"}
    if($message.event -eq 'analysis.errors'){
      $errors[$message.params.file]=@($message.params.errors | Where-Object severity -In @('ERROR','WARNING'))
    }
    if($message.event -eq 'server.error'){throw "Analyzer failure: $line"}
    if($message.event -eq 'server.status'){
      if($message.params.analysis.isAnalyzing){$active=$true}
      elseif($active){$complete=$true;break}
    }
  }
  if(-not $complete){throw 'Analyzer ended without completing analysis'}
  $diagnostics=@($errors.Values | ForEach-Object {$_})
  if($diagnostics.Count){
    $diagnostics | ConvertTo-Json -Depth 8 | Write-Output
    throw 'Static analysis reported errors or warnings'
  }
  $process.StandardInput.WriteLine('{"id":"3","method":"server.shutdown"}')
  Write-Output 'Static analysis passed.'
} finally {
  if(-not $process.WaitForExit(5000)){$process.Kill()}
  $process.Dispose()
}
