$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka') -Force
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Invoke-PSBabushkaDep.psm1') -Force

Describe 'Invoke-PSBabushkaDep' {
  Context 'Unmet' {
    It 'Invokes Meet' {
      $UnmetDep = New-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True }
      Invoke-PSBabushkaDep $UnmetDep | Out-Null
      $PSBabushka.Test | Should Be $True
      $PSBabushka.Reset.Invoke()
    }

    It 'Checks Met Again After Invoking Meet' {
      $PSBabushka.MetCount = 0
      $UnmetDep = New-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.MetCount++; $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True }
      Invoke-PSBabushkaDep $UnmetDep
      $PSBabushka.MetCount | Should Be 2
      $PSBabushka.Reset.Invoke()
    }

    It 'Invokes Before' {
      $UnmetDep = New-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True } -Before { $PSBabushka.Before = 'Before' }
      Invoke-PSBabushkaDep $UnmetDep | Out-Null
      $PSBabushka.Before | Should Be 'Before'
      $PSBabushka.Reset.Invoke()
    }
    
    It 'Invokes After' {
      $UnmetDep = New-PSBabushkaDep -Name 'Unmet' -Met { $PSBabushka.Test -eq $True } -Meet { $PSBabushka.Test = $True } -After { $PSBabushka.After = 'After' }
      Invoke-PSBabushkaDep $UnmetDep | Out-Null
      $PSBabushka.After | Should Be 'After'
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Already Met' {
    It 'Does Not Invoke Meet' {
      $DepAlreadyMet = New-PSBabushkaDep -Name 'Already Met' -Met { $True } -Meet { $PSBabushka.Test = 'Failed' }
      Invoke-PSBabushkaDep $DepAlreadyMet | Out-Null
      $PSBabushka.Test | Should Not Be 'Failed'
      $PSBabushka.Reset.Invoke()
    }

    It 'Does Not Invoke Before' {
      $DepAlreadyMet = New-PSBabushkaDep -Name 'Already Met' -Met { $True } -Meet {} -Before { $PSBabushka.Test = 'Failed' }
      Invoke-PSBabushkaDep $DepAlreadyMet | Out-Null
      $PSBabushka.Test | Should Not Be 'Failed'
      $PSBabushka.Reset.Invoke()
    }

    It 'Does Not Invoke After' {
      $DepAlreadyMet = New-PSBabushkaDep -Name 'Already Met' -Met { $True } -Meet {} -After { $PSBabushka.Test = 'Failed' }
      Invoke-PSBabushkaDep $DepAlreadyMet | Out-Null
      $PSBabushka.Test | Should Not Be 'Failed'
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Unmeetable Dep' {
    It 'Throws' {
      $UnmeetableDep = New-PSBabushkaDep -Name 'Unmeetable' -Met { $False } -Meet { }
      PesterThrow { Invoke-PSBabushkaDep $UnmeetableDep } | Should Be $True
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Requires' {
    It 'Recurses Over Required Deps' {
      $ChildDep = New-PSBabushkaDep -Name 'Child' -Met { $PSBabushka.Child -eq $True } -Meet { $PSBabushka.Child = $True }
      $PSBabushka.Deps = @($ChildDep)
      $ParentDep = New-PSBabushkaDep -Name 'Parent' -Requires 'Child' -Met { $PSBabushka.Parent -eq $True } -Meet { $PSBabushka.Parent = $True }
      Invoke-PSBabushkaDep $ParentDep | Out-Null
      $PSBabushka.Child | Should Be $True
      $PSBabushka.Reset.Invoke()
    }
  }

  Context 'Requires When Unmet' {
    It 'Invokes the RequiresWhenUnmet block when the Dep is Unmet' {
      $ChildDep = New-PSBabushkaDep -Name 'Child' -Met { $PSBabushka.Child -eq $True } -Meet { $PSBabushka.Child = $True }
      $PSBabushka.Deps = @($ChildDep)
      $ParentDep = New-PSBabushkaDep -Name 'Parent' -RequiresWhenUnmet 'Child' -Met { $PSBabushka.Parent -eq $True } -Meet { $PSBabushka.Parent = $True }
      Invoke-PSBabushkaDep $ParentDep | Out-Null
      $PSBabushka.Child | Should Be $True
      $PSBabushka.Reset.Invoke()
    }


    It 'Skips the RequiresWhenUnmet block when the Dep is Met' {
      $ChildDep = New-PSBabushkaDep -Name 'Child' -Met { $PSBabushka.Child -eq $True } -Meet { $PSBabushka.Child = $True }
      $PSBabushka.Deps = @($ChildDep)
      $ParentDep = New-PSBabushkaDep -Name 'Parent' -RequiresWhenUnmet 'Child' -Met { $True } -Meet { }
      Invoke-PSBabushkaDep $ParentDep | Out-Null
      $PSBabushka.Child | Should Not Be $True
      $PSBabushka.Reset.Invoke()
    }
  }
}
