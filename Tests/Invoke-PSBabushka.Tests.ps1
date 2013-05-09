$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Invoke-PSBabushka.psm1') -Force -DisableNameChecking

Describe 'Invoke-PSBabushka' {
  It 'Loads Deps with .Dep.ps1 extension under a PSBabushkaDeps directory' {
    Setup -File -Path "PSBabushkaDeps\A.Dep.ps1" -Content "Define-PSBabushkaDep -Name 'A' -Met { `$PSBabushka.A -eq 'A' } -Meet { `$PSBabushka.A = 'A' }"
    $TestDrive = Resolve-Path $TestDrive

    Invoke-PSBabushka -Name 'A' -Path $TestDrive

    $Dep = $PSBabushka.Deps | Where-Object { $_.Name -eq 'A' }
    $Dep.Path | Should Be "$TestDrive\PSBabushkaDeps\A.Dep.ps1"

    $PSBabushka.Reset.Invoke()
    Remove-Item "$TestDrive\PSBabushkaDeps\A.Dep.ps1"
  }

  It 'Does Not Load Deps under PSBabushkaDeps directory without the .Dep.ps1 extension' {
    $PSBabushka.Reset.Invoke()
    Setup -File -Path "PSBabushkaDeps\A.ps1" -Content "Define-PSBabushkaDep -Name 'A' -Met { `$PSBabushka.A -eq 'A' } -Meet { `$PSBabushka.A = 'A' }"
    $TestDrive = Resolve-Path $TestDrive

    try { Invoke-PSBabushka -Name 'A' -Path $TestDrive } catch { }

    $PSBabushka.Deps | Should Be $Null

    $PSBabushka.Reset.Invoke()
    Remove-Item "$TestDrive\PSBabushkaDeps\A.ps1"
  }

  It 'Does Not Load Deps with the .Dep.ps1 extension  under PSBabushkaDeps directory ' {
    Setup -File -Path "A.Dep.ps1" -Content "Define-PSBabushkaDep -Name 'A' -Met { `$PSBabushka.A -eq 'A' } -Meet { `$PSBabushka.A = 'A' }"
    $TestDrive = Resolve-Path $TestDrive

    try { Invoke-PSBabushka -Name 'A' -Path $TestDrive } catch { }

    $PSBabushka.Deps | Should Be $Null

    $PSBabushka.Reset.Invoke()
    Remove-Item "$TestDrive\A.Dep.ps1"
  }

  It 'Invokes The Given Dep' {
    Setup -File -Path "PSBabushkaDeps\A.Dep.ps1" -Content "Define-PSBabushkaDep -Name 'A' -Met { `$PSBabushka.A -eq 'A' } -Meet { `$PSBabushka.A = 'A' }"

    Invoke-PSBabushka -Name 'A' -Path $TestDrive

    $PSBabushka.A | Should Be 'A'

    $PSBabushka.Reset.Invoke()
    Remove-Item "$TestDrive\PSBabushkaDeps\A.Dep.ps1"
  }
}
