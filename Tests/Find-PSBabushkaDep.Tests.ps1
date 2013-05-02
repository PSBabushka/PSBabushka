$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Define-PSBabushkaDep.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Find-PSBabushkaDep.psm1') -Force -DisableNameChecking

Describe 'Find-PSBabushkaDep' {
  It 'Finds By Dep Name' {
    $DepA = Define-PSBabushkaDep -Name 'A' -Met {} -Meet {}
    $DepB = Define-PSBabushkaDep -Name 'B' -Met {} -Meet {}
    $DepC = Define-PSBabushkaDep -Name 'C' -Met {} -Meet {}

    $PSBabushka.Deps = @($Dep1, $DepB, $DepC)
    
    Find-PSBabushkaDep -Name 'B' | Should Be $DepB
  }
}
