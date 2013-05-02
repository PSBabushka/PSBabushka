Set-Variable -Name PSBabushka -Value @{} -Scope 'Global'
$PSBabushka.Reset = { Import-Module $PSScriptRoot -Force -DisableNameChecking }