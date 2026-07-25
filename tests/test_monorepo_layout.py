"""Root layout checks — provenance dirs from the five source repos must exist."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_TOP_LEVEL = ("backend", "frontend", "data", "mobile", "docs")


def test_flat_monorepo_directories_exist():
    missing = [name for name in REQUIRED_TOP_LEVEL if not (ROOT / name).is_dir()]
    assert missing == [], f"missing top-level dirs: {missing}"


def test_backend_is_fastapi_package():
    assert (ROOT / "backend" / "pyproject.toml").is_file()
    assert (ROOT / "backend" / "app" / "main.py").is_file()


def test_mobile_is_flutter_package():
    assert (ROOT / "mobile" / "pubspec.yaml").is_file()
    assert (ROOT / "mobile" / "lib" / "main.dart").is_file()


def test_frontend_data_docs_are_present_even_if_sparse():
    for name in ("frontend", "data", "docs"):
        assert (ROOT / name / ".gitignore").is_file(), f"{name}/.gitignore missing"


def test_agent_docs_and_skills_exist():
    assert (ROOT / "AGENTS.md").is_file()
    skill_root = ROOT / ".cursor" / "skills"
    assert skill_root.is_dir()
    expected = {
        "klima-provenance",
        "klima-code-review",
        "klima-simplification",
        "klima-spec",
        "klima-planning",
        "klima-mobile",
        "klima-improvement",
    }
    present = {p.name for p in skill_root.iterdir() if p.is_dir()}
    assert expected <= present
    for name in expected:
        assert (skill_root / name / "SKILL.md").is_file()
