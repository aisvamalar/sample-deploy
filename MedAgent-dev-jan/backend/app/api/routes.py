from fastapi import APIRouter, HTTPException
from backend.app.api.schemas import Query,AgentResponse
from backend.app.agents.supervisor import graph
from backend.app.services.orchestration import parse_response

router = APIRouter()


@router.post("/ask", response_model=AgentResponse)
async def ask(query: Query):
    try:
        stream = graph.stream(
            {"messages": [("user", query.message)]},
            stream_mode="updates",
        )

        tool, response, escalated = parse_response(stream)

        return AgentResponse(
            response=response,
            tool_called=tool,
            escalated=escalated,
        )

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail="Internal agent error",
        )
