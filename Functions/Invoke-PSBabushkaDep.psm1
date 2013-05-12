Import-Module "$PSScriptRoot\Select-PSBabushkaDep.psm1" -Force

Function Invoke-PSBabushkaDep {
  Param (
    [Parameter(Mandatory=$True)] [Hashtable] $PSBabushkaDep
  )

  if ($PSBabushkaDep.Requires -ne $NULL) {
    $PSBabushkaDep.Requires | ForEach-Object { Select-PSBabushkaDep -Name $_ } | ForEach-Object { Invoke-PSBabushkaDep $_ }
  }

  $Name = $PSBabushkaDep.Name

  if($PSBabushkaDep.Met.Invoke()) {
    Write-Output "[$Name] - Already met!"
  } else {
    if ($PSBabushkaDep.RequiresWhenUnmet -ne $NULL) {
      $PSBabushkaDep.RequiresWhenUnmet | ForEach-Object { Select-PSBabushkaDep -Name $_ } | ForEach-Object { Invoke-PSBabushkaDep $_ }
    }

    Write-Output "[$Name] - Not met. Meeting now."
    
    Invoke-Command $PSBabushkaDep.Before
    Invoke-Command $PSBabushkaDep.Meet
    Invoke-Command $PSBabushkaDep.After

    if ($PSBabushkaDep.Met.Invoke()) {
      Write-Output "[$Name] - Now met!"
    } else {
      throw "[$Name] - Still not met!"
    }
  }
}