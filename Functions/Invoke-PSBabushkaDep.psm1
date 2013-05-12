Import-Module "$PSScriptRoot\Select-PSBabushkaDep.psm1" -Force

function Invoke-PSBabushkaDep {
  param(
    [Parameter(Mandatory=$True)] [Hashtable] $BabushkaDep
  )

  if ($BabushkaDep.Requires -ne $NULL) {
    $BabushkaDep.Requires | ForEach-Object { Select-PSBabushkaDep -Name $_ } | ForEach-Object { Invoke-PSBabushkaDep -BabushkaDep $_ }
  }

  $Name = $BabushkaDep.Name

  if($BabushkaDep.Met.Invoke()) {
    Write-Output "[$Name] - Already met!"
  } else {
    if ($BabushkaDep.RequiresWhenUnmet -ne $NULL) {
      $BabushkaDep.RequiresWhenUnmet | ForEach-Object { Select-PSBabushkaDep -Name $_ } | ForEach-Object { Invoke-PSBabushkaDep -BabushkaDep $_ }
    }
    
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