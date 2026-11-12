# pls automations

**Everyday Mac automations for [pls](https://github.com/alexmx/pls), ready to ask for in plain words.** Mac
settings, sound and music, the network, files and images, the clipboard, apps, Xcode and the simulator, Ghostty,
developer chores and reminders.

```bash
pls "it's too bright"
pls "free up port 3000"
pls "keep my mac awake for 2 hours"
pls "what's taking up space?"
pls "remind me in 20 minutes to check the oven"
```

- **Read before you trust.** Each one is a short shell script or AppleScript, and none runs until you've looked at it
  and turned it on.
- **Tested against the model.** Each one's description, examples and params were checked against the on-device model
  pls uses, so plain requests find it and fill its values correctly.

## Get started

Install the collection, turn one on and ask for it:

```bash
pls collection add alexmx/pls-automations   # everything starts off; answer n to review them later
pls collection enable my-ip                  # read one and turn it on
pls "what's my ip"
```

Then:

```bash
pls collection review                        # read what's off and turn on what you trust
pls collection update                        # get changes; what changed is off until you review it
pls collection disable focus                 # turn one off
```

An approval is for the files as you read them, so an update that changes one turns it off until you review it again.
If you have an automation of your own with the same id, yours wins, and this one is still there as
`alexmx/pls-automations/<id>`.

## Requirements

- macOS 26 and [pls](https://github.com/alexmx/pls)
- A few need more, listed in the Notes column: Homebrew, Xcode, your password for `sudo`, or a permission macOS asks
  for the first time (Accessibility, Screen Recording, or "control this app" for the AppleScript ones)
- `focus` and `bluetooth` need a Shortcut you build once; see [below](#setting-up-focus-and-bluetooth)

## Automations

<!-- automations:start -->

### System

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`dark-mode`](automations/dark-mode.applescript) | “it's too bright” | Switch the system appearance between dark and light |  |
| [`keep-awake`](automations/keep-awake.sh) | “keep my mac awake for 2 hours” | Keep the Mac and its display awake for a number of minutes, or let it sleep again | runs in the background |
| [`sleep-display`](automations/sleep-display.sh) | “turn off the screen” | Turn the display off now, leaving everything running |  |
| [`lock-screen`](automations/lock-screen.applescript) | “lock my mac” | Lock the Mac now, so it needs your password to get back in | needs Accessibility permission |
| [`set-wallpaper`](automations/set-wallpaper.sh) | “set my wallpaper to ~/Pictures/beach.jpg” | Set the desktop picture to an image file |  |
| [`hidden-files`](automations/hidden-files.sh) | “show hidden files” | Show or hide hidden files (dotfiles) in Finder |  |
| [`dock-autohide`](automations/dock-autohide.sh) | “hide the dock” | Turn Dock auto-hiding on or off |  |
| [`screenshot-folder`](automations/screenshot-folder.sh) | “save screenshots to ~/Pictures/Screenshots” | Change the folder new screenshots are saved in, or show where they go |  |
| [`screenshot-format`](automations/screenshot-format.sh) | “make screenshots jpg” | Change the setting for which file format future screenshots are saved in (existing files stay as they are) |  |
| [`focus`](automations/focus.sh) | “do not disturb for an hour” | Turn a macOS Focus mode on or off, optionally for a number of minutes | needs the [“Set Focus” Shortcut](#setting-up-focus-and-bluetooth) |
| [`bluetooth`](automations/bluetooth.sh) | “turn off bluetooth” | Turn Bluetooth on or off, or restart it | needs the [“Set Bluetooth” Shortcut](#setting-up-focus-and-bluetooth) |
| [`low-power-mode`](automations/low-power-mode.sh) | “turn on low power mode” | Turn Low Power Mode on or off to save battery | needs your password (sudo) |

### Sound and music

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`set-volume`](automations/set-volume.applescript) | “set the volume to 30” | Set the sound output volume to a level from 0 to 100 |  |
| [`mute`](automations/mute.applescript) | “mute” | Mute or unmute the sound, keeping the volume level |  |
| [`apple-music-control`](automations/apple-music-control.applescript) | “pause the music” | Play, pause, skip or go back a track in the Music app |  |
| [`apple-music-playlist`](automations/apple-music-playlist.sh) | “play my Chill playlist” | Play a playlist from the Music app by name |  |
| [`apple-music-now-playing`](automations/apple-music-now-playing.applescript) | “what's playing?” | Show what's playing in the Music app |  |
| [`say`](automations/say.sh) | “say hello world” | Speak or announce text out loud with the Mac's text-to-speech voice |  |

### Network

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`wifi`](automations/wifi.sh) | “turn off wifi” | Turn Wi-Fi on or off, or restart it |  |
| [`flush-dns`](automations/flush-dns.sh) | “flush dns” | Clear the DNS cache, for when websites won't load or still point to their old address | needs your password (sudo) |
| [`speed-test`](automations/speed-test.sh) | “how fast is my internet?” | Measure the internet connection's download and upload speed |  |
| [`my-ip`](automations/my-ip.sh) | “what's my IP?” | Show this Mac's IP address on the local network and on the internet |  |
| [`kill-port`](automations/kill-port.sh) | “free up port 3000” | Kill whatever process is listening on a TCP port | asks first; shows what it would do |
| [`ports-in-use`](automations/ports-in-use.sh) | “what's using port 5432?” | List which apps are listening on which TCP ports, without stopping anything |  |
| [`ping-host`](automations/ping-host.sh) | “ping google.com” | Check whether a host or website is reachable and how fast it answers |  |

### Files

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`clean-downloads`](automations/clean-downloads.sh) | “clean up my downloads” | Trash old files in Downloads that haven't changed for a number of days, to free up space | asks first; shows what it would do |
| [`image-compress`](automations/image-compress) | “shrink my screenshots” | Compress images in a folder to a lower quality, reducing file size but keeping their dimensions |  |
| [`image-resize`](automations/image-resize.sh) | “resize the photos in ~/Pictures/trip to 1200 pixels” | Resize images in a folder to smaller pixel dimensions (width and height) |  |
| [`image-convert`](automations/image-convert.sh) | “convert my iPhone photos to jpg” | Convert images in a folder to another file format |  |
| [`video-convert`](automations/video-convert.sh) | “make this video smaller: ~/Movies/demo.mov” | Shrink or convert a video file (.mov, .mp4) to a smaller size or another format, keeping the original |  |
| [`zip`](automations/zip.sh) | “zip ~/Projects/site” | Zip a file or folder into a .zip archive next to it |  |
| [`unzip`](automations/unzip.sh) | “unzip ~/Downloads/fonts.zip” | Extract a .zip archive next to it |  |
| [`large-files`](automations/large-files.sh) | “what's taking up space?” | List the biggest files in a folder and its subfolders, to see what's taking up space |  |
| [`organize-folder`](automations/organize-folder.sh) | “organize my downloads” | Sort the files in a folder into subfolders by type: Images, Documents, Videos, Audio, Archives, Installers, Other | asks first; shows what it would do |
| [`empty-trash`](automations/empty-trash.applescript) | “empty the trash” | Empty the Trash, permanently deleting what's in it | asks first; shows what it would do |
| [`eject-disks`](automations/eject-disks.applescript) | “eject all disks” | Safely eject all external drives and disk images |  |

### Clipboard and text

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`plain-clipboard`](automations/plain-clipboard.sh) | “make the clipboard plain text” | Remove formatting from the copied text, so it pastes as plain text |  |
| [`clipboard-to-file`](automations/clipboard-to-file.sh) | “save the clipboard to a file” | Save the copied text to a file |  |
| [`new-uuid`](automations/new-uuid.sh) | “new uuid” | Generate a new UUID and copy it to the clipboard |  |
| [`pretty-json`](automations/pretty-json.sh) | “pretty print the json I copied” | Format the JSON on the clipboard with indentation, or say why it isn't valid JSON |  |
| [`count-words`](automations/count-words.sh) | “how many words did I copy?” | Count the words, characters and lines in the copied text |  |

### Apps

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`quit-apps`](automations/quit-apps.sh) | “quit everything” | Quit all open apps except the ones the request names | asks first; shows what it would do |
| [`force-quit`](automations/force-quit.sh) | “force quit Xcode” | Force-quit one app that's frozen or not responding, losing its unsaved work | asks first; shows what it would do |
| [`hide-apps`](automations/hide-apps.applescript) | “hide everything else” | Hide every app except the one in front, to clear the screen |  |

### Developer

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`brew-upgrade`](automations/brew-upgrade.sh) | “update brew” | Update Homebrew, upgrade all installed packages, and clean up old versions and unused dependencies | needs Homebrew |
| [`serve-folder`](automations/serve-folder.sh) | “serve this folder” | Serve a folder over HTTP on a local port, to preview a website or share files, until Ctrl-C |  |
| [`open-repo-page`](automations/open-repo-page.sh) | “open this repo on github” | Open the current git repository's page on GitHub or GitLab in the browser |  |
| [`git-prune-branches`](automations/git-prune-branches.sh) | “clean up merged branches” | Delete the local git branches of a repo that are merged into its default branch, or whose remote branch is gone after a merge | asks first; shows what it would do |
| [`git-worktree`](automations/git-worktree.sh) | “new worktree for fix-login” | Start work on a git branch in its own worktree, a folder next to the repo, and open it in a new Ghostty tab; a new branch starts from the default branch | needs Ghostty 1.3+ for the tab |

### Apple development

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`simulators`](automations/simulators.sh) | “boot the iPhone 17 simulator” | List, boot, shut down or erase iOS simulators | asks first for erase; needs Xcode |
| [`sim-open-url`](automations/sim-open-url.sh) | “open myapp://settings in the simulator” | Open a link or deep link (a custom URL scheme) in the running iOS simulator, to test how an app handles it | needs Xcode |
| [`sim-push`](automations/sim-push.sh) | “send a test push to com.me.app saying Hello” | Send a test push notification to an app in the running iOS simulator, by its bundle id | needs Xcode |
| [`sim-appearance`](automations/sim-appearance.sh) | “simulator dark mode” | Switch the running iOS simulators to dark or light mode, or change their text size (Dynamic Type), to check how an app's UI holds up; or show the current settings | needs Xcode |
| [`profile-info`](automations/profile-info.sh) | “what's in this provisioning profile ~/Downloads/App.mobileprovision” | Show what's in an iOS or macOS provisioning profile (app id, team, type, expiry, devices, entitlements), or list the installed profiles and which have expired |  |
| [`app-signature`](automations/app-signature.sh) | “show the entitlements of ~/Desktop/MyApp.app” | Show how an app is code signed: who signed it, what kind of signature, whether it's valid and notarized, and its entitlements |  |
| [`xcode-switch`](automations/xcode-switch.sh) | “switch to Xcode beta” | Switch the active Xcode (xcode-select) between the installed versions, or list them and show which one is in use | asks first for switch; needs your password (sudo) to switch |
| [`xcode-cleanup`](automations/xcode-cleanup.sh) | “Xcode is hogging space, clean it up” | Free the disk space Xcode piles up: DerivedData (also fixes stale builds), device support files, old simulators whose iOS version is no longer installed and simulator caches, and Swift package caches; archives are kept | asks first; shows what it would do |

### Ghostty

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`ghostty-workspace`](automations/ghostty-workspace.sh) | “new dev workspace” | Split the current Ghostty pane into a dev workspace: this shell on the left, lazygit top right and a smaller shell bottom right | needs Ghostty 1.3+; lazygit, if you want it in a repo |
| [`ghostty-split`](automations/ghostty-split.sh) | “split right” | Split the current Ghostty pane, opening the new pane in the current folder, and run a command in it if one is given | needs Ghostty 1.3+ |
| [`ghostty-jump`](automations/ghostty-jump.sh) | “go to the terminal in ark” | Go to the open Ghostty terminal in a folder, or with a title, by bringing it to the front | needs Ghostty 1.3+ |
| [`ghostty-ssh`](automations/ghostty-ssh.sh) | “ssh to build-mac” | Open a new Ghostty tab connected over SSH to a host | needs Ghostty 1.3+ |
| [`ghostty-present`](automations/ghostty-present.sh) | “big terminal for a demo” | Open a new Ghostty window with a big font, for a demo or screen sharing; other windows keep theirs | needs Ghostty 1.3+ |

### Productivity

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`new-note`](automations/new-note.sh) | “new note called groceries” | Create a note in Apple Notes and open it |  |
| [`remind-me`](automations/remind-me.applescript) | “remind me to call mom” | Add a reminder to the Reminders app, optionally due in a number of minutes |  |
| [`timer`](automations/timer.sh) | “set a timer for 10 minutes” | Set a quick timer that notifies you with a sound after a number of minutes |  |
| [`pomodoro`](automations/pomodoro.sh) | “start a pomodoro” | Run Pomodoro focus sessions, work and break rounds with a notification at each switch, or stop them | runs in the background |
| [`screen-recording`](automations/screen-recording.sh) | “record my screen for a minute” | Record the screen to a video file for a number of seconds, without sound | needs Screen Recording permission |

### Maintenance

| Automation | Ask | What it does | Notes |
|---|---|---|---|
| [`disk-space`](automations/disk-space.sh) | “how much disk space is free?” | Show how much free disk space is left on each drive |  |
| [`battery`](automations/battery.sh) | “how much battery do I have?” | Show the battery level, whether it's charging, how long is left, and the battery's health |  |
| [`time-machine-backup-now`](automations/time-machine-backup-now.sh) | “back up my mac now” | Start a Time Machine backup now, or show when the last one finished |  |
| [`check-updates`](automations/check-updates.sh) | “are there any macOS updates?” | Check for macOS and Apple software updates, without installing anything |  |
| [`shutdown-later`](automations/shutdown-later.sh) | “shut down in an hour” | Shut down or restart the Mac now or after some minutes, or cancel a pending one | asks first for shutdown or restart; runs in the background |

<!-- automations:end -->

## Setting up `focus` and `bluetooth`

macOS has no command for Focus modes or Bluetooth, so these two run a Shortcut you build once in the Shortcuts app.
Until you do, they say so and stop.

- **Set Bluetooth**: an **If** on Shortcut Input *is* `on` with **Set Bluetooth: On**, and **Otherwise**
  **Set Bluetooth: Off**. (`bluetooth` reads the current state itself, so the Shortcut only ever gets `on` or `off`.)
- **Set Focus**: **Get Dictionary from Input**, then **Get Dictionary Value** for `mode` and for `minutes`. For each
  Focus you use, an **If** on `mode` (e.g. *is* `work`) with **Set Focus: Work, On** — until **Adjust Date** (Current
  Date + `minutes` minutes) if you want the time limit. For `off`, **Set Focus** actions that turn your Focus modes
  off. The choices are `do-not-disturb`, `work`, `personal`, `sleep`, `morning` and `reduce-interruptions`; trim the
  `@pls.param mode` line in `automations/focus.sh` to the ones you have.

## Make one yours

Copy it into `~/.config/pls/automations` and change it there: your copy wins, and updates leave it alone.

## Contributing

Keep each automation self-contained (no paths into anyone's home, no files outside its own folder) and check it
before opening a pull request:

```bash
PLS_HOME=. pls doctor                         # no problems
PLS_HOME=. pls doctor --examples <id>         # every example picks it
python3 scripts/update-readme.py              # refresh the table
```

The formats, and how to write descriptions the model routes well, are in the
[use-pls skill](https://github.com/alexmx/pls/blob/main/skills/use-pls/SKILL.md).

## License

[MIT](LICENSE)
