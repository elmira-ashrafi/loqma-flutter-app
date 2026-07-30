# Generates assets/terms/en.json, fa.json, ps.json from trilingual tables.
# Run: python tool/generate_terms_assets.py (from package root)

from __future__ import annotations

import json
import sys
from pathlib import Path

_TOOL_DIR = Path(__file__).resolve().parent
if str(_TOOL_DIR) not in sys.path:
    sys.path.insert(0, str(_TOOL_DIR))

from terms_locale_tables import build_sections  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "terms"


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for idx, name in enumerate(("en", "fa", "ps")):
        payload = {"version": 1, "sections": build_sections(idx)}
        (OUT / f"{name}.json").write_text(
            json.dumps(payload, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
    print(f"Wrote {OUT} (en, fa, ps)")


if __name__ == "__main__":
    main()
