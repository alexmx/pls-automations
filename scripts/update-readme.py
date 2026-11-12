"""Rewrites the automations table in README.md from `pls list --json`, run on this repo as a library.

Usage: python3 scripts/update-readme.py   (needs pls on PATH, or PLS=/path/to/pls)
"""
import json, os, pathlib, subprocess

ROOT = pathlib.Path(__file__).resolve().parent.parent
SECTIONS = {
    "System": ["dark-mode", "keep-awake", "sleep-display", "lock-screen", "set-wallpaper", "hidden-files",
               "dock-autohide", "screenshot-folder", "screenshot-format", "focus", "bluetooth", "low-power-mode"],
    "Sound and music": ["set-volume", "mute", "apple-music-control", "apple-music-playlist", "apple-music-now-playing", "say"],
    "Network": ["wifi", "flush-dns", "speed-test", "my-ip", "kill-port", "ports-in-use", "ping-host"],
    "Files": ["clean-downloads", "image-compress", "image-resize", "image-convert", "video-convert", "zip", "unzip",
              "large-files", "organize-folder", "empty-trash", "eject-disks"],
    "Clipboard and text": ["plain-clipboard", "clipboard-to-file", "new-uuid", "pretty-json", "count-words"],
    "Apps": ["quit-apps", "force-quit", "hide-apps"],
    "Developer": ["brew-upgrade", "serve-folder", "open-repo-page", "git-prune-branches", "git-worktree", "git-worktree-clean"],
    "Apple development": ["simulators", "sim-open-url", "sim-push", "sim-appearance", "profile-info", "app-signature", "xcode-switch", "xcode-cleanup"],
    "Ghostty": ["ghostty-workspace", "ghostty-split", "ghostty-jump", "ghostty-ssh", "ghostty-present"],
    "Productivity": ["new-note", "remind-me", "timer", "pomodoro", "screen-recording"],
    "Maintenance": ["disk-space", "battery", "time-machine-backup-now", "check-updates", "shutdown-later"],
}
NEEDS_SHORTCUT = {"focus": "Set Focus", "bluetooth": "Set Bluetooth"}
NEEDS = {"brew-upgrade": "Homebrew", "git-worktree": "Ghostty 1.3+ for the tab", "flush-dns": "your password (sudo)", "low-power-mode": "your password (sudo)",
         "lock-screen": "Accessibility permission", "screen-recording": "Screen Recording permission",
         "simulators": "Xcode", "sim-open-url": "Xcode", "sim-push": "Xcode", "sim-appearance": "Xcode", "xcode-switch": "your password (sudo) to switch",
         "ghostty-workspace": "Ghostty 1.3+; lazygit, if you want it in a repo", "ghostty-split": "Ghostty 1.3+", "ghostty-jump": "Ghostty 1.3+", "ghostty-ssh": "Ghostty 1.3+", "ghostty-present": "Ghostty 1.3+"}

env = dict(os.environ, PLS_HOME=str(ROOT), PLS_MODEL="off")
automations = {a["id"]: a for a in json.loads(subprocess.check_output([os.environ.get("PLS", "pls"), "list", "--json"], env=env))}
listed = [id for ids in SECTIONS.values() for id in ids]
missing = sorted(set(automations) - set(listed))
assert not missing, f"add these to a section in {__file__}: {missing}"

def notes(a):
    out = []
    if a["confirm"] or a.get("confirmWhen"):
        out.append("asks first" if a["confirm"] else f"asks first for {' or '.join(a['confirmWhen']['choices'])}")
    if a["preview"]:
        out.append("shows what it would do")
    if a["background"]:
        out.append("runs in the background")
    if a["id"] in NEEDS_SHORTCUT:
        out.append(f"needs the [“{NEEDS_SHORTCUT[a['id']]}” Shortcut](#setting-up-focus-and-bluetooth)")
    if a["id"] in NEEDS:
        out.append(f"needs {NEEDS[a['id']]}")
    return "; ".join(out)

lines = []
for section, ids in SECTIONS.items():
    lines += [f"### {section}", "", "| Automation | Ask | What it does | Notes |", "|---|---|---|---|"]
    for id in ids:
        a = automations[id]
        path = pathlib.Path(a["source"]).relative_to(ROOT)
        ask = f"“{a['examples'][0]}”" if a["examples"] else ""
        lines.append(f"| [`{id}`]({path}) | {ask} | {a['description']} | {notes(a)} |")
    lines.append("")

readme = ROOT / "README.md"
text = readme.read_text()
start, end = "<!-- automations:start -->", "<!-- automations:end -->"
before, rest = text.split(start)
_, after = rest.split(end)
readme.write_text(before + start + "\n\n" + "\n".join(lines) + "\n" + end + after)
print(f"{len(automations)} automations in {len(SECTIONS)} sections")
