$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Invoke-PSBabushka.psm1') -Force -DisableNameChecking

Describe 'Invoke-PSBabushka' {
  It 'Loads Deps Within Current Directory' {
    Setup -File -Path "A.Dep.ps1" -Content "Define-PSBabushkaDep -Name 'A' -Met { `$PSBabushka.A -eq `$True } -Meet { `$PSBabushka.A = `$True }"
    $TestDrive = Resolve-Path $TestDrive

    Invoke-PSBabushka -Name 'A' -Path $TestDrive

    $Dep = $PSBabushka.Deps | Where-Object { $_.Name -eq 'A' }
    
    $Dep.Path | Should Be "$TestDrive\A.Dep.ps1"
  }

  It 'Invokes The Given Dep' {
    Setup -File -Path "B.Dep.ps1" -Content "Define-PSBabushkaDep -Name 'B' -Met { `$PSBabushka.B -eq 'B' } -Meet { `$PSBabushka.B = 'B' }"

    Invoke-PSBabushka -Name 'B' -Path $TestDrive

    $PSBabushka.B | Should Be 'B'
  }
}
