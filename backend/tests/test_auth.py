"""
Tests covering JWT authentication, protected endpoints, and SMS rate
limiting for the Rhythma backend.

Run with: pytest backend/tests/test_auth.py -v
"""
from unittest.mock import patch, MagicMock

import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)

VALID_USER = {"username": "testuser", "password": "password123"}


def get_token() -> str:
    """Helper: log in with the seeded test user and return a bearer token."""
    response = client.post("/api/v1/auth/token", data=VALID_USER)
    assert response.status_code == 200
    return response.json()["access_token"]


# ─── JWT Authentication ────────────────────────────────────────────────────
def test_login_success():
    response = client.post("/api/v1/auth/token", data=VALID_USER)
    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body
    assert body["token_type"] == "bearer"


def test_login_failure_wrong_password():
    response = client.post(
        "/api/v1/auth/token",
        data={"username": "testuser", "password": "wrongpassword"},
    )
    assert response.status_code == 401
    assert "detail" in response.json()


def test_login_failure_unknown_user():
    response = client.post(
        "/api/v1/auth/token",
        data={"username": "nobody", "password": "whatever"},
    )
    assert response.status_code == 401


# ─── Protected Endpoints ───────────────────────────────────────────────────
def test_health_check_is_public():
    """Health check is intentionally unauthenticated so uptime monitors work."""
    response = client.get("/api/v1/health/")
    assert response.status_code == 200


def test_protected_endpoint_without_token():
    # /cycle, /insights, /sms, and /assistant all require a bearer token.
    response = client.get("/api/v1/insights/testuser/scores")
    assert response.status_code == 401


def test_protected_endpoint_with_invalid_token():
    headers = {"Authorization": "Bearer not-a-real-token"}
    response = client.get("/api/v1/insights/testuser/scores", headers=headers)
    assert response.status_code == 401


def test_protected_endpoint_with_valid_token():
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/v1/insights/testuser/scores", headers=headers)
    assert response.status_code == 200


def test_protected_endpoint_rejects_cross_user_access():
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/v1/insights/someone-else/scores", headers=headers)
    assert response.status_code == 403


def test_cycle_log_requires_auth():
    payload = {"start_date": "2026-01-01"}
    response = client.post("/api/v1/cycle/log", json=payload)
    assert response.status_code == 401


def test_cycle_log_with_valid_token():
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    payload = {"start_date": "2026-01-01"}
    response = client.post("/api/v1/cycle/log", json=payload, headers=headers)
    assert response.status_code == 200


# ─── SMS Rate Limiting ─────────────────────────────────────────────────────
@pytest.fixture(autouse=True)
def _reset_sms_rate_limit_state():
    """Each SMS test gets a clean in-memory rate-limit window."""
    from api import sms as sms_module
    sms_module.sms_history.clear()
    yield
    sms_module.sms_history.clear()


@patch("twilio.rest.Client")
def test_sms_rate_limiting(mock_twilio_client, monkeypatch):
    # Deterministic env + mocked Twilio so this test doesn't depend on real
    # credentials or network access.
    monkeypatch.setenv("TWILIO_ACCOUNT_SID", "test_sid")
    monkeypatch.setenv("TWILIO_AUTH_TOKEN", "test_token")
    monkeypatch.setenv("TWILIO_PHONE_NUMBER", "+10000000000")

    mock_instance = MagicMock()
    mock_instance.messages.create.return_value = MagicMock(sid="SM_test_sid")
    mock_twilio_client.return_value = mock_instance

    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    payload = {"phone_number": "+1234567890", "message": "Test"}

    # First request in the window succeeds.
    response1 = client.post("/api/v1/sms/send-summary", json=payload, headers=headers)
    assert response1.status_code == 200
    assert response1.json()["sid"] == "SM_test_sid"

    # Second request within the same 60s window is rate limited.
    response2 = client.post("/api/v1/sms/send-summary", json=payload, headers=headers)
    assert response2.status_code == 429


def test_sms_requires_auth():
    payload = {"phone_number": "+1234567890", "message": "Test"}
    response = client.post("/api/v1/sms/send-summary", json=payload)
    assert response.status_code == 401