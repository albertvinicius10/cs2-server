# ═══════════════════════════════════════════════════════
#   CS2 Dedicated Server — Inicializador Windows
#   Uso: .\start.ps1
# ═══════════════════════════════════════════════════════
#Requires -Version 5.1

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$CS2Dir     = "$env:USERPROFILE\cs2server"
$CS2Binary  = "$CS2Dir\game\bin\win64\cs2.exe"

function Write-Info ($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Warn ($msg) { Write-Host "[AVISO] $msg" -ForegroundColor Yellow }
function Write-Err  ($msg) { Write-Host "[ERRO]  $msg" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  CS2 Dedicated Server - Iniciando (Windows)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ─── Carrega .env ────────────────────────────────────
$EnvFile = "$ScriptDir\.env"
$env_vars = @{}

if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        $line = $_.Trim()
        # Ignora linhas vazias e comentários
        if ($line -and -not $line.StartsWith('#')) {
            $parts = $line -split '=', 2
            if ($parts.Length -eq 2) {
                $key   = $parts[0].Trim()
                $value = ($parts[1] -replace '\s+#.*$', '').Trim().Trim('"').Trim("'")
                $env_vars[$key] = $value
                [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
    Write-Info ".env carregado"
} else {
    Write-Warn "Arquivo .env não encontrado. Usando valores padrão."
}

# ─── Helpers para ler variáveis ───────────────────────
function Get-Env ($key, $default = "") {
    $val = [System.Environment]::GetEnvironmentVariable($key)
    if ([string]::IsNullOrEmpty($val)) { return $default }
    return $val
}

# ─── Verifica instalação ─────────────────────────────
if (-not (Test-Path $CS2Binary)) {
    Write-Err "CS2 não encontrado em $CS2Binary`n       Execute primeiro: .\install.ps1"
}

# ─── Verifica token ──────────────────────────────────
$steamToken = Get-Env "STEAM_TOKEN"
if ([string]::IsNullOrEmpty($steamToken)) {
    Write-Warn "STEAM_TOKEN não definido! Servidor não aparecerá na lista pública."
    Write-Warn "Obtenha em: https://steamcommunity.com/dev/managegameservers"
}

$configurator = Join-Path $ScriptDir "configure_weaponpaints.py"
if ((Test-Path $configurator) -and (Get-Command python -ErrorAction SilentlyContinue)) {
    & python $configurator
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Não foi possível atualizar a configuração do WeaponPaints."
    }
}

$serverName     = Get-Env "SERVER_NAME"     "CS2 Server 5x5"
$serverPassword = Get-Env "SERVER_PASSWORD" ""
$serverPort     = Get-Env "SERVER_PORT"     "27015"
$startMap       = Get-Env "START_MAP"       "de_dust2"

Write-Info "Iniciando CS2 Dedicated Server..."
Write-Info "Nome:  $serverName"
Write-Info "Porta: $serverPort"
Write-Host ""

# ─── Argumentos do servidor ──────────────────────────
$serverArgs = @(
    "-dedicated",
    "-console",
    "-usercon",
    "-game", "csgo",
    "-insecure",
    "-nobots",
    "-port", $serverPort,
    "+game_type", "0",
    "+game_mode", "1",
    "+mapgroup", "mg_active",
    "+map", $startMap,
    "+sv_setsteamaccount", $steamToken,
    "+hostname", $serverName,
    "+sv_password", $serverPassword,
    "+sv_cheats", "0",
    "+sv_lan", "0",
    "+mp_friendlyfire", "0"
)

# ─── Inicia CS2 ──────────────────────────────────────
Push-Location $CS2Dir
try {
    & $CS2Binary @serverArgs
} finally {
    Pop-Location
}
