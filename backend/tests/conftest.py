"""Shared fixtures for backend API tests."""

from __future__ import annotations

import os
from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def sqlite_file(tmp_path_factory: pytest.TempPathFactory) -> Path:
    path = tmp_path_factory.mktemp("db") / "test-klima.db"
    os.environ["SQLITE_FILE"] = str(path)
    os.environ["LOG_LEVEL"] = "ERROR"
    os.environ["DB_ACTIVE"] = "sqlite"
    return path


@pytest.fixture(scope="session")
def app(sqlite_file: Path):
    # Import only after SQLITE_FILE is set so Database binds to the temp file.
    from app.main import app as fastapi_app

    return fastapi_app


@pytest.fixture()
def client(app):
    from fastapi.testclient import TestClient

    with TestClient(app) as test_client:
        yield test_client
