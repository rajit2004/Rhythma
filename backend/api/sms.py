from fastapi import APIRouter, Depends, HTTPException, status
from core.auth import get_current_user
from pydantic import BaseModel, Field
from datetime import datetime, timedelta, timezone
import os

# ─── Pydantic Model ──────────────────────────────────────────────────────────
class SMSRequest(BaseModel):
    phone_number: str = Field(..., pattern=r"^\+[1-9]\d{1,14}$")
    message: str


# ─── Rate Limiter (in-memory) ──────────────────────────────────────────────
sms_history = {}

def is_rate_limited(user_id: str, limit: int = 1, window_seconds: int = 60) -> bool:
    now = datetime.now(timezone.utc)
    if user_id in sms_history:
        sms_history[user_id] = [t for t in sms_history[user_id] if now - t < timedelta(seconds=window_seconds)]
    else:
        sms_history[user_id] = []

    if len(sms_history[user_id]) >= limit:
        return True

    sms_history[user_id].append(now)
    return False


# ─── Router ──────────────────────────────────────────────────────────────────
router = APIRouter(tags=["SMS"])

@router.post("/send-summary")
async def send_sms_summary(
    request: SMSRequest,
    current_user: dict = Depends(get_current_user)
):
    user_id = current_user["id"]

    # Rate limit check
    if is_rate_limited(user_id):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Rate limit exceeded. Please wait 60 seconds before sending another SMS."
        )

    # ─── Twilio Integration ──────────────────────────────────────────────────
    # Check if Twilio is installed
    try:
        from twilio.rest import Client
    except ImportError:
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="Twilio is not installed. Please install it with `pip install twilio`."
        )

    # Check if environment variables are set
    account_sid = os.getenv("TWILIO_ACCOUNT_SID")
    auth_token = os.getenv("TWILIO_AUTH_TOKEN")
    from_phone = os.getenv("TWILIO_PHONE_NUMBER")

    if not account_sid or not auth_token or not from_phone:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Twilio credentials are not configured. Please set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_PHONE_NUMBER in .env."
        )

    try:
        client = Client(account_sid, auth_token)
        message = client.messages.create(
            body=request.message,
            from_=from_phone,
            to=request.phone_number
        )
        return {"message": "SMS sent successfully", "sid": message.sid}

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send SMS: {str(e)}"
        )