from pydantic import BaseModel

class Query(BaseModel):
    message: str

class AgentResponse(BaseModel):
    response: str
    escalated: bool