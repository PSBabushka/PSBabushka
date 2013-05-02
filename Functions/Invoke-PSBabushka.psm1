Import-Module "$PSScriptRoot\Find-PSBabushkaDep.psm1" -Force -DisableNameChecking
Import-Module "$PSScriptRoot\Define-PSBabushkaDep.psm1" -Force -DisableNameChecking
Import-Module "$PSScriptRoot\Invoke-PSBabushkaDep.psm1" -Force -DisableNameChecking

function Invoke-PSBabushka {
  param(
    [Parameter(Mandatory=$True)] [String] $Name,
    [Parameter(Mandatory=$False)] [String] $Path = (Get-Location)
  )

  $PSBabushka.Deps = Get-ChildItem -Path $Path -Include "*.Dep.ps1" -Recurse | ForEach-Object { $_.PSPath } | ForEach-Object { Invoke-Expression $_ }

  $PSBabushka.Dep = Find-PSBabushkaDep -Name $Name

  Invoke-PSBabushkaDep -BabushkaDep $PSBabushka.Dep
}
