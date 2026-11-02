param([ValidateSet('Install','Restore')][string]$Mode='Install',[string]$GameFolder)
$ErrorActionPreference='Stop'
function Hash-Bytes([byte[]]$Bytes) {
 $sha=[Security.Cryptography.SHA256]::Create()
 try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() } finally {$sha.Dispose()}
}
$written=New-Object 'System.Collections.Generic.List[object]'
try {
 Write-Host 'Majikoi A: Startup Fix + English Launcher and Settings v1.0'
 Write-Host 'Close the launcher, settings windows, and all five games first.'
 if(-not $GameFolder){$GameFolder=Read-Host 'Paste the game folder path'}
 $GameFolder=$GameFolder.Trim().Trim('"')
 if(-not (Test-Path -LiteralPath $GameFolder -PathType Container)){throw 'Game folder not found.'}
 $GameFolder=(Get-Item -LiteralPath $GameFolder).FullName
 $manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'patch-data.json') -Raw | ConvertFrom-Json
 $backup=Join-Path $GameFolder 'Majikoi-English-Startup-Mod-Backup-v1'
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
   if(Test-Path -LiteralPath $saved){if((Hash-Bytes ([IO.File]::ReadAllBytes($saved))) -ne $f.originalSha256){throw "Backup mismatch: $($f.name)"}}
   $next=[byte[]]$current.Clone()
   foreach($change in $f.changes){$chunk=[Convert]::FromBase64String($change.bytes);[Array]::Copy($chunk,0,$next,[int]$change.offset,$chunk.Length)}
   if((Hash-Bytes $next) -ne $f.patchedSha256){throw "Patch verification failed: $($f.name)"}
  }else{
   if($hash -eq $f.originalSha256){Write-Host "Already original: $($f.name)";continue}
   if(-not (Test-Path -LiteralPath $saved)){throw "Original backup missing: $($f.name). Restore requires the backups created by this installer."}
   $next=[IO.File]::ReadAllBytes($saved)
   if((Hash-Bytes $next) -ne $f.originalSha256){throw "Backup verification failed: $($f.name)"}
  }
  $jobs.Add([pscustomobject]@{Name=$f.name;Path=$target;Backup=$saved;Before=$current;After=$next})
 }
 # Prepare and validate every output before changing any game file.
 if($Mode -eq 'Install' -and $jobs.Count -gt 0){
  $null=New-Item -ItemType Directory -Path $backup -Force
  foreach($job in $jobs){if(-not (Test-Path -LiteralPath $job.Backup)){[IO.File]::WriteAllBytes($job.Backup,$job.Before)}}
 }
 foreach($job in $jobs){
  # Opening with exclusive access fails safely if the game is still running.
  $stream=[IO.File]::Open($job.Path,[IO.FileMode]::Open,[IO.FileAccess]::Write,[IO.FileShare]::None)
  $written.Add($job)
  try {$stream.Write($job.After,0,$job.After.Length);$stream.SetLength($job.After.Length);$stream.Flush()} finally {$stream.Dispose()}
  if((Hash-Bytes ([IO.File]::ReadAllBytes($job.Path))) -ne (Hash-Bytes $job.After)){throw "Write verification failed: $($job.Name)"}
  Write-Host "Updated: $($job.Name)"
 }
 Write-Host "$Mode complete. $($jobs.Count) files updated."
 if($Mode -eq 'Install'){Write-Host 'Use Launcher.exe as usual. Keep the backup folder to undo the mod.'}
 exit 0
}catch{
 $failure=$_.Exception.Message
 foreach($job in $written){try{[IO.File]::WriteAllBytes($job.Path,$job.Before)}catch{Write-Host "Automatic rollback failed for $($job.Name). Original backups remain in $backup." -ForegroundColor Red}}
 Write-Host "FAILED: $failure" -ForegroundColor Red
 exit 1
}
