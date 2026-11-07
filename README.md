# pls automations

59 ready-made automations for [pls](https://github.com/alexmx/pls): Mac settings, sound and music, the network,
files and images, the clipboard, apps, developer chores and everyday reminders. Ask for them in plain words —
`pls "it's too bright"`, `pls "free up port 3000"`, `pls "shrink my screenshots"` — or run them by name.

Each one is a short shell script or AppleScript you can read before you trust it. Each was tested against the model
pls uses, so its description, examples and params lead requests to it and fill its values correctly.

## Install

```sh
pls collection add alexmx/pls-automations                    # all of them
pls collection add alexmx/pls-automations --only wifi,mute   # just some
pls collection update                                        # later: get changes; lists every automation that changed
pls collection disable focus                                 # turn one off; it stays off across updates
```

Your own automations always win: if you have one with the same id, this collection's is still there as
`alexmx/pls-automations/<id>`. Installing runs nothing; an update changes scripts that will run, so read what it lists.

## Requirements

- macOS 26 and [pls](https://github.com/alexmx/pls)
- A few need more, listed in the Notes column below: Homebrew for `brew-upgrade`, Xcode for `simulators`, your
  password for the two that use `sudo`, or a permission macOS asks for the first time (Accessibility for
  `lock-screen`, Screen Recording for `screen-recording`, and "control this app" prompts for the AppleScript ones).

### Shortcuts for `focus` and `bluetooth`

macOS has no command for Focus modes or Bluetooth, so these two run a Shortcut you build once in the Shortcuts app.
Until you do, they say so and stop.

- **Set Bluetooth**: an **If** on Shortcut Input *is* `on` with **Set Bluetooth: On**, and **Otherwise**
  **Set Bluetooth: Off**. (`bluetooth` reads the current state itself, so the Shortcut only ever gets `on` or `off`.)
- **Set Focus**: **Get Dictionary from Input**, then **Get Dictionary Value** for `mode` and for `minutes`. For each
  Focus you use, an **If** on `mode` (e.g. *is* `work`) with **Set Focus: Work, On** — until **Adjust Date** (Current
  Date + `minutes` minutes) if you want the time limit. For `off`, **Set Focus** actions that turn your Focus modes
  off. The choices are `do-not-disturb`, `work`, `personal`, `sleep`, `morning` and `reduce-interruptions`; trim the
  `@pls.param mode` line in `automations/focus.sh` to the ones you have.

## Automations

<!-- automations:start -->

### System

| Automation | What it does | Notes |
|---|---|---|
| [`dark-mode`](automations/dark-mode.applescript) | Switch the system appearance between dark and light |  |
| [`keep-awake`](automations/keep-awake.sh) | Keep the Mac and its display awake for a number of minutes, or let it sleep again | runs in the background |
| [`sleep-display`](automations/sleep-display.sh) | Turn the display off now, leaving everything running |  |
| [`lock-screen`](automations/lock-screen.applescript) | Lock the Mac now, so it needs your password to get back in | needs Accessibility permission |
| [`set-wallpaper`](automations/set-wallpaper.sh) | Set the desktop picture to an image file |  |
| [`hidden-files`](automations/hidden-files.sh) | Show or hide hidden files (dotfiles) in Finder |  |
| [`dock-autohide`](automations/dock-autohide.sh) | Turn Dock auto-hiding on or off |  |
| [`screenshot-folder`](automations/screenshot-folder.sh) | Change the folder new screenshots are saved in, or show where they go |  |
| [`screenshot-format`](automations/screenshot-format.sh) | Change the setting for which file format future screenshots are saved in (existing files stay as they are) |  |
| [`focus`](automations/focus.sh) | Turn a macOS Focus mode on or off, optionally for a number of minutes | needs the “Set Focus” Shortcut |
| [`bluetooth`](automations/bluetooth.sh) | Turn Bluetooth on or off, or restart it | needs the “Set Bluetooth” Shortcut |
| [`low-power-mode`](automations/low-power-mode.sh) | Turn Low Power Mode on or off to save battery | needs your password (sudo) |

### Sound and music

| Automation | What it does | Notes |
|---|---|---|
| [`set-volume`](automations/set-volume.applescript) | Set the sound output volume to a level from 0 to 100 |  |
| [`mute`](automations/mute.applescript) | Mute or unmute the sound, keeping the volume level |  |
| [`apple-music-control`](automations/apple-music-control.applescript) | Play, pause, skip or go back a track in the Music app |  |
| [`apple-music-playlist`](automations/apple-music-playlist.sh) | Play a playlist from the Music app by name |  |
| [`apple-music-now-playing`](automations/apple-music-now-playing.applescript) | Show what's playing in the Music app |  |
| [`say`](automations/say.sh) | Speak or announce text out loud with the Mac's text-to-speech voice |  |

### Network

| Automation | What it does | Notes |
|---|---|---|
| [`wifi`](automations/wifi.sh) | Turn Wi-Fi on or off, or restart it |  |
| [`flush-dns`](automations/flush-dns.sh) | Clear the DNS cache, for when websites won't load or still point to their old address | needs your password (sudo) |
| [`speed-test`](automations/speed-test.sh) | Measure the internet connection's download and upload speed |  |
| [`my-ip`](automations/my-ip.sh) | Show this Mac's IP address on the local network and on the internet |  |
| [`kill-port`](automations/kill-port.sh) | Kill whatever process is listening on a TCP port | asks first; shows what it would do |
| [`ports-in-use`](automations/ports-in-use.sh) | List which apps are listening on which TCP ports, without stopping anything |  |
| [`ping-host`](automations/ping-host.sh) | Check whether a host or website is reachable and how fast it answers |  |

### Files

| Automation | What it does | Notes |
|---|---|---|
| [`clean-downloads`](automations/clean-downloads.sh) | Trash old files in Downloads that haven't changed for a number of days, to free up space | asks first; shows what it would do |
| [`image-compress`](automations/image-compress) | Compress images in a folder to a lower quality, reducing file size but keeping their dimensions |  |
| [`image-resize`](automations/image-resize.sh) | Resize images in a folder to smaller pixel dimensions (width and height) |  |
| [`image-convert`](automations/image-convert.sh) | Convert images in a folder to another file format |  |
| [`video-convert`](automations/video-convert.sh) | Shrink or convert a video file (.mov, .mp4) to a smaller size or another format, keeping the original |  |
| [`zip`](automations/zip.sh) | Zip a file or folder into a .zip archive next to it |  |
| [`unzip`](automations/unzip.sh) | Extract a .zip archive next to it |  |
| [`large-files`](automations/large-files.sh) | List the biggest files in a folder and its subfolders, to see what's taking up space |  |
| [`organize-folder`](automations/organize-folder.sh) | Sort the files in a folder into subfolders by type: Images, Documents, Videos, Audio, Archives, Installers, Other | asks first; shows what it would do |
| [`empty-trash`](automations/empty-trash.applescript) | Empty the Trash, permanently deleting what's in it | asks first; shows what it would do |
| [`eject-disks`](automations/eject-disks.applescript) | Safely eject all external drives and disk images |  |

### Clipboard and text

| Automation | What it does | Notes |
|---|---|---|
| [`plain-clipboard`](automations/plain-clipboard.sh) | Remove formatting from the copied text, so it pastes as plain text |  |
| [`clipboard-to-file`](automations/clipboard-to-file.sh) | Save the copied text to a file |  |
| [`new-uuid`](automations/new-uuid.sh) | Generate a new UUID and copy it to the clipboard |  |
| [`pretty-json`](automations/pretty-json.sh) | Format the JSON on the clipboard with indentation, or say why it isn't valid JSON |  |
| [`count-words`](automations/count-words.sh) | Count the words, characters and lines in the copied text |  |

### Apps

| Automation | What it does | Notes |
|---|---|---|
| [`quit-apps`](automations/quit-apps.sh) | Quit all open apps except the ones the request names | asks first; shows what it would do |
| [`force-quit`](automations/force-quit.sh) | Force-quit one app that's frozen or not responding, losing its unsaved work | asks first; shows what it would do |
| [`hide-apps`](automations/hide-apps.applescript) | Hide every app except the one in front, to clear the screen |  |

### Developer

| Automation | What it does | Notes |
|---|---|---|
| [`brew-upgrade`](automations/brew-upgrade.sh) | Update Homebrew, upgrade all installed packages, and clean up old versions and unused dependencies | needs Homebrew |
| [`clean-derived-data`](automations/clean-derived-data.sh) | Delete Xcode's DerivedData to fix stale builds and free up disk space | asks first; shows what it would do |
| [`simulators`](automations/simulators.sh) | List, boot, shut down or erase iOS simulators | asks first for erase; needs Xcode |
| [`serve-folder`](automations/serve-folder.sh) | Serve a folder over HTTP on a local port, to preview a website or share files, until Ctrl-C |  |
| [`open-repo-page`](automations/open-repo-page.sh) | Open the current git repository's page on GitHub or GitLab in the browser |  |

### Productivity

| Automation | What it does | Notes |
|---|---|---|
| [`new-note`](automations/new-note.sh) | Create a note in Apple Notes and open it |  |
| [`remind-me`](automations/remind-me.applescript) | Add a reminder to the Reminders app, optionally due in a number of minutes |  |
| [`timer`](automations/timer.sh) | Set a quick timer that notifies you with a sound after a number of minutes |  |
| [`pomodoro`](automations/pomodoro.sh) | Run Pomodoro focus sessions, work and break rounds with a notification at each switch, or stop them | runs in the background |
| [`screen-recording`](automations/screen-recording.sh) | Record the screen to a video file for a number of seconds, without sound | needs Screen Recording permission |

### Maintenance

| Automation | What it does | Notes |
|---|---|---|
| [`disk-space`](automations/disk-space.sh) | Show how much free disk space is left on each drive |  |
| [`battery`](automations/battery.sh) | Show the battery level, whether it's charging, how long is left, and the battery's health |  |
| [`time-machine-backup-now`](automations/time-machine-backup-now.sh) | Start a Time Machine backup now, or show when the last one finished |  |
| [`check-updates`](automations/check-updates.sh) | Check for macOS and Apple software updates, without installing anything |  |
| [`shutdown-later`](automations/shutdown-later.sh) | Shut down or restart the Mac now or after some minutes, or cancel a pending one | asks first for shutdown or restart; runs in the background |

<!-- automations:end -->

## Changing them

To change one for yourself, copy it into `~/.config/pls/automations`: your copy wins, and updates leave it alone.

To contribute, keep each automation self-contained (no paths into anyone's home, no files outside its own folder) and
check it before opening a pull request:

```sh
PLS_HOME=. pls doctor                                # no problems
PLS_HOME=. pls doctor --examples <id>                # every example picks it
python3 scripts/update-readme.py                     # refresh the table above
```

The formats, and how to write descriptions the model routes well, are in the
[use-pls skill](https://github.com/alexmx/pls/blob/main/skills/use-pls/SKILL.md).

## License

[MIT](LICENSE)
