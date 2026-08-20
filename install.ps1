# ═══════════════════════════════════════════════════════
#   CS2 Dedicated Server — Instalador Windows
#   Uso: .\install.ps1   (PowerShell como Administrador)
# ═══════════════════════════════════════════════════════
#Requires -Version 5.1

$ErrorActionPreference = "Stop"

# ─── Configurações ────────────────────────────────────
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$SteamCmdDir = "$env:USERPROFILE\steamcmd"
$CS2Dir      = "$env:USERPROFILE\cs2server"
$SteamCmdExe = "$SteamCmdDir\steamcmd.exe"

# ─── Funções ─────────────────────────────────────────
function Write-Info    ($msg) { Write-Host "[INFO]   $msg" -ForegroundColor Cyan }
function Write-Success ($msg) { Write-Host "[OK]     $msg" -ForegroundColor Green }
function Write-Warn    ($msg) { Write-Host "[AVISO]  $msg" -ForegroundColor Yellow }
function Write-Err     ($msg) { Write-Host "[ERRO]   $msg" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "═════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CS2 Dedicated Server — Instalador Windows" -ForegroundColor Cyan
Write-Host "═════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ─── Instala SteamCMD ────────────────────────────────
if (-not (Test-Path $SteamCmdExe)) {
    Write-Info "Baixando SteamCMD..."
    New-Item -ItemType Directory -Force -Path $SteamCmdDir | Out-Null

    $zipPath = "$env:TEMP\steamcmd.zip"
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" `
        -OutFile $zipPath -UseBasicParsing

    Expand-Archive -Path $zipPath -DestinationPath $SteamCmdDir -Force
    Remove-Item $zipPath

    Write-Success "SteamCMD instalado em $SteamCmdDir"
} else {
    Write-Success "SteamCMD já instalado"
}

# ─── Instala / Atualiza CS2 ──────────────────────────
Write-Info "Baixando/atualizando CS2 Dedicated Server (~30 GB na primeira vez)..."
Write-Info "Pasta de instalação: $CS2Dir"

& $SteamCmdExe `
    +force_install_dir "$CS2Dir" `
    +login anonymous `
    +app_update 730 validate `
    +quit

Write-Success "CS2 instalado/atualizado com sucesso!"

# ─── Copia configs ───────────────────────────────────
$CfgDest = "$CS2Dir\game\csgo\cfg\matchzy"
New-Item -ItemType Directory -Force -Path $CfgDest | Out-Null

$serverCfg = "$ScriptDir\cfg\server.cfg"
if (Test-Path $serverCfg) {
    Copy-Item $serverCfg "$CS2Dir\game\csgo\cfg\server.cfg" -Force
    Write-Success "server.cfg copiado"
}

$matchzyCfg = "$ScriptDir\cfg\matchzy\matchzy.cfg"
if (Test-Path $matchzyCfg) {
    Copy-Item $matchzyCfg "$CfgDest\matchzy.cfg" -Force
    Write-Success "matchzy.cfg copiado"
}

# ─── Copia plugins ───────────────────────────────────
$PluginsSrc  = "$ScriptDir\plugins"
$AddonsDest  = "$CS2Dir\game\csgo\addons\counterstrikesharp\plugins"

$pluginFiles = Get-ChildItem -Path $PluginsSrc -Exclude ".gitkeep" -ErrorAction SilentlyContinue
if ($pluginFiles) {
    Write-Info "Copiando plugins..."
    New-Item -ItemType Directory -Force -Path $AddonsDest | Out-Null
    Copy-Item "$PluginsSrc\*" $AddonsDest -Recurse -Force
    Write-Success "Plugins copiados"
} else {
    Write-Warn "Pasta plugins\ está vazia. Instale Metamod + CounterStrikeSharp em:"
    Write-Warn "$CS2Dir\game\csgo\addons\"
}

# ─── Finaliza ────────────────────────────────────────
Write-Host ""
Write-Host "═════════════════════════════════════════════" -ForegroundColor Green
Write-Host "   Instalação concluída!" -ForegroundColor Green
Write-Host "═════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos passos:"
Write-Host "  1. Edite o arquivo .env com seu STEAM_TOKEN"
Write-Host "  2. Execute: .\start.ps1"
Write-Host ""
Write-Host "  CS2 instalado em: $CS2Dir"
Write-Host ""
