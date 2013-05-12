Import-Module "$PSScriptRoot\Import-PSBabushkaDeps.psm1" -Force
Import-Module "$PSScriptRoot\Select-PSBabushkaDep.psm1" -Force
Import-Module "$PSScriptRoot\Invoke-PSBabushkaDep.psm1" -Force

Function Invoke-PSBabushka {
  Param (
    [Parameter(Mandatory=$True)]  [String] $Name,
    [Parameter(Mandatory=$False)] [String] $Path = (Get-Location)
  )

  Import-PSBabushkaDeps -From $Path -Into ([Ref] $PSBabushka)
  $PSBabushka.Dep = Select-PSBabushkaDep -Name $Name
  Invoke-PSBabushkaDep $PSBabushka.Dep
}
