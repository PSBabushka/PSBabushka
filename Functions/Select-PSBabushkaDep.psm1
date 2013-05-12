Function Select-PSBabushkaDep {
  Param (
    [Parameter(Mandatory=$True)] [String] $Name
  )

  $PSBabushka.Deps | Where-Object { $_.Name -eq $Name }
}
