Import-Module "$PSScriptRoot\Select-PSBabushkaDep.psm1" -Force -DisableNameChecking
Import-Module "$PSScriptRoot\New-PSBabushkaDep.psm1" -Force -DisableNameChecking
Import-Module "$PSScriptRoot\Invoke-PSBabushkaDep.psm1" -Force -DisableNameChecking

function Invoke-PSBabushka {
  param(
    [Parameter(Mandatory=$True)] [String] $Name,
    [Parameter(Mandatory=$False)] [String] $Path = (Get-Location)
  )

  $PSBabushka.Deps = Get-ChildItem -Path $Path -Directory -Include 'PSBabushkaDeps' -Recurse | ForEach-Object { $_.PSPath } | ForEach-Object { Get-ChildItem -Path $_ -File -Include "*.Dep.ps1" -Recurse } | ForEach-Object { $_.PSPath } | ForEach-Object { Invoke-Expression $_ }

  $PSBabushka.Dep = Select-PSBabushkaDep -Name $Name

  Invoke-PSBabushkaDep -BabushkaDep $PSBabushka.Dep
}
