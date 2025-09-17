# <img src="https://www.rocksdanister.com/lively/assets/logo.webp" alt="" width="40" style="margin-bottom: -10px;"> &nbsp;&nbsp; **SMART RANDOM WALLPAPER** &nbsp;&nbsp; <img src="https://cdn2.steamgriddb.com/icon/700a143a1799e92c5aca1d4bf9de0b2a/32/256x256.png" alt="" width="40">

Here is a solution to add tagging support to [Lively Wallpaper](https://github.com/rocksdanister/lively) and randomly change wallpaper according to tags and day/night period.

It only needs 2 powershell scripts. If you use [Rainmeter](https://www.rainmeter.net/), import the config (*to do*) and edit the option to auto change your wallpaper every hour and or manually set the ones using some specific tags.

Read the [wiki](https://github.com/Fred-Vatin/smart-random-wallpaper/wiki) to learn how.

Once installed, you can run commands like that where `ws` stands for the `Set random Wallpaper.ps1` path.

```pwsh
ws -IncludeTags "day clock" -ExcludeTags "rain"
```

A new random wallpaper will be set corresponding to the filter.

---

> [!NOTE]
> I had to create this solution because the [Lively Wallpaper](https://github.com/rocksdanister/lively) author refuses to implement a built-in tags feature.
> Check [#2871](https://github.com/rocksdanister/lively/issues/2871).
