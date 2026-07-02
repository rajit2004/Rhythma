from fastapi import APIRouter, Depends, HTTPException
from core.auth import get_current_user
import os
import google.generativeai as genai
from pydantic import BaseModel
from typing import List, Optional

# ─── Pydantic Models ──────────────────────────────────────────────────────────
# NOTE: This is the single source of truth for the /assistant/chat API contract.
# Request:  { "message": str, "language"?: str = "en", "history"?: [{role, content}] }
# Response: { "response": str, "language": str, "disclaimer": str }
# Each field is defined exactly once below — do not duplicate these models
# elsewhere. The Flutter app does not yet call this endpoint (it still talks to
# Gemini directly from `gemini_service.dart`); when that migration happens, it
# must consume this exact shape.
class ChatMessage(BaseModel):
    role: str
    content: str

class AssistantRequest(BaseModel):
    message: str
    language: Optional[str] = "en"
    history: Optional[List[ChatMessage]] = []

class AssistantResponse(BaseModel):
    response: str
    language: str
    disclaimer: str = "Please consult a healthcare professional for medical advice."


# ─── System Prompt ────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """
You are Rhythma, a compassionate and knowledgeable AI menstrual health companion designed specifically for women in India. Your purpose is to provide supportive, culturally sensitive, and medically responsible guidance on menstrual health, reproductive health, emotional well-being, and overall women's health.

Key guidelines:
- Always prioritize safety and remind users to consult a doctor for medical advice.
- Keep responses concise, empathetic, and easy to understand.
- Use simple English or the user's preferred Indian language.
- Be non-judgmental and encouraging.
- Do not provide medical diagnoses – encourage professional consultation.
- Never prescribe medication.
- If you don't know something, say so honestly.
- Always end responses that involve symptoms or health concerns with a gentle reminder to consult a healthcare professional.
"""


# ─── Router ──────────────────────────────────────────────────────────────────
router = APIRouter(tags=["AI Assistant"])

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))


@router.post("/chat", response_model=AssistantResponse)
async def chat(
    request: AssistantRequest,
    current_user: dict = Depends(get_current_user)
):
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty.")

    prompt_parts = []
    prompt_parts.append(f"System: {SYSTEM_PROMPT}")
    prompt_parts.append(f"Language: Respond in {request.language}.")
    prompt_parts.append("\n--- Conversation History ---")

    if request.history:
        for msg in request.history[-10:]:
            if msg.role == "user":
                prompt_parts.append(f"User: {msg.content}")
            elif msg.role == "model":
                prompt_parts.append(f"Assistant: {msg.content}")
    else:
        prompt_parts.append("(No previous messages)")

    prompt_parts.append("\n--- Current Message ---")
    prompt_parts.append(f"User: {request.message}")
    prompt_parts.append("Assistant:")

    full_prompt = "\n".join(prompt_parts)

    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        gemini_result = model.generate_content(
            full_prompt,
            system_instruction=SYSTEM_PROMPT
        )
        reply_text = gemini_result.text.strip() if gemini_result.text else "I'm sorry, I couldn't process that."

        # `response` is the only field name the client should ever see for the
        # assistant's reply text — keep it consistent with AssistantResponse above.
        return AssistantResponse(
            response=reply_text,
            language=request.language,
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini API error: {str(e)}")


@router.get("/languages")
async def supported_languages(current_user: dict = Depends(get_current_user)):
    return [
        {"code": "en", "name": "English"},
        {"code": "hi", "name": "हिन्दी (Hindi)"},
        {"code": "mr", "name": "मराठी (Marathi)"},
        {"code": "ta", "name": "தமிழ் (Tamil)"},
        {"code": "te", "name": "తెలుగు (Telugu)"},
        {"code": "kn", "name": "ಕನ್ನಡ (Kannada)"},
        {"code": "ml", "name": "മലയാളം (Malayalam)"},
        {"code": "bn", "name": "বাংলা (Bengali)"},
    ]