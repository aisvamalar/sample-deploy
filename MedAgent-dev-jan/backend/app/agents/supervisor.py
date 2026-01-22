from langchain.tools import tool
from langchain_groq import ChatGroq
from langgraph.prebuilt import create_react_agent

from backend.app.tools.therapy import query_medgemma
from backend.app.tools.emergency import call_emergency
from backend.app.agents.prompts import SYSTEM_PROMPT
from backend.app.config import settings


@tool
def ask_mental_health_specialist(query: str) -> str:
    """
    Provide empathetic, non-clinical emotional support.
    Use this tool for general mental health concerns such as stress,
    anxiety, sadness, or emotional overwhelm.
    """
    return query_medgemma(query)


@tool
def emergency_call_tool(reason: str = "user at risk") -> str:
    """
    Trigger emergency escalation when the user expresses suicidal ideation,
    self-harm intent, or immediate danger.
    """
    call_emergency()
    return "Emergency escalation initiated."


tools = [ask_mental_health_specialist, emergency_call_tool]

llm = ChatGroq(
    model=settings.MODEL_NAME,
    temperature=settings.TEMPERATURE,
    api_key=settings.GROQ_API_KEY,
)

graph = create_react_agent(
    model=llm,
    tools=tools,
)
