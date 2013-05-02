# PSBabushka

A configuration management framework built in PowerShell to help automate Windows environments.

## Current State

Throwing together PowerShell scripts to automate boring, repetitive tasks has become second-nature for any sane person who finds themselves using Windows.

Unfortunately, this can lead to a proliferation of scripts which lack purpose, readability and elegance, while not meeting the standard of quality most people would otherwise hold their code to.

Even if we want to spend a little more time crafting the perfect script to perform the overly-tedious task in question, without explicitly referencing and satisfying the implicit pre-requisites we are tightly coupling the script's implementation to the current environment.

## Enter PSBabushka

PSBabushka allows Windows users to write small, readable and testable configuration management scripts to help automate their environments.

By following a few simple patterns when writing PSBabushka scripts, known as Deps, you will end up with a battle-tested library of scripts which can be used to confidently manage anything you could otherwise achieve with a less-elegant PowerShell script.

## Overview

The basic idea of PSBabushka is to break a script down into two blocks. The first, called Met, is used to determine when the desired outcome has been achieved. The second, called Meet, is used to perform the desired piece of automation.

This allows PSBabushka to only run the Dep's Meet block if its Met block does not return something truthy (ie. `$False`, `$Null` or an empty string). It also means that once a Dep's Meet block has run, its Met block can be run once again to validate the success of the Meet block.

These two parts form a feedback loop, which is where the real power of PSBabushka comes from. This core feature allows many interesting things, including the ability to write idempotent scripts that can be run many times in many different contexts while being able to safely assume the result will be identical each and every time.

## Example

PSGet is a popular tool for streamlining the installation of PowerShell modules from remote sources. Its own installer can be run over the top of an existing copy, but it will still hit the network to download the latest copy of the PsGet scripts when it could simply do nothing and have the same effect.

With PSBabushka, we can wrap this in a Dep which will install PsGet if it is not already available, but will know if it has been installed and instead do nothing.

`PsGet-Installed.ps1`
```
Define-PSBabushkaDep `
  -Name 'PsGet-Installed' `
  -Met { Get-Command -Module 'PsGet' } `
  -Meet { (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | Invoke-Expression PoshGit }
```

Now all we need to do to install PsGet via our PSBabushka Dep is run the following:

```
PS C:\> Invoke-PSBabushka 'PsGet-Installed'

[PsGet-Installed] Not met. Meeting now.
[PsGet-Installed] Now met!
```

There you go, looks like everything worked. Just to be sure, let's run it again.

```
PS C:\> Invoke-PSBabushka 'PsGet-Installed'

[PsGet-Installed] Already met!
```

## Declarative over Imperative

In this wonderful world of environment automation, scripts are often a little more complex than this, and likely require a few more steps to truly achieve the desired effect. Unfortunately, it's dangerous to assume what state the environment is in, in order to know which requirements for the script have been satisfied but which have not.

This scenario often leads to "defensive scripting" where every assumption is validated before trying to invoke or execute each step in the script. While this approach makes a script more resilient, it is often achieved through imperative scripting, which is more cumbersome to read, understand and debug.

The alternative to imperative scripting in declarative scripting, in where requirements and assumptions are declared, leaving the runtime to decide how to achieve the stated goal. In PSBabushka, this pattern allows a Dep to declare which other Deps it requires, leaving it up to PSBabushka to satisfy those requirements at runtime, rather than taking on an added responsibility of enforcing that the requirements be met explicitly.

## Deps Require Deps

Going back to our example above, installing PsGet is often only a means to an end. While it was useful to automate the installer so we don't have to look it up each time, we can take the example further to demonstrate how to install a PowerShell module via PsGet. In this example our earlier Dep, named `PsGet-Installed`, is referenced by our new Dep which aims to install the Posh-Git module.

`PoshGit-Installed.ps1`
```
Define-PSBabushkaDep `
  -Name 'PoshGit-Installed' `
  -Requires 'PsGet-Installed' `
  -Met { Get-Command -Module 'Posh-Git' } `
  -Meet { Install-Module 'Posh-Git' }
```

Now when running PSBabushka and pointing to our new Dep, we see the following:

```
PS C:\> Invoke-PSBabushka 'PoshGit-Installed'

[PsGet-Installed] Already met!

[PoshGit-Installed] Not met. Meeting now.
[PoshGit-Installed] Now met!
```

By declaring that installing Posh-Git requires that PsGet is already installed (because the command we need to run to install Posh-Git is PsGet's `Install-Module`) we can allow PSBabushka to determine how best to tie everything together.

## Credit

[Ben Hoskings](http://benhoskin.gs/) deserves a huge amount of credit for creating the original [Babushka](http://babushka.me/), which I have used and loved for a long while now. Unfortunately not everyone can use Ruby, which led me to implement the framework in PowerShell.
