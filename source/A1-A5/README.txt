MAJIKOI A: STARTUP FIX + ENGLISH LAUNCHER AND SETTINGS
Version 1.0 | November 1, 2026 | Unofficial community patch

WHAT IT DOES
- Helps prevent startup hangs on modern Windows by restricting each A-1 through A-5 game to one logical processor.
- Translates the launcher's 14 buttons into English.
- Translates the shared startup settings controls, dropdown choices, System Info tab, and related dialog labels.
- Keeps the original launcher workflow and game filenames.

SUPPORTED VERSION
Prepared for the A1-A5 Special Edition + Dialogue Uncensor Patch installation examined during development. The edition name alone does not guarantee compatibility: this installer checks the exact SHA-256 of all seven target files. Other releases or modified files are rejected before any game file is changed.

REQUIREMENTS
Windows 11 (tested), built-in Windows PowerShell, and your own matching game installation. No Python, downloads, or additional runtime is required. You need write access to the game folder.

INSTALL
1. Extract this entire ZIP into a folder. Do not run it from inside the ZIP.
2. Close the launcher, settings windows, and all game instances.
3. Double-click Install.cmd.
4. Paste the full path to the game folder when prompted, then press Enter.
5. Wait for "Install complete", then launch Launcher.exe normally.

The installer first validates every target and prepares the changes in memory. It saves originals in Majikoi-English-Startup-Mod-Backup-v1 inside the game folder, then checks the installed files. Re-running the installer skips files already patched.

UNDO
Close the launcher, settings, and games. Double-click Restore.cmd and enter the same game folder. Keep the backup folder until you no longer need to restore. Restore also verifies its inputs; it will not overwrite files from a different version or a later modification. You can alternatively copy the seven original files from the backup folder back into the game folder while all game programs are closed.

IF INSTALLATION FAILS
Read the displayed error. A version mismatch means this build is unsupported; do not force the patch. A file-access error usually means a game/settings window is still open or the folder is not writable. Backups are retained. If writing fails after changes begin, the installer attempts to restore the files changed during that run.

SCOPE AND TESTING
The original startup failure was intermittent: processes sometimes stayed in the background without a game window. Five consecutive one-processor tests succeeded. After applying the executable flag, all five games opened twice each (10/10 startup tests). This suggests a startup timing/concurrency issue; the exact internal cause was not identified. Full playthroughs and performance across every scene have not been tested. Games remain restricted to one logical processor while running.

The translated launcher and A-1 settings/System Info layouts were visually checked. All five settings buttons use the same StartUpTool.exe. Japanese game titles, artwork, in-game text, and some diagnostic details are outside this mod's translation scope. This is not a full game translation.

No save files, game archives, or system-wide Windows settings are modified. The package does not include full game executables, artwork, audio, or game data archives. It contains only changed-byte patch data, installer scripts, and this guide. It does not provide or replace a game license and is not affiliated with the game's publisher.

FILES CHANGED
Launcher.dat
StartUpTool.exe
The five Japanese-named A-1 through A-5 game executables

SHARING
Share the ZIP as-is, rather than uploading your patched executables or backup folder. Recipients must supply their own supported game files. Preserve this guide and version information when sharing.
