# Majikoi Windows 11 startup fixes

Unofficial patches for intermittent startup failures in Majikoi A1–A5 and Majikoi A+ Disc.

## Downloads

- [Majikoi A1-A5 Win 11 startup fix.zip](./Majikoi%20A1-A5%20Win%2011%20startup%20fix.zip?raw=true)
- [Majikoi A+ Win 11 startup fix.zip](./Majikoi%20A%2B%20Win%2011%20startup%20fix.zip?raw=true)

Click a link to download, then extract the entire ZIP before running it.

## Installation

1. Close the game, launcher, and settings windows.
2. Extract the appropriate ZIP and run **Install.cmd**.
3. Paste the full path to your game folder when prompted.
4. After installation succeeds, launch the game normally. For A+, use `majikoiAplus.exe`.

The installers use Windows PowerShell, which is built into Windows. No Python, extra runtime, or downloads are needed. The game folder must be writable.

## What changes

Both fixes set the executable's `IMAGE_FILE_UP_SYSTEM_ONLY` flag, restricting each game process to one logical processor. This resolved the observed startup hangs/crashes in the tests below. The exact internal fault is not known. The restriction remains active during gameplay.

The **A1–A5 package also includes English launcher and startup-settings labels**, including dropdown choices and the System Info tab. It is not a full game translation. Japanese titles, artwork, in-game text, and some diagnostics are outside its scope.

The **A+ package only fixes startup**; it does not change translations.

## Supported builds

| Package | Tested installation |
| --- | --- |
| A1–A5 | Special Edition A1–A5 with Dialogue Uncensor Patch |
| A+ | A+ Disc with Daybreak Translations full game patch v2.0 |

Edition names are not sufficient to establish compatibility. Each installer checks the exact SHA-256 hashes listed in its `patch-data.json`. Unsupported or differently modified files are rejected before any game file is changed. Do not force a mismatched patch.

A+ expects both `majikoiAplus.exe` and the Japanese-named game executable present in the tested installation.

## Backups and removal

Run **Restore.cmd** from the extracted package and enter the game folder. Keep the installer-created backup folder in the game directory:

- A1–A5: `Majikoi-English-Startup-Mod-Backup-v1`
- A+: `Majikoi-APlus-Startup-Mod-Backup-v1`

The installers verify all inputs and prepared outputs, preserve originals, skip already-patched files, verify written files, and attempt rollback if writing fails. Restoration also validates hashes. Existing patched installations without installer-created backups cannot be restored by this package; use their original backups instead.

## Testing

- A1–A5: all five patched games opened twice each, **10/10 startup checks**. English launcher and A1 settings/System Info layouts were visually inspected; the settings program is shared by all five games.
- A+: the unpatched English executable crashed on both attempts. After patching, three English-executable launches and one Japanese-filename launch passed, **4/4 checks**.
- Installer tests: A1–A5 installation, repeat installation, byte-exact restoration, and unsupported-file rejection; A+ installation and byte-exact restoration.

These are startup checks on one Windows 11 system, not full playthrough or broad hardware testing. The patches do not modify saves, game archives, or global Windows settings.

## Package contents and source

The ZIPs contain patch data, install/restore scripts, and instructions. Full executables and game assets are not included. The `source/` folders contain the same unpacked installer files for inspection. Supply your own matching game installation. This repository is unofficial and is not affiliated with the publisher or Daybreak Translations.

## SHA-256 checksums

```
fb65ae33e293043ee7c64abee17f1e0293c643b01cb98e9b89a7ed419ceae2ee  Majikoi A1-A5 Win 11 startup fix.zip
1f9e33bb4e9c78a196a9096ffc37060974154bfeaf0963198cb4f621e86f575b  Majikoi A+ Win 11 startup fix.zip
```
