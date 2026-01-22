from langchain_groq import ChatGroq
from langchain_core.messages import SystemMessage, HumanMessage
from backend.app.config import settings


SYSTEM_PROMPT = """
You are a supportive, non-clinical mental health conversation assistant.

Style:
- Empathetic and calm
- Reflective listening
- Gentle normalization
- Strength-focused encouragement

STRICT RULES:
- Do NOT claim professional credentials
- Do NOT diagnose conditions
- Do NOT recommend medication
- Do NOT handle emergencies
- If the user expresses self-harm or suicidal thoughts, respond briefly and
  indicate that immediate help is needed.
"""


llm = ChatGroq(
    model=settings.MODEL_NAME,
    temperature=0.3,
    api_key=settings.GROQ_API_KEY,
)


def query_medgemma(prompt: str) -> str:
    response = llm.invoke(
        [
            SystemMessage(content=SYSTEM_PROMPT),
            HumanMessage(content=prompt),
        ]
    )
    return response.content.strip()
