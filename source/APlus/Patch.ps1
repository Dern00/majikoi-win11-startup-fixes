param([ValidateSet('Install','Restore')][string]$Mode='Install',[string]$GameFolder)
$ErrorActionPreference='Stop'
function Hash-Bytes([byte[]]$Bytes) {
 $sha=[Security.Cryptography.SHA256]::Create()
 try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() } finally {$sha.Dispose()}
}
function Hash-Stream([IO.FileStream]$Stream) {
 $sha=[Security.Cryptography.SHA256]::Create()
 try {
  $Stream.Position=0
  return ([BitConverter]::ToString($sha.ComputeHash($Stream))).Replace('-','').ToLowerInvariant()
 } finally {$sha.Dispose()}
}
$locked=New-Object 'System.Collections.Generic.List[object]'
$written=New-Object 'System.Collections.Generic.List[object]'
try {
 Write-Host 'Majikoi A+ Win 11 startup fix v1.1.1'
 Write-Host 'Close the launcher, settings windows, and the game first.'
 if(-not $GameFolder){
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.Application]::EnableVisualStyles()
  $picker=New-Object System.Windows.Forms.FolderBrowserDialog
  $picker.Description="Select the game installation folder for $Mode."
  $picker.ShowNewFolderButton=$false
  $picker.SelectedPath=$PSScriptRoot
  try {
   if($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK){
    Write-Host 'Cancelled. No files were changed.'
    exit 0
   }
   $GameFolder=$picker.SelectedPath
  } finally {$picker.Dispose()}
 }
 $GameFolder=$GameFolder.Trim().Trim('"')
 if(-not (Test-Path -LiteralPath $GameFolder -PathType Container)){throw 'Game folder not found.'}
 $GameFolder=(Get-Item -LiteralPath $GameFolder).FullName
 $manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'patch-data.json') -Raw | ConvertFrom-Json
 $backup=Join-Path $GameFolder 'Majikoi-APlus-Startup-Mod-Backup-v1'
 $jobs=New-Object 'System.Collections.Generic.List[object]'
 foreach($f in $manifest.files){
  if([IO.Path]::GetFileName($f.name) -cne $f.name){throw 'Invalid filename in patch data.'}
  $target=Join-Path $GameFolder $f.name
  if(-not (Test-Path -LiteralPath $target -PathType Leaf)){throw "Required file missing: $($f.name)"}
  $current=[IO.File]::ReadAllBytes($target);$hash=Hash-Bytes $current
  if($hash -ne $f.originalSha256 -and $hash -ne $f.patchedSha256){throw "Unsupported or modified file: $($f.name). No files have been changed. This patch requires the exact supported edition."}
  $saved=Join-Path $backup $f.name
  if($Mode -eq 'Install'){
   if($hash -eq $f.patchedSha256){Write-Host "Already patched: $($f.name)";continue}
   $next=[byte[]]$current.Clone()
   foreach($change in $f.changes){$chunk=[Convert]::FromBase64String($change.bytes);[Array]::Copy($chunk,0,$next,[int]$change.offset,$chunk.Length)}
   if((Hash-Bytes $next) -ne $f.patchedSha256){throw "Patch verification failed: $($f.name)"}
  }else{
   if($hash -eq $f.originalSha256){Write-Host "Already original: $($f.name)";continue}
   if(-not (Test-Path -LiteralPath $saved)){throw "Original backup missing: $($f.name). Restore requires the backups created by this installer."}
   $next=[IO.File]::ReadAllBytes($saved)
   if((Hash-Bytes $next) -ne $f.originalSha256){throw "Backup verification failed: $($f.name)"}
  }
  $jobs.Add([pscustomobject]@{Name=$f.name;Path=$target;Backup=$saved;Before=$current;BeforeHash=$hash;After=$next;Stream=$null})
 }
 # Lock and recheck every file that will change before creating backups or writing.
 # Keep the same handles open through verification and any rollback.
 foreach($job in $jobs){
  try {
   $job.Stream=[IO.File]::Open($job.Path,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
  } catch {
   throw "Could not lock $($job.Name) for writing. Close the game and launcher and check that the folder is writable. $($_.Exception.Message)"
  }
  $locked.Add($job)
  if((Hash-Stream $job.Stream) -ne $job.BeforeHash){
   throw "File changed during verification: $($job.Name). No game files were changed. Run the installer again when the folder is idle."
  }
 }

 if($Mode -eq 'Install' -and $jobs.Count -gt 0){
  $null=New-Item -ItemType Directory -Path $backup -Force
  foreach($job in $jobs){
   if(Test-Path -LiteralPath $job.Backup){
    if((Hash-Bytes ([IO.File]::ReadAllBytes($job.Backup))) -ne $job.BeforeHash){
     throw "Backup mismatch: $($job.Name)"
    }
    continue
   }
   $backupStream=[IO.File]::Open($job.Backup,[IO.FileMode]::CreateNew,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
   try {
    $backupStream.Write($job.Before,0,$job.Before.Length)
    $backupStream.Flush()
    if((Hash-Stream $backupStream) -ne $job.BeforeHash){
     throw "Could not verify backup: $($job.Name)"
    }
   } finally {$backupStream.Dispose()}
  }
 }
 foreach($job in $jobs){
  $written.Add($job)
  $job.Stream.Position=0
  $job.Stream.Write($job.After,0,$job.After.Length)
  $job.Stream.SetLength($job.After.Length)
  $job.Stream.Flush()
  if((Hash-Stream $job.Stream) -ne (Hash-Bytes $job.After)){
   throw "Write verification failed: $($job.Name)"
  }
  Write-Host "Updated: $($job.Name)"
 }
 Write-Host "$Mode complete. $($jobs.Count) files updated."
 if($Mode -eq 'Install'){Write-Host 'Use majikoiAplus.exe as usual. Keep the backup folder to undo the mod.'}
 exit 0
}catch{
 $failure=$_.Exception.Message
 foreach($job in $written){
  try {
   $job.Stream.Position=0
   $job.Stream.Write($job.Before,0,$job.Before.Length)
   $job.Stream.SetLength($job.Before.Length)
   $job.Stream.Flush()
   if((Hash-Stream $job.Stream) -ne $job.BeforeHash){throw 'Rollback verification failed.'}
  } catch {
   Write-Host "Automatic rollback failed for $($job.Name). Original backups remain in $backup." -ForegroundColor Red
  }
 }
 Write-Host "FAILED: $failure" -ForegroundColor Red
 exit 1
}
finally {
 foreach($job in $locked){$job.Stream.Dispose()}
}
