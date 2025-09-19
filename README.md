# <img src="https://www.rocksdanister.com/lively/assets/logo.webp" alt="" width="40" style="margin-bottom: -10px;"> &nbsp;&nbsp; **SMART RANDOM WALLPAPER** &nbsp;&nbsp; <img src="https://cdn2.steamgriddb.com/icon/700a143a1799e92c5aca1d4bf9de0b2a/32/256x256.png" alt="" width="40">

Here is a solution to add tagging support to [Lively Wallpaper](https://github.com/rocksdanister/lively) and randomly change wallpaper according to tags and day/night period.

It only needs 2 powershell scripts. If you use [Rainmeter](https://www.rainmeter.net/), import the config (*to do*) and edit the option to auto change your wallpaper every hour and or manually set the ones using some specific tags.

Read the [wiki](https://github.com/Fred-Vatin/smart-random-wallpaper/wiki) to learn how.

Once installed, you can run commands like that where `ws` stands for the `Set random Wallpaper.ps1` path.

```pwsh
sw -IncludeTags "day clock" -ExcludeTags "rain"
```

A new random wallpaper will be set corresponding to the filter.

## Screenshots
Rainmeter config with tooltip:

<img alt="image" src="https://github.com/user-attachments/assets/41dea42a-0e10-4492-a4e8-fa9f2de13b02" />

`-help` output:

<img alt="WindowsTerminal 2025-09-19 22h05 872×902 #3985" src="https://github.com/user-attachments/assets/99f3fde3-cd53-4990-85f5-af99e3c14dd2" />

---

> [!NOTE]
> I had to create this solution because the [Lively Wallpaper](https://github.com/rocksdanister/lively) author refuses to implement a built-in tags feature.
> Check [#2871](https://github.com/rocksdanister/lively/issues/2871).

---

[![BUY ME A COFFEE](https://img.shields.io/badge/BUY%20ME%20A%20COFFEE-ffffff?logo=buymeacoffee&style=for-the-badge&color=710067&logoColor=ffe071)](https://github.com/sponsors/Fred-Vatin)
