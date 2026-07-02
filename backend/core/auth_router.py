from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
from core.auth import (
    create_access_token,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    get_password_hash,
    verify_password,
)
from utils.logger import logger

# ════════════════════════════════════════════════════════════════════════════
# ⚠️  TEMPORARY — DEVELOPMENT ONLY  ⚠️
# `fake_users_db` is an in-memory placeholder so JWT auth can be exercised
# end-to-end before real user storage exists. It is NOT persisted, NOT secure
# for multiple real users, and MUST be replaced with a real database-backed
# user store (Firestore / Postgres / etc.) before this ships to production.
# Tracked as follow-up work — do not build additional features on top of this
# without replacing it first.
# ════════════════════════════════════════════════════════════════════════════
logger.warning(
    "core.auth_router is using a TEMPORARY in-memory fake_users_db. "
    "Replace with real user storage before production."
)

fake_users_db = {
    "testuser": {
        "username": "testuser",
        "full_name": "Test User",
        "email": "test@example.com",
        "hashed_password": get_password_hash("password123"),
        "disabled": False,
    }
}

router = APIRouter(tags=["Authentication"])

@router.post("/token")
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = fake_users_db.get(form_data.username)
    if not user or not verify_password(form_data.password, user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}