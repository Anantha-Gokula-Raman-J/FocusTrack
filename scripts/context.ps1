param(
  [ValidateSet('prompts','settings','reports','storage','windows','ui','release','naming','architecture')]
  [string]$Task = 'architecture'
)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$required=@('README','product','architecture','edge-cases','verification','features')
$features=if($Task -eq 'architecture'){@('prompts','settings','reports','storage','windows','ui','release','naming')}else{@($Task)}
foreach($name in ($required+$features | Select-Object -Unique)){
  Write-Output ("--- docs/specs/{0}.md ---" -f $name)
  Get-Content -LiteralPath (Join-Path $root "docs/specs/$name.md")
}
