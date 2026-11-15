MAJIKOI A+ WIN 11 STARTUP FIX — v1.1
Unofficial community patch | November 15, 2026

Restricts the two game executables to one logical processor to address startup crashes. No translation changes are included.

SUPPORTED BUILD
Tested with Majikoi A+ Disc using Daybreak Translations full game patch v2.0. Both majikoiAplus.exe and the Japanese-named game executable must match the hashes in patch-data.json. Other builds are rejected before any files are changed.

INSTALL
1. Extract this entire ZIP.
2. Close the game, launcher, and settings windows.
3. Run Install.cmd and choose your game installation folder in the popup.
4. After installation succeeds, launch majikoiAplus.exe as usual.

Windows PowerShell is built into Windows. No Python or additional downloads are needed. You need write access to the game folder.

UNDO
Run Restore.cmd and select the game folder in the popup. Original files are saved in Majikoi-APlus-Startup-Mod-Backup-v1 inside that folder. Keep this backup to undo the mod. Restoration verifies backup hashes. You can also manually copy the originals back while the game is closed.

The installer validates all files before changing any, skips already-patched files, checks installed hashes, and attempts rollback if writing fails. If a build is unsupported, do not force installation. For file-access errors, close all game processes and check folder permissions.

TESTING AND LIMITATIONS
Before the fix, the English executable crashed in both startup tests. After the fix, three English-executable launches and one Japanese-filename executable launch succeeded (4/4). Each executable differs from its original by one byte. Full gameplay and all hardware configurations have not been tested. The game remains limited to one logical processor while running.

No saves, game archives, translation files, or global Windows settings are changed. This package contains changed-byte patch data and installer scripts, not full game executables or game assets. You must supply your own matching game installation. This unofficial patch is not affiliated with the publisher or Daybreak Translations.

Share this ZIP, not your game files or backups.

Version 1.1 changes: Install and Restore now open a folder-selection popup. Cancel exits without changing files. The game patches and backup folder names are unchanged from v1.0.
