function Define-PSBabushkaDep {
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
  $This.Path = $MyInvocation.PSCommandPath

  return $This
}