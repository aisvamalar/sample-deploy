from typing import Optional, Tuple


def parse_response(stream) -> Tuple[Optional[str], str, bool]:
    """
    Returns:
      tool_name: name of the tool invoked (if any)
      response: final assistant message
      escalated: whether emergency escalation occurred
    """

    tool_name = None
    response_parts = []
    escalated = False

    for event in stream:
        # Tool execution
        if "tools" in event:
            for msg in event["tools"].get("messages", []):
                name = getattr(msg, "name", None)
                if name:
                    tool_name = name
                    if name == "emergency_call_tool":
                        escalated = True

        # Agent output
        if "agent" in event:
            for msg in event["agent"].get("messages", []):
                if msg.content:
                    response_parts.append(msg.content)

    final_response = response_parts[-1] if response_parts else ""

    return tool_name, final_response, escalated
