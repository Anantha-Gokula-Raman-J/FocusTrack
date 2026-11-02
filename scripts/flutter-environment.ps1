function Resolve-FlutterSdk {
  param([string]$FlutterSdk)
  if(-not $FlutterSdk){$FlutterSdk=$env:FLUTTER_ROOT}
  if(-not $FlutterSdk){
    $command=Get-Command flutter.bat -ErrorAction SilentlyContinue
    if($command){$FlutterSdk=Split-Path (Split-Path $command.Source -Parent) -Parent}
  }
  if(-not $FlutterSdk -or -not(Test-Path -LiteralPath (Join-Path $FlutterSdk 'bin/flutter.bat'))){
    throw 'Flutter SDK not found. Add flutter/bin to PATH, set FLUTTER_ROOT, or pass -FlutterSdk.'
  }
  return (Resolve-Path -LiteralPath $FlutterSdk).Path
}
