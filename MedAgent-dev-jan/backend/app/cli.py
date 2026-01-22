from backend.app.agents.supervisor import graph
from backend.app.agents.prompts import SYSTEM_PROMPT
from backend.app.services.orchestration import parse_response


def run_cli():
    print("🧠 Mental Health AI Agent (CLI Mode)")
    print("Type 'exit' or 'quit' to stop.\n")

    messages = [("system", SYSTEM_PROMPT)]

    try:
        while True:
            user_input = input("User: ").strip()

            if user_input.lower() in {"exit", "quit"}:
                print("Goodbye 👋")
                break

            messages.append(("user", user_input))

            stream = graph.stream(
                {"messages": messages},
                stream_mode="updates",
            )

            tool_called, response, escalated = parse_response(stream)

            messages.append(("assistant", response))

            print("\nTOOL CALLED:", tool_called)
            print("ANSWER:", response)
            print("-" * 60)

    except KeyboardInterrupt:
        print("\nSession terminated safely.")


if __name__ == "__main__":
    run_cli()
