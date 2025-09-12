$currentDate = Get-Date
$currentHour = $currentDate.Hour
$currentMinute = $currentDate.Minute
$currentTime = $currentHour + ($currentMinute / 60.0) # Convert to decimal time

# Determine the season according to the month
$month = $currentDate.Month
switch ($month) {
  { $_ -in 3, 4, 5 } { $season = "Spring"; $sunrise = 6.5; $sunset = 20.0 }
  { $_ -in 6, 7, 8 } { $season = "Summer"; $sunrise = 5.5; $sunset = 21.0 }
  { $_ -in 9, 10, 11 } { $season = "Autumn"; $sunrise = 7.0; $sunset = 19.0 }
  default { $season = "Winter"; $sunrise = 8.0; $sunset = 17.0 }
}

# Check if the current time is in the day or night
if ($currentTime -ge $sunrise -and $currentTime -lt $sunset) {
  $result = "day"
}
else {
  $result = "night"
}

# Output result
Write-Output "Season : $season"
Write-Output "Current Time : $($currentDate.ToString('HH:mm'))"
Write-Output "Sunrise : $($sunrise.ToString('0.00'))"
Write-Output "Sunset : $($sunset.ToString('0.00'))"
Write-Output "Result : $result"
