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


EXPECTED_SKILLS = {
    "klima-provenance",
    "klima-code-review",
    "klima-simplification",
    "klima-spec",
    "klima-planning",
    "klima-mobile",
    "klima-backend",
    "klima-contracts",
    "klima-improvement",
}


def test_agent_docs_and_skills_exist():
    assert (ROOT / "AGENTS.md").is_file()
    skill_root = ROOT / ".cursor" / "skills"
    assert skill_root.is_dir()
    present = {p.name for p in skill_root.iterdir() if p.is_dir()}
    assert EXPECTED_SKILLS <= present
    for name in EXPECTED_SKILLS:
        assert (skill_root / name / "SKILL.md").is_file()


def test_skill_mirrors_stay_in_sync():
    """`.agents/skills/` mirrors `.cursor/skills/`; a stale copy misleads agents."""
    for name in EXPECTED_SKILLS:
        cursor = ROOT / ".cursor" / "skills" / name / "SKILL.md"
        agents = ROOT / ".agents" / "skills" / name / "SKILL.md"
        assert agents.is_file(), f".agents mirror missing for {name}"
        assert cursor.read_text() == agents.read_text(), f"{name} mirrors diverged"


def test_schema_package_is_the_contract_source():
    schema = ROOT / "schema"
    assert (schema / "pyproject.toml").is_file()
    assert (schema / "klima_schema" / "models.py").is_file()
    # The backend facade must not grow its own model definitions.
    facade = (ROOT / "backend" / "app" / "schemas" / "klima.py").read_text()
    assert "class " not in facade, "backend/app/schemas/klima.py must stay a re-export"
