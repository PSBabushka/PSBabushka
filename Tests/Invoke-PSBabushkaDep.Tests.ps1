$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Define-PSBabushkaDep.psm1') -Force -DisableNameChecking
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Invoke-PSBabushkaDep.psm1') -Force -DisableNameChecking

Describe 'Invoke-PSBabushkaDep' {
  Context 'Unmet' {
    It 'Invokes Meet' {
      $UnmetDep = Define-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True }
      Invoke-PSBabushkaDep $UnmetDep | Out-Null
      $PSBabushka.Test | Should Be $True
      $PSBabushka.Reset.Invoke()
    }

    It 'Checks Met Again After Invoking Meet' {
      $PSBabushka.MetCount = 0
      $UnmetDep = Define-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.MetCount++; $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True }
      Invoke-PSBabushkaDep $UnmetDep
      $PSBabushka.MetCount | Should Be 2
      $PSBabushka.Reset.Invoke()
    }

    It 'Invokes Before' {
      $UnmetDep = Define-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True } -Before { $PSBabushka.Before = 'Before' }
      Invoke-PSBabushkaDep $UnmetDep | Out-Null
      $PSBabushka.Before | Should Be 'Before'
      $PSBabushka.Reset.Invoke()
    }
    
    It 'Invokes After' {
      $UnmetDep = Define-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True } -After { $PSBabushka.After = 'After' }
      Invoke-PSBabushkaDep $UnmetDep | Out-Null
      $PSBabushka.After | Should Be 'After'
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Already Met' {
    It 'Does Not Invoke Meet' {
      $DepAlreadyMet = Define-PSBabushkaDep -Name 'Already Met' -Met { $True } -Meet { $PSBabushka.Test = 'Failed' }
      Invoke-PSBabushkaDep $DepAlreadyMet | Out-Null
      $PSBabushka.Test | Should Not Be 'Failed'
      $PSBabushka.Reset.Invoke()
    }

    It 'Does Not Invoke Before' {
      $DepAlreadyMet = Define-PSBabushkaDep -Name 'Already Met' -Met { $True } -Meet {} -Before { $PSBabushka.Test = 'Failed' }
      Invoke-PSBabushkaDep $DepAlreadyMet | Out-Null
      $PSBabushka.Test | Should Not Be 'Failed'
      $PSBabushka.Reset.Invoke()
    }

    It 'Does Not Invoke After' {
      $DepAlreadyMet = Define-PSBabushkaDep -Name 'Already Met' -Met { $True } -Meet {} -After { $PSBabushka.Test = 'Failed' }
      Invoke-PSBabushkaDep $DepAlreadyMet | Out-Null
      $PSBabushka.Test | Should Not Be 'Failed'
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Unmeetable Dep' {
    It 'Throws' {
      $UnmeetableDep = Define-PSBabushkaDep -Name 'Unmeetable' -Met { $False } -Meet { }
      PesterThrow { Invoke-PSBabushkaDep $UnmeetableDep } | Should Be $True
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Requires' {
    It 'Recurses Over Required Deps' {
      $ChildDep = Define-PSBabushkaDep -Name 'Child' -Met { $PSBabushka.Child -eq $True } -Meet { $PSBabushka.Child = $True }
      $PSBabushka.Deps = @($ChildDep)
      $ParentDep = Define-PSBabushkaDep -Name 'Parent' -Met { $PSBabushka.Parent -eq $True } -Meet { $PSBabushka.Parent = $True } -Requires 'Child'
      Invoke-PSBabushkaDep $ParentDep | Out-Null
      $PSBabushka.Child | Should Be $True
      $PSBabushka.Reset.Invoke()
    }
  }
}
