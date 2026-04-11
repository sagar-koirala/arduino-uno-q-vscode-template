$settingsPath = ".vscode/settings.json"
$ip = $null

# Check if settings.json exists and contains an IP
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $ip = $settings.'arduino.ip'
    } catch {}
}

# Prompt for IP if not found
if ([string]::IsNullOrWhiteSpace($ip)) {
    $ip = Read-Host "No Arduino IP found. Please enter the Arduino IP address"
    if (-not (Test-Path ".vscode")) { New-Item -ItemType Directory -Path ".vscode" | Out-Null }
    
    $settingsObj = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
    $settingsObj | Add-Member -MemberType NoteProperty -Name "arduino.ip" -Value $ip -Force
    $settingsObj | ConvertTo-Json | Set-Content $settingsPath
    
    Write-Host "Saved IP to settings.json!"
    Write-Host "⚠️ NOTE: VS Code already loaded the empty IP for this sequence. After this setup finishes, please run the Deploy task one more time! ⚠️" -ForegroundColor Yellow
}

# Ensure SSH key exists
$sshKey = "$env:USERPROFILE\.ssh\id_ed25519"
if (-not (Test-Path $sshKey)) {
    Write-Host "SSH key not found locally. Generating a new ed25519 key..."
    ssh-keygen -t ed25519 -f $sshKey -N '""'
}

# Test if passwordless authentication already works
Write-Host "Testing passwordless authentication to arduino@$ip..."
$null = ssh -o BatchMode=yes -o ConnectTimeout=3 "arduino@$ip" "exit" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Password authentication required. Securely copying public key to the Arduino..."
    Write-Host ">>> PLEASE ENTER THE ARDUINO PASSWORD BELOW <<<" -ForegroundColor Cyan
    
    $pubKey = Get-Content "$sshKey.pub"
    ssh "arduino@$ip" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH Key successfully registered on the Arduino!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to set up SSH key." -ForegroundColor Red
        # Note: If this fails, it might be due to interactive prompts failing inside VS Code Tasks.
        exit 0
    }
} else {
    Write-Host "✅ Passwordless SSH is already configured and working smoothly!" -ForegroundColor Green
}