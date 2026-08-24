import json
import os
import stat
from pathlib import Path


DEFAULT_CONFIG = (
    Path.home()
    / "cs2server"
    / "game"
    / "csgo"
    / "addons"
    / "counterstrikesharp"
    / "configs"
    / "plugins"
    / "WeaponPaints"
    / "WeaponPaints.json"
)


def main() -> None:
    config_path = Path(os.environ.get("WEAPONPAINTS_CONFIG", DEFAULT_CONFIG))
    required = {
        "DatabaseHost": os.environ.get("DB_HOST", ""),
        "DatabasePort": int(os.environ.get("DB_PORT", "3306")),
        "DatabaseUser": os.environ.get("DB_USER", ""),
        "DatabasePassword": os.environ.get("DB_PASSWORD", ""),
        "DatabaseName": os.environ.get("DB_NAME", ""),
    }
    missing = [key for key, value in required.items() if not value]
    if missing:
        raise SystemExit(f"Variáveis ausentes: {', '.join(missing)}")

    config_path.parent.mkdir(parents=True, exist_ok=True)
    if config_path.exists():
        # Remove linhas de comentário // que o CounterStrikeSharp adiciona
        raw = "\n".join(
            line for line in config_path.read_text(encoding="utf-8").splitlines()
            if not line.strip().startswith("//")
        )
        config = json.loads(raw)
    else:
        config = {"ConfigVersion": 10, "SkinsLanguage": "en"}

    config.update(required)
    temporary_path = config_path.with_suffix(".tmp")
    temporary_path.write_text(
        json.dumps(config, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary_path.replace(config_path)

    if os.name != "nt":
        config_path.chmod(stat.S_IRUSR | stat.S_IWUSR)

    print(f"WeaponPaints configurado em {config_path}")


if __name__ == "__main__":
    main()
