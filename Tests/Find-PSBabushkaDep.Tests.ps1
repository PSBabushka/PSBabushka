$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\New-PSBabushkaDep.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Find-PSBabushkaDep.psm1') -Force -DisableNameChecking

Describe 'Find-PSBabushkaDep' {
  It 'Finds By Dep Name' {
    $DepA = New-PSBabushkaDep -Name 'A' -Met {} -Meet {}
    $DepB = New-PSBabushkaDep -Name 'B' -Met {} -Meet {}
    $DepC = New-PSBabushkaDep -Name 'C' -Met {} -Meet {}

    $PSBabushka.Deps = @($Dep1, $DepB, $DepC)
    
    Find-PSBabushkaDep -Name 'B' | Should Be $DepB
  }
}
