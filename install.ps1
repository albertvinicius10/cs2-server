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

# ─── Registra Metamod no gameinfo ─────────────────────
$GameInfo = "$CS2Dir\game\csgo\gameinfo.gi"
if (Test-Path $GameInfo) {
    $gameInfoText = Get-Content $GameInfo -Raw
    if ($gameInfoText -notmatch '(?m)^\s*Game\s+csgo/addons/metamod\s*$') {
        Copy-Item $GameInfo "$GameInfo.bak" -Force
        $gameInfoText = $gameInfoText -replace '(?m)^(\s*Game_LowViolence\s+csgo_lv[^\r\n]*\r?\n)', '$1`t`tGame`tcsgo/addons/metamod`r`n'
        [System.IO.File]::WriteAllText($GameInfo, $gameInfoText, (New-Object System.Text.UTF8Encoding($false)))
        Write-Success "Metamod registrado no gameinfo.gi"
    }
}

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

# ─── Verifica Metamod + CounterStrikeSharp ────────────
$AddonSource = "$ScriptDir\game\csgo\addons"
$MetamodBinary = "$AddonSource\metamod\bin\win64\server.dll"
$CounterStrikeSharpBinary = "$AddonSource\counterstrikesharp\bin\win64\counterstrikesharp.dll"
if ((Test-Path $MetamodBinary) -and (Test-Path $CounterStrikeSharpBinary)) {
    Copy-Item "$AddonSource\*" "$CS2Dir\game\csgo\addons" -Recurse -Force
    Write-Success "Metamod + CounterStrikeSharp copiados"
} else {
    Write-Warn "Metamod/CounterStrikeSharp não estão completos no projeto."
    Write-Warn "Baixe os pacotes Windows e extraia em $CS2Dir\game\csgo\addons\"
}

# ─── Copia plugins ───────────────────────────────────
$PluginsSrc  = "$ScriptDir\plugins"
$AddonsRoot  = "$CS2Dir\game\csgo\addons\counterstrikesharp"
$AddonsDest  = "$AddonsRoot\plugins"

$pluginFiles = Get-ChildItem -Path $PluginsSrc -Exclude ".gitkeep" -ErrorAction SilentlyContinue
if ($pluginFiles) {
    Write-Info "Copiando plugins..."
    New-Item -ItemType Directory -Force -Path $AddonsDest | Out-Null

    $matchzyPackage = Get-ChildItem -Path $PluginsSrc -Directory |
        Where-Object { Test-Path "$($_.FullName)\addons\counterstrikesharp\plugins" } |
        Select-Object -First 1
    if ($matchzyPackage) {
        Get-ChildItem -Path $AddonsDest -Directory -ErrorAction SilentlyContinue |
            Where-Object { Test-Path "$($_.FullName)\addons\counterstrikesharp\plugins" } |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item "$($matchzyPackage.FullName)\addons\counterstrikesharp\plugins\*" $AddonsDest -Recurse -Force
        if (Test-Path "$($matchzyPackage.FullName)\cfg\MatchZy") {
            Copy-Item "$($matchzyPackage.FullName)\cfg\MatchZy" "$CS2Dir\game\csgo\cfg" -Recurse -Force
        }
    }

    $weaponPaintsSrc = "$PluginsSrc\WeaponPaints"
    if (Test-Path "$weaponPaintsSrc\WeaponPaints.dll") {
        Copy-Item $weaponPaintsSrc "$AddonsDest\WeaponPaints" -Recurse -Force
    }

    $gamedataSrc = "$PluginsSrc\gamedata"
    if (Test-Path $gamedataSrc) {
        New-Item -ItemType Directory -Force -Path "$AddonsRoot\gamedata" | Out-Null
        Copy-Item "$gamedataSrc\*" "$AddonsRoot\gamedata" -Recurse -Force
    }
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
