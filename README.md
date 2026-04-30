## Miscellaneous settings / configurations for my workstation

- Hammerspoon
- Visual Studio Code
- iTerm2
- screen
- ShadowSocksX

## How to use Caps key latency 0

- Download and move the correct folder
- `launchctl load ~/Library/LaunchAgents/com.user.capslockdelay.plist`
- Undo: 
```
launchctl unload ~/Library/LaunchAgents/com.user.capslockdelay.plist
rm ~/Library/LaunchAgents/com.user.capslockdelay.plist
```

ref: https://blog.andylain.com/2026/01/mac-mac-caps-lock.html
