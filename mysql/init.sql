-- ═══════════════════════════════════════════════════════
--   CS2 Server - Inicialização do Banco de Dados
-- ═══════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS cs2server CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cs2server;

-- ─── Tabela de skins (WeaponPaints) ──────────────────
CREATE TABLE IF NOT EXISTS wp_player_skins (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  steamid       VARCHAR(32)     NOT NULL,
  weapon_defindex INT           NOT NULL DEFAULT 0,
  weapon_paint_id INT           NOT NULL DEFAULT 0,
  weapon_wear   FLOAT           NOT NULL DEFAULT 0.0,
  weapon_seed   INT             NOT NULL DEFAULT 0,
  weapon_nametag VARCHAR(255)   NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  UNIQUE KEY uq_player_weapon (steamid, weapon_defindex)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Tabela de facas (WeaponPaints) ──────────────────
CREATE TABLE IF NOT EXISTS wp_player_knife (
  steamid   VARCHAR(32)  NOT NULL,
  knife     VARCHAR(64)  NOT NULL DEFAULT 'weapon_knife',
  PRIMARY KEY (steamid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Tabela de luvas (WeaponPaints) ──────────────────
CREATE TABLE IF NOT EXISTS wp_player_gloves (
  steamid   VARCHAR(32)  NOT NULL,
  glove     INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (steamid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Tabela de agentes (WeaponPaints) ────────────────
CREATE TABLE IF NOT EXISTS wp_player_agents (
  steamid         VARCHAR(32) NOT NULL,
  agent_ct        VARCHAR(64) NOT NULL DEFAULT '',
  agent_t         VARCHAR(64) NOT NULL DEFAULT '',
  PRIMARY KEY (steamid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Tabela de músicas (WeaponPaints) ────────────────
CREATE TABLE IF NOT EXISTS wp_player_music (
  steamid   VARCHAR(32) NOT NULL,
  music_id  INT         NOT NULL DEFAULT 0,
  PRIMARY KEY (steamid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Tabela de partidas (MatchZy) ────────────────────
CREATE TABLE IF NOT EXISTS matchzy_stats (
  matchid       VARCHAR(64)  NOT NULL,
  mapnumber     INT          NOT NULL DEFAULT 0,
  team1_name    VARCHAR(128) NOT NULL DEFAULT '',
  team2_name    VARCHAR(128) NOT NULL DEFAULT '',
  team1_score   INT          NOT NULL DEFAULT 0,
  team2_score   INT          NOT NULL DEFAULT 0,
  winner        VARCHAR(128) NOT NULL DEFAULT '',
  end_time      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (matchid, mapnumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Tabela de stats de jogadores (MatchZy) ──────────
CREATE TABLE IF NOT EXISTS matchzy_player_stats (
  matchid     VARCHAR(64)  NOT NULL,
  mapnumber   INT          NOT NULL DEFAULT 0,
  steamid64   VARCHAR(32)  NOT NULL,
  name        VARCHAR(128) NOT NULL DEFAULT '',
  team        VARCHAR(128) NOT NULL DEFAULT '',
  kills       INT          NOT NULL DEFAULT 0,
  deaths      INT          NOT NULL DEFAULT 0,
  assists     INT          NOT NULL DEFAULT 0,
  adr         FLOAT        NOT NULL DEFAULT 0,
  hs_kills    INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (matchid, mapnumber, steamid64)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SELECT 'Banco de dados inicializado com sucesso!' AS status;
