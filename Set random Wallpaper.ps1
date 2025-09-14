param(
  [switch]$UpdateList,
  [switch]$SetWallpapersPath,
  [switch]$ForgetWallpapersPath,
  [switch]$All,
  [string]$IncludeTags,
  [string]$ExcludeTags,
  [switch]$Show,
  [switch]$NoTags,
  [switch]$Help,
  [switch]$Man
)

# Stop the script if an error occurs.
$ErrorActionPreference = 'Stop'


<#*==========================================================================
*	ℹ		PARAMETERS

Run the script with the -help parameter to know how to use it
===========================================================================#>

<#*==========================================================================
* ℹ                   DEFAULT VARIABLES
===========================================================================#>

Set-Location $PSScriptRoot
$WorkingDir = Get-Location

New-Variable -Name ListFile -Value "Wallpapers list.ps1" -Option Constant
New-Variable -Name ListPath -Value $(Join-Path -Path $WorkingDir -ChildPath $ListFile) -Option Constant
New-Variable -Name EnvPathName -Value "WallpapersPath" -Option Constant
New-Variable -Name EnvPrevName -Value "WallpaperPrevious" -Option Constant
New-Variable -Name WallpapersFolder -Value "wallpapers" -Option Constant

$WallpapersPath = [System.Environment]::GetEnvironmentVariable($EnvPathName, "User")

if (-not ($WallpapersPath)) {
  $WallpapersPath = (Join-Path -Path $WorkingDir -ChildPath $WallpapersFolder)
}

# Write-Output "WallpapersPath: $WallpapersPath"
# Write-Output "ListPath: $ListPath"

<#*==========================================================================
* ℹ                   FUNCTIONS
===========================================================================#>
# Display help message with specified formatting
function Show-Help {
  Write-Host "`nℹ`tPARAMETERS" -ForegroundColor Magenta
  Write-Host "========================`n" -ForegroundColor Magenta
  Write-Host "-Help" -ForegroundColor Magenta
  Write-Host "`tOpen this help (default)`n"
  # Write-Host "-Man" -ForegroundColor Magenta
  # Write-Host "`tUse this to open wiki at `"$repo`"`n"

  Write-Host "-UpdateList" -ForegroundColor Magenta
  Write-Host "`tCreate or update the wallpapers list and save it to: "
  Write-Host "`t$ListPath`n" -ForegroundColor Cyan
  Write-Host "`tThis function is automatically called if the list is not found when using other parameters below." -ForegroundColor DarkGray
  Write-Host "`tUse it to force an update of the list.`n" -ForegroundColor DarkGray

  Write-Host "Here are the parameters to set a random wallpaper using tags." -ForegroundColor Yellow
  Write-Host "You can use both -IncludeTags and -ExcludeTags at the same time." -ForegroundColor Yellow
  Write-Host "But -IncludeTags must come first." -ForegroundColor Yellow

  Write-Host "-All" -ForegroundColor Magenta
  Write-Host "`tIt will set a wallpaper using any wallpapers in `"$ListFile`"`n"
  Write-Host "-IncludeTags <String>" -ForegroundColor Magenta
  Write-Host "`tPass one or serveral tags as word like `"day clock`""
  Write-Host "`tOnly wallpapers having those tags in description will be used`n"
  Write-Host "-ExcludeTags <String>" -ForegroundColor Magenta
  Write-Host "`tPass one or several tags as word like `"day clock`""
  Write-Host "`tWallpapers having those tags in description will NOT be used even if they are in -IncludeTags`n"

  Write-Host "You can add these parameters after -All or -IncludeTags or -ExcludeTags" -ForegroundColor Yellow

  Write-Host "-Show" -ForegroundColor Magenta
  Write-Host "`tDisplay the list returned by tags filter in a table in the console."
  Write-Host "`tNo wallpaper is set when using this parameter.`n"

  Write-Host "`tSpecial: use " -ForegroundColor Red -NoNewline
  Write-Host "-All -Show -NoTags" -ForegroundColor Yellow
  Write-Host "`tto display the list of wallpapers that don’t have tags set."
  Write-Host "`tNo wallpaper is set when using these parameters.`n"

  Write-Host "`nℹ`tDefault Paths" -ForegroundColor Magenta
  Write-Host "========================`n" -ForegroundColor Magenta

  Write-Host "-SetWallpapersPath" -ForegroundColor Magenta
  Write-Host "`tUse this parameter to run an assistant to help you to define"
  Write-Host "`tyour lively wallpapers path in your user environment variable."
  Write-Host "`tBy default, this script use the `"$WallpapersFolder`" directory in the same path as this script."
  Write-Host "`tCurrent value: " -NoNewline
  Write-Host "`t$WallpapersPath`n" -ForegroundColor Cyan

  Write-Host "-ForgetWallpapersPath" -ForegroundColor Magenta
  Write-Host "`tUse this parameter to delete the " -NoNewline
  Write-Host "$EnvPathName " -ForegroundColor Cyan -NoNewline
  Write-Host "environment variable."
  Write-Host "`tThen this script will use the `"$WallpapersFolder`" directory in the same path as this script.`n"

  Write-Host "ListPath" -ForegroundColor Yellow
  Write-Host "`tThis is where the `"$ListFile`" is saved." -ForegroundColor DarkGray
  Write-Host "`tBy default in the same path as this script." -ForegroundColor DarkGray
  Write-Host "`tCurrent value: " -NoNewline
  Write-Host "`t$ListPath`n" -ForegroundColor Cyan
  Write-Host "`tEdit this script to customize this path if you really need it."
}

function TerminateWithError {
  param(
    [string]$errorMessage = "Error happened.`nEXIT",
    [System.Exception]$exception
  )

  [console]::beep(1000, 100)
  [console]::beep(1000, 100)
  [console]::beep(1000, 100)
  [console]::beep(1000, 1000)

  if ($exception) {
    $line = $_.InvocationInfo.ScriptLineNumber

    if ($line) {
      Write-Host "`n$errorMessage :`n`t$($exception.Message)`n`tLine: $line`nEXIT" -ForegroundColor Red
    }
    else {
      Write-Host "`n$errorMessage :`n$($exception.Message)`nEXIT" -ForegroundColor Red
    }
  }
  else {
    Write-Host "ERROR`n" -ForegroundColor Red
    Write-Host "   $errorMessage`n`nEXIT" -ForegroundColor Red
  }

  exit 1
}

function WriteTitle {
  param(
    [Parameter(Mandatory = $true)]
    [string]$title
  )

  Write-Host "`n===== $title =====`n" -ForegroundColor Magenta
}

function Test-CLI-Installation {
  if (-not (Get-Command Livelycu -ErrorAction SilentlyContinue)) {
    TerminateWithError -errorMessage "`"Livelycu.exe`" is not installed globally on the system. Download it and add it to the user PATH."
  }
}

function SetPath {
  Write-Host "`nDo NOT need to use double quotes if your path contains spaces." -ForegroundColor Yellow

  do {

    $path = Read-Host -Prompt 'Please enter a path (or press Enter to cancel)'

    if (-not $path) {
      Write-Host 'Operation cancelled.' -ForegroundColor Yellow
      return $null
    }

    if (-not (Test-Path -Path $path -PathType Container)) {
      Write-Host "`nError : the path " -ForegroundColor Red
      Write-Host "$path" -ForegroundColor cyan
      Write-Host "doesn’t exist. Try again or press Ctrl+C to cancel." -ForegroundColor Red
      $isValidPath = $false
    }
    else {
      $isValidPath = $true
    }

  } until ($isValidPath)

  try {
    $null = New-ItemProperty -Path "HKCU:\Environment" -Name $EnvPathName -Value $path -PropertyType String -Force
  }
  catch {
    TerminateWithError -errorMessage "The path failed to be registered as a user environment variable."
  }

  $WallpapersPath = [System.Environment]::GetEnvironmentVariable($EnvPathName, "User")

  # Clear-Host
  Write-Host "`nWallpapers path: " -ForegroundColor Green -NoNewline
  Write-Host "$WallpapersPath" -ForegroundColor Cyan
  Write-Host "saved in the the " -ForegroundColor Green -NoNewline
  Write-Host "$EnvPathName " -ForegroundColor Cyan -NoNewline
  Write-Host "environment variable." -ForegroundColor Green
  Write-Host "`nThis will take effect in a new pwsh session though." -ForegroundColor Yellow


  # Retourne le chemin.
  return $WallpapersPath
}

function UpdateList {
  $Output = '$Wallpapers = @()' + [Environment]::NewLine

  if (Test-Path -Path $WallpapersPath -PathType Container) {
    # Browse each Wallpapers child folder (non-recursively)
    Get-ChildItem -Path $WallpapersPath -Directory | ForEach-Object {
      $CurrentFolder = $_.Name
      # Path to the LivelyInfo.json file in the current folder
      $jsonFile = Join-Path -Path $_.FullName -ChildPath 'LivelyInfo.json'

      if (Test-Path -Path $jsonFile -PathType Leaf) {
        try {
          # Read JSON file
          $jsonContent = Get-Content -Path $jsonFile -Raw | ConvertFrom-Json
          # Get wallpaper title
          $Title = $jsonContent.Title

          # Get wallpaper tags
          $Tags = $jsonContent.Desc
          if ($Tags) {
            $Tags = ($Tags | Select-String -Pattern '#\w+' -AllMatches).Matches.Value -join ' '
            $Tags = $Tags.Replace("#", "")
          }

          if ($Title) {
            # If title is like "The 80's", replace with "The 80''s" to avoid parsing error later
            $Title = $Title.Replace("'", "''")
            $Title = $Title.Replace('"', "''")

            # Add formated text to $Output
            $Output += "`$Wallpapers += New-Object -TypeName psobject -Property @{" + [Environment]::NewLine
            $Output += "    'Folder' = '$CurrentFolder'" + [Environment]::NewLine
            $Output += "    'Title' = '$Title'" + [Environment]::NewLine

            if ($Tags) {
              $Output += "    'Tags' = '$Tags'" + [Environment]::NewLine
            }

            $Output += "}" + [Environment]::NewLine
          }
        }
        catch {
          Write-Warning "Error reading file  `"LivelyInfo.json`" in $CurrentFolder : $_"
        }
      }
    }
  }
  else {
    Write-Warning "`"$WallpapersFolder`" folder doesn’t exist in:"
    Write-Host "$WallpapersPath" -ForegroundColor Cyan
    exit
  }

  try {
    Write-Output ""
    $Output | Out-File -FilePath $ListPath -Encoding UTF8 -ErrorAction Stop
    Write-Host "`"$ListFile`" sucessfully updated in:" -ForegroundColor Green
    Write-Host "$ListPath`n" -ForegroundColor Cyan
  }
  catch {
    TerminateWithError -errorMessage "Failed to create `"$ListPath`""
  }
}

function Pause {
  Read-Host "Paused. Press Enter to continue..."
}

$ImportList = {
  if (-not (Test-Path -Path $ListPath -PathType Leaf)) {
    Write-Host "`nAuto update list because not found in:" -ForegroundColor Yellow
    Write-Host "$ListPath`n" -ForegroundColor Cyan
    UpdateList
  }

  . "$ListPath"

  if (-not $Wallpapers) {
    TerminateWithError -errorMessage "No valid wallpapers found to filter in: `"$ListPath`". Try to open a new pwsh session and use the -UpdateList parameter."
  }
}

$SetRandom = {
  param($List = $Wallpapers)

  Test-CLI-Installation

  $WallpaperPrevious = [System.Environment]::GetEnvironmentVariable($EnvPrevName, "User")

  do {
    $randomWallpaper = $List | Get-Random

    if ($randomWallpaper.Folder -eq $WallpaperPrevious) {
      $isNew = $false
    }
    else {
      $isNew = $true
    }

  } until (
    $isNew
  )

  try {
    $null = New-ItemProperty -Path "HKCU:\Environment" -Name $EnvPrevName -Value $randomWallpaper.Folder -PropertyType String -Force
  }
  catch {
    TerminateWithError -errorMessage "`"$randomWallpaper.Folder`" failed to be registered as the user environment variable `"$EnvPrevName`""
  }

  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "`$randomWallpaperPath: $randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "`nNew wallapaper set: " -NoNewline
  Write-Host "$($randomWallpaper.Title)" -ForegroundColor Green -NoNewline
  Write-Host "`ttagged: " -NoNewline
  Write-Host "$($randomWallpaper.Tags)" -ForegroundColor Green -NoNewline
}

$Exclude = {
  param($List = $Wallpapers)

  $RequiredTags = $ExcludeTags -split '\s+'

  $FilteredList = $Wallpapers | Where-Object {
    $tags = $_.Tags -split '\s+'
    ($RequiredTags | Where-Object { $tags -contains $_ }).Count -eq 0
  }
}

$TagsListIn = {
  if ($IncludeTags) {
    Write-Host "Including tags: " -NoNewline
    Write-Host "$IncludeTags" -ForegroundColor Green
  }
}

$TagsListOut = {
  if ($ExcludeTags) {
    Write-Host "Excluding tags: " -NoNewline
    Write-Host "$ExcludeTags" -ForegroundColor Red
  }
}

<#*==========================================================================
* ℹ		HANDLE HELP PARAMETER
===========================================================================#>

if ((-not $UpdateList -and -not $All -and -not $SetWallpapersPath -and -not $ForgetWallpapersPath -and -not $IncludeTags -and -not $ExcludeTags -and -not $NoTags -and -not $Show -and -not $Help -and -not $Man) -or ($Help)) {
  Show-Help
  exit
}

<#*==========================================================================
* ℹ		HANDLE -UpdateList PARAMETER
===========================================================================#>
if ($UpdateList) {
  UpdateList
  exit
}

<#*==========================================================================
* ℹ		HANDLE -SetWallpapersPath PARAMETER
===========================================================================#>
if ($SetWallpapersPath) {
  $Path = SetPath
  exit
}

<#*==========================================================================
* ℹ		HANDLE -ForgetWallpapersPath PARAMETER
===========================================================================#>
if ($ForgetWallpapersPath) {
  try {

    if ($null -ne [System.Environment]::GetEnvironmentVariable($EnvPathName, "User")) {
      Remove-ItemProperty -Path "HKCU:\Environment" -Name $EnvPathName
      Write-Host "`nThe environment variable named " -ForegroundColor Green -NoNewline
      Write-Host "$EnvPathName " -ForegroundColor Cyan -NoNewline
      Write-Host "has been deleted." -ForegroundColor Green
      Write-Host "`nThis will take effect in a new pwsh session though." -ForegroundColor Yellow
    }
    else {
      Write-Host "`nThe environment variable named " -ForegroundColor Yellow -NoNewline
      Write-Host "$EnvPathName " -ForegroundColor Cyan -NoNewline
      Write-Host "was not found." -ForegroundColor Yellow
      Write-Host "If you expected otherwise, open a new pwsh session and run the command " -ForegroundColor Yellow
      Write-Host "[System.Environment]::GetEnvironmentVariable(`"$EnvPathName`", `"User`")" -ForegroundColor Magenta
      Write-Host "to be sure this variable doesn’t exist or open an environment manager like rapidEE." -ForegroundColor Yellow
    }

  }
  catch {
    TerminateWithError -errorMessage "The environment variable `"$EnvPathName`" failed to be deleted."
  }

  exit
}

<#*==========================================================================
* ℹ		HANDLE -All PARAMETER
===========================================================================#>

if ($All) {
  . $ImportList

  if ($Show -and -not $NoTags) {
    WriteTitle "HERE IS THE COMPLETE LIST : $($Wallpapers.Count)"
    Write-Host "$ListPath`n" -ForegroundColor Cyan

    $Wallpapers |
    Select-Object -Property Title, Tags, Folder |
    Sort-Object -Property Title
    exit
  }

  if ($Show -and $NoTags) {
    $FilteredList = $Wallpapers | Where-Object { -not $_.Tags -or $_.Tags.Count -eq 0 } |
    Select-Object -Property Title, Folder |
    Sort-Object -Property Title

    WriteTitle "LIST WITH FILTER: NO TAGS : $($FilteredList.Count)"
    Write-Host "$ListPath`n" -ForegroundColor Cyan
    $FilteredList | Select-Object Title, Tags, Folder | Sort-Object Title

    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS FROM COMPLETE LIST"
  Write-Host "$ListPath`n" -ForegroundColor Cyan

  . $SetRandom

  exit
}

<#*==========================================================================
* ℹ		HANDLE -IncludeTags PARAMETER
===========================================================================#>

if ($IncludeTags) {
  . $ImportList

  $RequiredTags = $IncludeTags -split '\s+'

  $FilteredList = $Wallpapers | Where-Object {
    $tags = $_.Tags -split '\s+'
    # Put the pipeline result in parentheses before comparing
    (( $RequiredTags |
      ForEach-Object { $tags -contains $_ } |
      Where-Object { -not $_ } |
      Measure-Object |
      Select-Object -ExpandProperty Count) -eq 0)
  }

  if ($ExcludeTags) {
    . $Exclude -List $FilteredList
  }

  if ($Show) {
    WriteTitle "FILTERED LIST : $($FilteredList.Count)"
    Write-Host "$ListPath`n" -ForegroundColor Cyan

    & $TagsListIn
    & $TagsListOut

    $FilteredList | Select-Object Title, Tags, Folder | Sort-Object Title
  }
  else {
    WriteTitle "SET RANDOM WALLPAPERS FILTERED FROM LIST"
    Write-Host "$ListPath`n" -ForegroundColor Cyan

    & $TagsListIn
    & $TagsListOut

    . $SetRandom -List $FilteredList
  }

  exit
}

<#*==========================================================================
* ℹ		HANDLE -ExcludeTags PARAMETER
===========================================================================#>

if ($ExcludeTags) {
  . $ImportList

  . $Exclude

  if ($Show) {
    WriteTitle "FILTERED LIST : $($FilteredList.Count)"
    Write-Host "$ListPath`n" -ForegroundColor Cyan

    & $TagsListIn
    & $TagsListOut

    $FilteredList | Select-Object Title, Tags, Folder | Sort-Object Title
  }
  else {
    WriteTitle "SET RANDOM WALLPAPERS FILTERED FROM LIST"
    Write-Host "$ListPath`n" -ForegroundColor Cyan

    & $TagsListIn
    & $TagsListOut

    . $SetRandom -List $FilteredList
  }

  exit
}
