param(
  [switch]$all,
  [switch]$day,
  [switch]$night,
  [switch]$music,
  [switch]$clock,
  [switch]$rain,
  [switch]$show,
  [switch]$help,
  [switch]$man
)

# Stop the script if an error occurs.
$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

<#*==========================================================================
*	ℹ		PARAMETERS

  Run the script with the -help parameter to know how to use it
===========================================================================#>

<#*==========================================================================
* ℹ                   DEFAULT VARIABLES
===========================================================================#>

New-Variable -Name WallpapersPath -Value (Join-Path -Path (Get-Location) -ChildPath 'wallpapers') -Option Constant
New-Variable -Name ListsPath -Value $(Join-Path -Path (Get-Location).path -ChildPath 'Lists') -Option Constant

# Write-Host "$WallpapersPath"

<#*==========================================================================
* ℹ                   FUNCTIONS
===========================================================================#>
# Display help message with specified formatting
function Show-Help {
  Write-Host "ℹ`tPARAMETERS" -ForegroundColor Magenta
  Write-Host "========================`n" -ForegroundColor Magenta
  Write-Host "-help" -ForegroundColor Magenta
  Write-Host "`tOpen this help (default)`n"
  # Write-Host "-man" -ForegroundColor Magenta
  # Write-Host "`tUse this to open wiki at `"$repo`"`n"

  Write-Host "Here are the parameters to call a list" -ForegroundColor Yellow

  Write-Host "-all" -ForegroundColor Magenta
  Write-Host "`tUse `"Wallpapers list.ps1`" to set random wallpapers`n"
  Write-Host "-day" -ForegroundColor Magenta
  Write-Host "`tUse `"Day.ps1`" to set random wallpapers`n"
  Write-Host "-night" -ForegroundColor Magenta
  Write-Host "`tUse `"Night.ps1`" to set random wallpapers`n"
  Write-Host "-music" -ForegroundColor Magenta
  Write-Host "`tUse `"Music.ps1`" to set random wallpapers`n"
  Write-Host "-clock" -ForegroundColor Magenta
  Write-Host "`tUse `"Clock.ps1`" to set random wallpapers`n"
  Write-Host "-rain" -ForegroundColor Magenta
  Write-Host "`tUse `"Rain.ps1`" to set random wallpapers`n"

  Write-Host "You can add these parameters after a list parameter" -ForegroundColor Yellow

  Write-Host "-show" -ForegroundColor Magenta
  Write-Host "`tDisplay the list in a table in the console. No wallpaper is set when used this parameter.`n"

  Write-Host "`nℹ`tDefault Paths" -ForegroundColor Magenta
  Write-Host "========================`n" -ForegroundColor Magenta
  Write-Host "Edit this script to customize those paths.`n"

  Write-Host "WallpapersPath" -ForegroundColor Magenta
  Write-Host "`tThis is where your lively wallpapers are saved" -ForegroundColor DarkGray
  Write-Host "`t$WallpapersPath`n" -ForegroundColor Cyan

  Write-Host "ListsPath" -ForegroundColor Magenta
  Write-Host "`tThis is where your lists `"*.ps1`" are saved." -ForegroundColor DarkGray
  Write-Host "`tBy default, the `"Lists`" folder in the same path as this script." -ForegroundColor DarkGray
  Write-Host "`t$ListsPath`n" -ForegroundColor Cyan
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

  Write-Host "`n===== $title =====`n" -ForegroundColor Cyan
}

function Test-CLI-Installation {
  if (-not (Get-Command Livelycu -ErrorAction SilentlyContinue)) {
    TerminateWithError -errorMessage "`"Livelycu.exe`" is not installed globally on the system. Download it and add it to the user PATH."
  }
}
<#*==========================================================================
* ℹ            GET PARAMETERS
===========================================================================#>
# Clear-Host

<#*==========================================================================
* ℹ		HANDLE HELP PARAMETER
===========================================================================#>

if ((-not $all -and -not $day -and -not $night -and -not $music -and -not $clock -and -not $rain -and -not $show -and -not $man) -or ($help)) {
  Show-Help
  exit
}

<#*==========================================================================
* ℹ		HANDLE -ALL PARAMETER
===========================================================================#>

if ($all) {
  # Import list
  $List = (Join-Path -Path $ListsPath -ChildPath 'Wallpapers list.ps1')

  if (-not (Test-Path -Path $List -PathType Leaf)) {
    WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""
    TerminateWithError -errorMessage "`"$List`" not found or not reachable."
  }

  . "$List"

  if ($show) {
    WriteTitle "HERE IS THE LIST FROM: `"$List`""
    $Wallpapers | Sort-Object -Property Title
    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""

  Test-CLI-Installation

  $randomWallpaper = $Wallpapers | Get-Random
  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "$randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "New wallapaper set: " -NoNewline
  Write-Host "`"$($randomWallpaper.Title)`"" -ForegroundColor Green -NoNewline

  exit
}

<#*==========================================================================
* ℹ		HANDLE -DAY PARAMETER
===========================================================================#>

if ($day) {
  # Import list
  $List = (Join-Path -Path $ListsPath -ChildPath 'Day.ps1')

  if (-not (Test-Path -Path $List -PathType Leaf)) {
    WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""
    TerminateWithError -errorMessage "`"$List`" not found or not reachable."
  }

  . "$List"

  if ($show) {
    WriteTitle "HERE IS THE LIST FROM: `"$List`""
    $Wallpapers | Sort-Object -Property Title
    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""

  Test-CLI-Installation

  $randomWallpaper = $Wallpapers | Get-Random
  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "$randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "New wallapaper set: " -NoNewline
  Write-Host "`"$($randomWallpaper.Title)`"" -ForegroundColor Green -NoNewline

  exit
}

<#*==========================================================================
* ℹ		HANDLE -NIGHT PARAMETER
===========================================================================#>

if ($night) {
  # Import list
  $List = (Join-Path -Path $ListsPath -ChildPath 'Night.ps1')

  if (-not (Test-Path -Path $List -PathType Leaf)) {
    WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""
    TerminateWithError -errorMessage "`"$List`" not found or not reachable."
  }

  . "$List"

  if ($show) {
    WriteTitle "HERE IS THE LIST FROM: `"$List`""
    $Wallpapers | Sort-Object -Property Title
    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""

  Test-CLI-Installation

  $randomWallpaper = $Wallpapers | Get-Random
  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "$randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "New wallapaper set: " -NoNewline
  Write-Host "`"$($randomWallpaper.Title)`"" -ForegroundColor Green -NoNewline

  exit
}

<#*==========================================================================
* ℹ		HANDLE -MUSIC PARAMETER
===========================================================================#>

if ($music) {
  # Import list
  $List = (Join-Path -Path $ListsPath -ChildPath 'Music.ps1')

  if (-not (Test-Path -Path $List -PathType Leaf)) {
    WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""
    TerminateWithError -errorMessage "`"$List`" not found or not reachable."
  }

  . "$List"

  if ($show) {
    WriteTitle "HERE IS THE LIST FROM: `"$List`""
    $Wallpapers | Sort-Object -Property Title
    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""

  Test-CLI-Installation

  $randomWallpaper = $Wallpapers | Get-Random
  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "$randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "New wallapaper set: " -NoNewline
  Write-Host "`"$($randomWallpaper.Title)`"" -ForegroundColor Green -NoNewline

  exit
}

<#*==========================================================================
* ℹ		HANDLE -CLOCK PARAMETER
===========================================================================#>

if ($clock) {
  # Import list
  $List = (Join-Path -Path $ListsPath -ChildPath 'Clock.ps1')

  if (-not (Test-Path -Path $List -PathType Leaf)) {
    WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""
    TerminateWithError -errorMessage "`"$List`" not found or not reachable."
  }

  . "$List"

  if ($show) {
    WriteTitle "HERE IS THE LIST FROM: `"$List`""
    $Wallpapers | Sort-Object -Property Title
    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""

  Test-CLI-Installation

  $randomWallpaper = $Wallpapers | Get-Random
  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "$randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "New wallapaper set: " -NoNewline
  Write-Host "`"$($randomWallpaper.Title)`"" -ForegroundColor Green -NoNewline

  exit
}

<#*==========================================================================
* ℹ		HANDLE -RAIN PARAMETER
===========================================================================#>

if ($rain) {
  # Import list
  $List = (Join-Path -Path $ListsPath -ChildPath 'Rain.ps1')

  if (-not (Test-Path -Path $List -PathType Leaf)) {
    WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""
    TerminateWithError -errorMessage "`"$List`" not found or not reachable."
  }

  . "$List"

  if ($show) {
    WriteTitle "HERE IS THE LIST FROM: `"$List`""
    $Wallpapers | Sort-Object -Property Title
    exit
  }

  WriteTitle "SET RANDOM WALLPAPERS USING LIST: `"$List`""

  Test-CLI-Installation

  $randomWallpaper = $Wallpapers | Get-Random
  $randomWallpaperPath = (Join-Path -Path $WallpapersPath -ChildPath $randomWallpaper.Folder)

  # Write-Host "$randomWallpaperPath"

  livelycu setwp --file "$randomWallpaperPath"

  Write-Host "New wallapaper set: " -NoNewline
  Write-Host "`"$($randomWallpaper.Title)`"" -ForegroundColor Green -NoNewline

  exit
}
