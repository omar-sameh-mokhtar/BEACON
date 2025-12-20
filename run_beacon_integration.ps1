$ADB="C:\Users\Dell\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$SCRCPY="C:\scrcpy-win64-v3.3.4\scrcpy-win64-v3.3.4\scrcpy.exe"
$DEVICE_ID="R9KX601CKTP"

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

$VIDEO_NAME="beacon_$TIMESTAMP.mp4"

$INT_TXT="integration_$TIMESTAMP.txt"
$INT_HTML="integration_$TIMESTAMP.html"

$FLUTTER_TXT="flutter_$TIMESTAMP.txt"
$FLUTTER_HTML="flutter_$TIMESTAMP.html"

Write-Host "=== Beacon Tests Started ==="

Remove-Item $INT_TXT,$INT_HTML,$FLUTTER_TXT,$FLUTTER_HTML -ErrorAction SilentlyContinue

& $ADB -s $DEVICE_ID logcat -c

# ==========================
# Screen record
# ==========================
$scrcpyProcess = Start-Process `
  -FilePath $SCRCPY `
  -ArgumentList "--serial=$DEVICE_ID --record=$VIDEO_NAME --no-control" `
  -PassThru

Start-Sleep 4

# ==========================
# Integration Tests
# ==========================
Write-Host "Running integration tests..."
try {
    flutter test integration_test -d $DEVICE_ID 2>&1 | Tee-Object $INT_TXT
}
catch {}

# ==========================
# Flutter Tests
# ==========================
Write-Host "Running flutter tests..."
try {
    flutter test 2>&1 | Tee-Object $FLUTTER_TXT
}
catch {}

# ==========================
# Logcat
# ==========================
& $ADB -s $DEVICE_ID logcat -d > logcat.txt
Add-Content $INT_TXT "`n===== LOGCAT =====`n"
Add-Content $INT_TXT (Get-Content logcat.txt)

Add-Content $FLUTTER_TXT "`n===== LOGCAT =====`n"
Add-Content $FLUTTER_TXT (Get-Content logcat.txt)

# ==========================
# Stop recording
# ==========================
if ($scrcpyProcess -and !$scrcpyProcess.HasExited) {
    Stop-Process -Id $scrcpyProcess.Id
}

# ==========================
# TXT -> HTML function
# ==========================
function Convert-ToHtml($txt, $html, $title) {
    $escaped = Get-Content $txt | ForEach-Object {
        $_ -replace "&","&amp;" -replace "<","&lt;" -replace ">","&gt;"
    }

@"
<html>
<head>
<title>$title</title>
<style>
body { background:#0d1117; color:#c9d1d9; font-family:Consolas; }
.pass { color:#3fb950; }
.fail { color:#f85149; }
pre { white-space: pre-wrap; }
</style>
</head>
<body>
<h2>$title</h2>
<pre>
$($escaped -join "`n")
</pre>
</body>
</html>
"@ | Out-File $html -Encoding utf8
}

# ==========================
# Generate HTMLs
# ==========================
Convert-ToHtml $INT_TXT $INT_HTML "Beacon Integration Tests"
Convert-ToHtml $FLUTTER_TXT $FLUTTER_HTML "Beacon Flutter Tests"

Write-Host "=== DONE ==="
Write-Host "Video:        $VIDEO_NAME"
Write-Host "Integration:  $INT_HTML"
Write-Host "Flutter:      $FLUTTER_HTML"
