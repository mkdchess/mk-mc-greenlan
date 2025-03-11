<#
.SYNOPSIS
  Updates .env with gamerules and creates a sanitized .env.example.

.DESCRIPTION
  This script:
    - Reads gamerules.txt and converts its lines into a single-line string with literal \n
    - Inserts or replaces the RCON_CMDS_STARTUP line in .env
    - Copies .env to .env.example
    - Replaces the header comment in .env.example
    - Blanks out sensitive fields like CF_API_KEY and OPS in .env.example

.AUTHOR
  Written by ChatGPT (OpenAI), refined for GreenLAN by request.

.VERSION
  1.0
#>

# Load gamerules.txt and join lines with \n
$rcon = Get-Content -Raw -Encoding UTF8 -Path "gamerules.txt" -ErrorAction Stop -Force
$rcon = $rcon -replace "`r?`n", "\\n"

# Read current .env (or create a blank array)
$envPath = ".env"
$lines = if (Test-Path $envPath) { Get-Content $envPath } else { @() }

# Remove existing RCON_CMDS_STARTUP
$lines = $lines | Where-Object { $_ -notmatch '^RCON_CMDS_STARTUP=' }

# Add new RCON_CMDS_STARTUP line
$lines += "RCON_CMDS_STARTUP=`"$rcon`""

# Save updated .env
$lines | Set-Content $envPath -Encoding UTF8

# Copy to .env.example
Copy-Item ".env" ".env.example" -Force

# Read and modify .env.example
$exampleLines = Get-Content ".env.example"

# Replace comment header
if ($exampleLines[0] -match '^#\s*mc-GreenLAN') {
    $exampleLines[0] = '# mc-GreenLAN .env.example'
}

# Blank sensitive keys
$exampleLines = $exampleLines -replace '^CF_API_KEY=.*', 'CF_API_KEY='
$exampleLines = $exampleLines -replace '^OPS=.*', 'OPS='

# Save .env.example
$exampleLines | Set-Content ".env.example" -Encoding UTF8

Write-Host "✅ .env and .env.example updated successfully."
