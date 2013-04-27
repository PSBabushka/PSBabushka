Import-Module "$PSScriptRoot\Find-PSBabushkaDep.psm1" -Force

function Invoke-PSBabushka {
  param(
    [Parameter(Mandatory=$True)] [String] $Name
  )

  $PSBabushka.Deps = Get-ChildItem -Path (Get-Location) -Include "*.Dep.ps1" -Recurse | ForEach-Object { $_.PSPath } | ForEach-Object { Invoke-Expression $_ }

  $PSBabushka.Dep = Find-PSBabushkaDep -Name $Name

  Invoke-PSBabushkaDep -BabushkaDep $PSBabushka.Dep
}
