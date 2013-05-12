Import-Module "$PSScriptRoot\New-PSBabushkaDep.psm1" -Force

Function Import-PSBabushkaDeps {
  Param (
    [Parameter(Mandatory=$True)] [String] $From,
    [Parameter(Mandatory=$True)] [Ref]    $Into
  )

  $PSBabushkaDepDirs = Get-ChildItem -Path $From -Directory -Include 'PSBabushkaDeps' -Recurse
  $PSBabushkaDepFiles = $PSBabushkaDepDirs | ForEach-Object { Get-ChildItem -Path $_.FullName -File -Include "*.Dep.ps1" -Recurse }
  $Into.Value.Deps = $PSBabushkaDepFiles | ForEach-Object { Invoke-Expression $_.FullName }
}