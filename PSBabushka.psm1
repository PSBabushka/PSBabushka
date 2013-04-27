function Define-BabushkaDep {
  param(
    [Parameter(Mandatory=$True)]  [String]      $Name,
    [Parameter(Mandatory=$False)] [String[]]    $Requires,
    [Parameter(Mandatory=$True)]  [ScriptBlock] $Met,
    [Parameter(Mandatory=$True)]  [ScriptBlock] $Meet,
    [Parameter(Mandatory=$False)] [ScriptBlock] $Before = {},
    [Parameter(Mandatory=$False)] [ScriptBlock] $After  = {}
  )

  $This = @{}
  $This.Name = $Name
  $This.Requires = $Requires
  $This.Met = $Met
  $This.Meet = $Meet
  $This.Before = $Before
  $This.After = $After

  return $This
}

function Invoke-BabushkaDep {
  param(
    [Parameter(Mandatory=$True)] [Hashtable] $BabushkaDep
  )

  if ($BabushkaDep.Requires -ne $NULL) {
    $BabushkaDep.Requires | ForEach-Object { Find-BabushkaDep -BabushkaDepName $_ } | ForEach-Object { Invoke-BabushkaDep -BabushkaDep $_ }
  }

  $Name = $BabushkaDep.Name

  if($BabushkaDep.Met.Invoke()) {
    Write-Host "[$Name] - Already met!"
  } else {
    Write-Host "[$Name] - Not met. Meeting now."
    . $BabushkaDep.Before
    . $BabushkaDep.Meet
    . $BabushkaDep.After
    if ($BabushkaDep.Met.Invoke()) {
      Write-Host "[$Name] - Now met!"
    } else {
      throw "[$Name] - Still not met!"
    }
  }
}

function Find-BabushkaDep {
  param(
    [Parameter(Mandatory=$True)] [String] $BabushkaDepName
  )

  $Babushka.Deps | Where-Object { $_.Name -eq $BabushkaDepName }
}

function Invoke-Babushka {
  param(
    [Parameter(Mandatory=$True)] [String] $Name
  )

  $Babushka = @{}
  $Babushka.Deps = Get-ChildItem -Path (Get-Location) -Include "*.dep.ps1" -Recurse | ForEach-Object { $_.PSPath } | ForEach-Object { Invoke-Expression $_ }

  $Babushka.Dep = Find-BabushkaDep -BabushkaDepName $Name

  Invoke-BabushkaDep -BabushkaDep $Babushka.Dep
}
