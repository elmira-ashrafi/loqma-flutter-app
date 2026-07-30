# Generates assets/privacy/en.json, fa.json, ps.json from trilingual tables.
# Run from package root: python tool/generate_privacy_assets.py

from __future__ import annotations

import json
import sys
from pathlib import Path

# Allow `import privacy_locale_tables` when run as `python tool/generate_privacy_assets.py`
_TOOL_DIR = Path(__file__).resolve().parent
if str(_TOOL_DIR) not in sys.path:
    sys.path.insert(0, str(_TOOL_DIR))

from privacy_locale_tables import (  # noqa: E402
    COLLECT_TITLE,
    CONTACT_EMAIL,
    CONTACT_PARA,
    CONTACT_PHONE,
    CONTACT_TEAM,
    CONTACT_TITLE,
    INTRO_PARAS,
    INTRO_TITLE,
    RETENTION_CARDS,
    RETENTION_TITLE,
    RIGHTS_CARDS,
    RIGHTS_FOOTER,
    RIGHTS_TITLE,
    SECURITY_BULLETS,
    SECURITY_INTRO,
    SECURITY_TITLE,
    SUBSECTIONS,
    USE_CASES,
    USE_TITLE,
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "privacy"

Tri = tuple[str, str, str]


def pick(tri: Tri, lang_idx: int) -> str:
    return tri[lang_idx]


def build_sections(lang_idx: int) -> list[dict]:
    intro = {
        "id": "intro",
        "title": pick(INTRO_TITLE, lang_idx),
        "paragraphs": [pick(p, lang_idx) for p in INTRO_PARAS],
    }

    subsections: list[dict] = []
    for accent, title_tri, intro_tri, bullets in SUBSECTIONS:
        sub: dict = {
            "title": pick(title_tri, lang_idx),
            "accent": accent,
            "bullets": [
                {"title": pick(bt[0], lang_idx), "purpose": pick(bt[1], lang_idx)}
                for bt in bullets
            ],
        }
        if intro_tri is not None:
            sub["intro"] = pick(intro_tri, lang_idx)
        subsections.append(sub)

    collect = {
        "id": "collect",
        "title": pick(COLLECT_TITLE, lang_idx),
        "subsections": subsections,
    }

    use_sec = {
        "id": "use",
        "title": pick(USE_TITLE, lang_idx),
        "useCases": [
            {"title": pick(title_tri, lang_idx), "description": pick(desc_tri, lang_idx)}
            for title_tri, desc_tri in USE_CASES
        ],
    }

    security = {
        "id": "security",
        "title": pick(SECURITY_TITLE, lang_idx),
        "paragraphs": [pick(SECURITY_INTRO, lang_idx)],
        "securityBullets": [pick(b, lang_idx) for b in SECURITY_BULLETS],
    }

    retention = {
        "id": "retention",
        "title": pick(RETENTION_TITLE, lang_idx),
        "retentionCards": [
            {"title": pick(title_tri, lang_idx), "body": pick(body_tri, lang_idx)}
            for title_tri, body_tri in RETENTION_CARDS
        ],
    }

    rights = {
        "id": "rights",
        "title": pick(RIGHTS_TITLE, lang_idx),
        "rightsCards": [
            {"title": pick(title_tri, lang_idx), "body": pick(body_tri, lang_idx)}
            for title_tri, body_tri in RIGHTS_CARDS
        ],
        "footer": pick(RIGHTS_FOOTER, lang_idx),
    }

    contact = {
        "id": "contact",
        "title": pick(CONTACT_TITLE, lang_idx),
        "paragraphs": [pick(CONTACT_PARA, lang_idx)],
        "contactTeam": pick(CONTACT_TEAM, lang_idx),
        "contactEmail": CONTACT_EMAIL,
        "contactPhone": CONTACT_PHONE,
    }

    return [intro, collect, use_sec, security, retention, rights, contact]


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for idx, name in enumerate(("en", "fa", "ps")):
        payload = {"version": 1, "sections": build_sections(idx)}
        text = json.dumps(payload, ensure_ascii=False, indent=2)
        (OUT / f"{name}.json").write_text(text, encoding="utf-8")
    print(f"Wrote localized privacy JSON to {OUT} (en, fa, ps)")


if __name__ == "__main__":
    main()
