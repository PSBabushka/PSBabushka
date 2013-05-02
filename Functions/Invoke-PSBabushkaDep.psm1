Import-Module "$PSScriptRoot\Find-PSBabushkaDep.psm1" -Force

function Invoke-PSBabushkaDep {
  param(
    [Parameter(Mandatory=$True)] [Hashtable] $BabushkaDep
  )

  if ($BabushkaDep.Requires -ne $NULL) {
    $BabushkaDep.Requires | ForEach-Object { Find-PSBabushkaDep -Name $_ } | ForEach-Object { Invoke-PSBabushkaDep -BabushkaDep $_ }
  }

  $Name = $BabushkaDep.Name

  if($BabushkaDep.Met.Invoke()) {
    Write-Output "[$Name] - Already met!"
  } else {
    Write-Output "[$Name] - Not met. Meeting now."
    Invoke-Command $BabushkaDep.Before
    Invoke-Command $BabushkaDep.Meet
    Invoke-Command $BabushkaDep.After
    if ($BabushkaDep.Met.Invoke()) {
      Write-Output "[$Name] - Now met!"
    } else {
      throw "[$Name] - Still not met!"
    }
  }
}