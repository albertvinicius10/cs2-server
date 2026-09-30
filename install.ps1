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
        $gameInfoText = $gameInfoText -replace '(?m)^(\s*Game_LowViolence\s+csgo_lv[^\r\n]*\r?\n)', ('$1' + "`t`tGame`tcsgo/addons/metamod`r`n")
        [System.IO.File]::WriteAllText($GameInfo, $gameInfoText, (New-Object System.Text.UTF8Encoding($false)))
        Write-Success "Metamod registrado no gameinfo.gi"
    }
}

# ─── Copia configs ───────────────────────────────────
$CfgDest = "$CS2Dir\game\csgo\cfg\matchzy"
$AddonsRoot = "$CS2Dir\game\csgo\addons\counterstrikesharp"
New-Item -ItemType Directory -Force -Path $CfgDest | Out-Null

$serverCfg = "$ScriptDir\cfg\server.cfg"
if (Test-Path $serverCfg) {
    Copy-Item $serverCfg "$CS2Dir\game\csgo\cfg\server.cfg" -Force
    Write-Success "server.cfg copiado"
}

$adminsCfg = "$ScriptDir\cfg\admins.json"
if (Test-Path $adminsCfg) {
    New-Item -ItemType Directory -Force -Path "$AddonsRoot\configs" | Out-Null
    Copy-Item $adminsCfg "$AddonsRoot\configs\admins.json" -Force
    Write-Success "admins.json copiado"
}

$coreConfig = "$AddonsRoot\configs\core.json"
$coreExample = "$AddonsRoot\configs\core.example.json"
if ((Test-Path $coreExample) -and -not (Test-Path $coreConfig)) {
    Copy-Item $coreExample $coreConfig -Force
}
if (Test-Path $coreConfig) {
    $coreText = Get-Content $coreConfig -Raw
    $coreText = $coreText -replace '("FollowCS2ServerGuidelines"\s*:\s*)true', '${1}false'
    [System.IO.File]::WriteAllText($coreConfig, $coreText, (New-Object System.Text.UTF8Encoding($false)))
    Write-Success "Diretrizes do CounterStrikeSharp ajustadas para o WeaponPaints"
}

$matchzyCfg = "$ScriptDir\cfg\matchzy\matchzy.cfg"
if (Test-Path $matchzyCfg) {
    Copy-Item $matchzyCfg "$CfgDest\matchzy.cfg" -Force
    Write-Success "matchzy.cfg copiado"
}

# ─── Baixa Metamod + CounterStrikeSharp Windows ──────
$CSS_VERSION = "1.0.372"
$MMBuild     = "1410"
$CSS_URL     = "https://github.com/roflmuffin/CounterStrikeSharp/releases/download/v$CSS_VERSION/counterstrikesharp-with-runtime-windows-$CSS_VERSION.zip"
$METAMOD_URL = "https://github.com/alliedmodders/metamod-source/releases/download/2.0.0.$MMBuild/mmsource-2.0.0-git$MMBuild-windows.zip"
$CS2Addons   = "$CS2Dir\game\csgo\addons"
$MetamodDll  = "$CS2Addons\metamod\bin\win64\server.dll"
$CSSDll      = "$CS2Addons\counterstrikesharp\bin\win64\counterstrikesharp.dll"

if (-not (Test-Path $MetamodDll)) {
    Write-Info "Baixando Metamod:Source Windows (build $MMBuild)..."
    $zip = "$env:TEMP\metamod-win.zip"
    $tmp = "$env:TEMP\metamod-win-extract"
    Invoke-WebRequest -Uri $METAMOD_URL -OutFile $zip -UseBasicParsing
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    Remove-Item $zip
    Copy-Item "$tmp\addons\*" $CS2Addons -Recurse -Force
    Remove-Item $tmp -Recurse -Force
    Write-Success "Metamod instalado"
} else {
    Write-Success "Metamod já instalado"
}

if (-not (Test-Path $CSSDll)) {
    Write-Info "Baixando CounterStrikeSharp v$CSS_VERSION Windows (com runtime)..."
    $zip = "$env:TEMP\css-win.zip"
    $tmp = "$env:TEMP\css-win-extract"
    Invoke-WebRequest -Uri $CSS_URL -OutFile $zip -UseBasicParsing
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    Remove-Item $zip
    Copy-Item "$tmp\addons\*" $CS2Addons -Recurse -Force
    Remove-Item $tmp -Recurse -Force
    Write-Success "CounterStrikeSharp instalado"
} else {
    Write-Success "CounterStrikeSharp já instalado"
}

# ─── Helper: baixa plugin do NickFox007 ─────────────
function Install-NickFoxPlugin($name, $repo, $checkDll) {
    if (Test-Path $checkDll) {
        Write-Success "$name já instalado"
        return
    }
    Write-Info "Baixando $name..."
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/NickFox007/$repo/releases/latest" -UseBasicParsing
        $asset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
        if ($asset) {
            $zip = "$env:TEMP\$name.zip"
            $tmp = "$env:TEMP\$name-extract"
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip -UseBasicParsing
            if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
            Expand-Archive -Path $zip -DestinationPath $tmp -Force
            Remove-Item $zip
            New-Item -ItemType Directory -Force -Path "$AddonsRoot\plugins" | Out-Null
            if (Test-Path "$tmp\addons\counterstrikesharp\plugins") {
                Copy-Item "$tmp\addons\counterstrikesharp\plugins\*" "$AddonsRoot\plugins" -Recurse -Force
                if (Test-Path "$tmp\addons\counterstrikesharp\shared") {
                    New-Item -ItemType Directory -Force -Path "$AddonsRoot\shared" | Out-Null
                    Copy-Item "$tmp\addons\counterstrikesharp\shared\*" "$AddonsRoot\shared" -Recurse -Force
                }
            } else {
                Copy-Item "$tmp\*" "$AddonsRoot\plugins" -Recurse -Force
            }
            Remove-Item $tmp -Recurse -Force
            Write-Success "$name instalado"
        } else {
            Write-Warn "Nenhum asset .zip encontrado na release de $name"
        }
    } catch {
        Write-Warn "Não foi possível baixar $name`: $_"
        Write-Warn "Baixe manualmente em: https://github.com/NickFox007/$repo/releases"
    }
}

# ─── Baixa AnyBaseLib → PlayerSettings → MenuManager ────
Install-NickFoxPlugin "AnyBaseLib"    "AnyBaseLibCS2"     "$AddonsRoot\plugins\AnyBaseLib\AnyBaseLib.dll"
Install-NickFoxPlugin "PlayerSettings" "PlayerSettingsCS2" "$AddonsRoot\plugins\PlayerSettings\PlayerSettings.dll"

# ─── Baixa MenuManager ──────────────────────────────
Install-NickFoxPlugin "MenuManager" "MenuManagerCS2" "$AddonsRoot\plugins\MenuManagerCore\MenuManagerCore.dll"

# Copia configs do repo (vdf, gamedata, lang, api — sem sobrescrever bin/)
$AddonSource = "$ScriptDir\game\csgo\addons"
if (Test-Path $AddonSource) {
    Copy-Item "$AddonSource\*" $CS2Addons -Recurse -Force
    Write-Success "Configs de addons copiadas"
}

# ─── Copia plugins ───────────────────────────────────
$PluginsSrc  = "$ScriptDir\plugins"
$AddonsDest  = "$AddonsRoot\plugins"

$pluginFiles = Get-ChildItem -Path $PluginsSrc -Exclude ".gitkeep" -ErrorAction SilentlyContinue
if ($pluginFiles) {
    Write-Info "Copiando plugins..."
    New-Item -ItemType Directory -Force -Path $AddonsDest | Out-Null

    $matchzyRoot = "$PluginsSrc\MatchZy-0.8.15"
    if (Test-Path "$matchzyRoot\addons\counterstrikesharp\plugins") {
        Copy-Item "$matchzyRoot\addons\counterstrikesharp\plugins\*" $AddonsDest -Recurse -Force
        Copy-Item "$matchzyRoot\cfg\MatchZy" "$CS2Dir\game\csgo\cfg" -Recurse -Force
    }

    $retakesRoot = "$PluginsSrc\RetakesPlugin-3.1.0\addons\counterstrikesharp"
    if (Test-Path "$retakesRoot\plugins") {
        Copy-Item "$retakesRoot\plugins\*" $AddonsDest -Recurse -Force
    }
    if (Test-Path "$retakesRoot\shared") {
        New-Item -ItemType Directory -Force -Path "$AddonsRoot\shared" | Out-Null
        Copy-Item "$retakesRoot\shared\*" "$AddonsRoot\shared" -Recurse -Force
    }

    $deathmatchSrc = "$PluginsSrc\Deathmatch"
    if (Test-Path "$deathmatchSrc\Deathmatch.dll") {
        Copy-Item $deathmatchSrc "$AddonsDest\Deathmatch" -Recurse -Force
    }
    if (Test-Path "$deathmatchSrc\shared") {
        New-Item -ItemType Directory -Force -Path "$AddonsRoot\shared" | Out-Null
        Copy-Item "$deathmatchSrc\shared\*" "$AddonsRoot\shared" -Recurse -Force
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
    $weaponPaintsGamedataSrc = "$weaponPaintsSrc\gamedata"
    if (Test-Path $weaponPaintsGamedataSrc) {
        New-Item -ItemType Directory -Force -Path "$AddonsRoot\gamedata" | Out-Null
        Copy-Item "$weaponPaintsGamedataSrc\*" "$AddonsRoot\gamedata" -Recurse -Force
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
