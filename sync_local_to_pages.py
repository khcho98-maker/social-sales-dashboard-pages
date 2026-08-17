from __future__ import annotations

import json
import shutil
from datetime import datetime
from pathlib import Path


PAGES_DIR = Path(__file__).resolve().parent
PROJECT_DIR = PAGES_DIR.parent
DRAFTS_PATH = PROJECT_DIR / "drafts.json"
SOURCE_ASSETS_DIR = PROJECT_DIR / "assets"
TARGET_ASSETS_DIR = PAGES_DIR / "assets"
PREVIEW_DATA_PATH = PAGES_DIR / "preview-data.js"

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp", ".gif"}


def read_drafts() -> list[dict[str, object]]:
    if not DRAFTS_PATH.exists():
        return []
    data = json.loads(DRAFTS_PATH.read_text(encoding="utf-8"))
    return data if isinstance(data, list) else []


def iter_image_values(value: object):
    if isinstance(value, dict):
        for item in value.values():
            yield from iter_image_values(item)
    elif isinstance(value, list):
        for item in value:
            yield from iter_image_values(item)
    elif isinstance(value, str):
        suffix = Path(value).suffix.lower()
        if suffix in IMAGE_EXTS:
            yield value


def source_image_path(raw_path: str) -> Path | None:
    candidate = Path(raw_path)
    if candidate.exists():
        return candidate
    by_name = SOURCE_ASSETS_DIR / candidate.name
    if by_name.exists():
        return by_name
    project_relative = PROJECT_DIR / raw_path
    if project_relative.exists():
        return project_relative
    return None


def reset_target_assets() -> None:
    resolved_pages = PAGES_DIR.resolve()
    resolved_assets = TARGET_ASSETS_DIR.resolve()
    if TARGET_ASSETS_DIR.exists():
        if resolved_pages not in resolved_assets.parents:
            raise RuntimeError(f"Refusing to remove unexpected directory: {resolved_assets}")
        shutil.rmtree(TARGET_ASSETS_DIR)
    TARGET_ASSETS_DIR.mkdir(parents=True, exist_ok=True)


def copy_assets(drafts: list[dict[str, object]]) -> list[str]:
    reset_target_assets()
    copied: list[str] = []
    seen: set[str] = set()
    for raw_path in iter_image_values(drafts):
        source = source_image_path(raw_path)
        if not source:
            continue
        target_name = source.name
        if target_name in seen:
            continue
        shutil.copy2(source, TARGET_ASSETS_DIR / target_name)
        copied.append(target_name)
        seen.add(target_name)
    return copied


def main() -> None:
    drafts = read_drafts()
    copied_assets = copy_assets(drafts)
    payload = {
        "synced_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "source": str(DRAFTS_PATH),
        "draft_count": len(drafts),
        "asset_count": len(copied_assets),
        "assets": copied_assets,
        "runs": [],
        "drafts": drafts,
    }
    PREVIEW_DATA_PATH.write_text(
        "window.SOCIAL_SALES_PREVIEW_DATA = "
        + json.dumps(payload, ensure_ascii=False, indent=2)
        + ";\n",
        encoding="utf-8",
    )
    print(f"synced {len(drafts)} drafts and {len(copied_assets)} assets")


if __name__ == "__main__":
    main()
