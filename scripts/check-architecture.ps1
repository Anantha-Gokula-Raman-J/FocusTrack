$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$required=@('AGENTS.md','docs/specs/README.md','docs/specs/architecture.md','docs/specs/edge-cases.md','docs/specs/verification.md','lib/domain/activity_repository.dart','lib/application/workspace_controller.dart')
foreach($file in $required){
  if(-not(Test-Path -LiteralPath (Join-Path $root $file))){throw "Missing harness file: $file"}
}
$main=Get-Content -LiteralPath (Join-Path $root 'lib/main.dart') -Raw
if(($main -split '\r?\n').Count -gt 30 -or $main -match '\bclass\s|\bWidget\s|\bTimer\b'){throw 'main.dart must remain a small bootstrap entrypoint'}
foreach($file in Get-ChildItem (Join-Path $root 'lib/domain') -Filter '*.dart'){
  if((Get-Content $file.FullName -Raw) -match 'package:flutter|dart:io|\.\./(?:app|application|data|platform|presentation)/'){
    throw "Domain dependency violation: $($file.Name)"
  }
}
foreach($file in Get-ChildItem (Join-Path $root 'lib/presentation') -Filter '*.dart'){
  if((Get-Content $file.FullName -Raw) -match 'MethodChannel|invokeMethod|store\.change|store\.data|store\.todos|store\.days'){
    throw "Presentation bypasses an application/repository boundary: $($file.Name)"
  }
}


foreach($file in Get-ChildItem (Join-Path $root 'lib/application') -Filter '*.dart'){
  if((Get-Content $file.FullName -Raw) -match 'BuildContext|import.+\.\./data/|store\.change|store\.data'){
    # The class documentation may mention BuildContext without depending on it.
    $code=(Get-Content $file.FullName | Where-Object {$_ -notmatch '^\s*//'}) -join [Environment]::NewLine
    if($code -match 'BuildContext|import.+\.\./data/|store\.change|store\.data'){
      throw "Application dependency violation: $($file.Name)"
    }
  }
}
Write-Output 'Architecture boundaries passed.'

# Prevent old current-identity names from returning; migration literals are allowed.
$pubspec=Get-Content -LiteralPath (Join-Path $root 'pubspec.yaml') -Raw
if($pubspec -notmatch '(?m)^name:\s*focustrack\s*$'){throw 'Dart package must be focustrack'}
$identityFiles=@(
  (Get-ChildItem (Join-Path $root 'lib') -Recurse -Filter '*.dart').FullName
  (Get-ChildItem (Join-Path $root 'test') -Recurse -Filter '*.dart').FullName
  (Join-Path $root 'windows/CMakeLists.txt')
  (Join-Path $root 'windows/runner/flutter_window.cpp')
)
foreach($file in $identityFiles){
  if((Get-Content -LiteralPath $file -Raw) -match 'package:daymark/|\bDaymark(App|Store)\b|daymark/windows|project\(daymark'){
    throw "Obsolete current identity: $file"
  }
}
Write-Output 'FocusTrack naming checks passed.'
