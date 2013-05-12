$Root = Resolve-Path -Path "$PSScriptRoot\.."

Import-Module (Join-Path -Path $Root -ChildPath 'PSBabushka') -Force
Import-Module (Join-Path -Path $Root -ChildPath 'Functions\Import-PSBabushkaDeps.psm1') -Force

Describe 'Import-PSBabushkaDeps' {
  It 'Imports PSBabushkaDeps From a Dir into a Ref' {
    Setup -File -Path 'PSBabushkaDeps\Test.Dep.ps1' -Content "Write-Output 'Bar'"

    $Test = @{}
    
    Import-PSBabushkaDeps -From $TestDrive -Into ([Ref] $Test)

    $Test.Deps | Should Be 'Bar'
  }
}
