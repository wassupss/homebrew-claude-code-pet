#!/usr/bin/env python3
"""claude-pet hook installer. Usage: setup-hooks.py [install|uninstall]"""
import json, pathlib, sys

CFG    = pathlib.Path.home() / ".claude" / "settings.json"
MARKER = "claude-pet"

HOOK_ENTRIES = {
    "SessionStart": {"type": "command", "command": "claude-pet _hook session_start"},
    "PostToolUse":  {"type": "command", "command": "claude-pet _hook tool_use"},
}

# Old hook patterns to remove during migration (absolute-path installs)
OLD_PATTERNS = ["pet.py _hook"]


def load():
    return json.loads(CFG.read_text()) if CFG.exists() else {}


def save(cfg):
    CFG.parent.mkdir(parents=True, exist_ok=True)
    CFG.write_text(json.dumps(cfg, ensure_ascii=False, indent=2))


def _has_marker(h: dict) -> bool:
    return MARKER in str(h)


def _is_old(h: dict) -> bool:
    s = str(h)
    return any(p in s for p in OLD_PATTERNS)


def install():
    cfg  = load()
    hooks = cfg.setdefault("hooks", {})
    changed = False

    for event, entry in HOOK_ENTRIES.items():
        existing = hooks.get(event, [])

        # Remove old absolute-path hooks (migration)
        cleaned = [h for h in existing if not _is_old(h)]
        if len(cleaned) != len(existing):
            changed = True

        # Skip if already installed
        if any(_has_marker(h) for h in cleaned):
            hooks[event] = cleaned
            continue

        hooks[event] = cleaned + [{"hooks": [entry]}]
        changed = True

    if changed:
        save(cfg)
        print("✓ claude-pet hooks installed (~/.claude/settings.json)")
    else:
        print("✓ claude-pet hooks already present, skipped")


def uninstall():
    if not CFG.exists():
        return
    cfg  = load()
    hooks = cfg.get("hooks", {})
    for event in list(hooks.keys()):
        hooks[event] = [h for h in hooks[event]
                        if not _has_marker(h) and not _is_old(h)]
        if not hooks[event]:
            del hooks[event]
    save(cfg)
    print("✓ claude-pet hooks removed")


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "install"
    {"install": install, "uninstall": uninstall}.get(action, install)()
