

# Mental Health AI Agent

**Agentic Conversational System using LangGraph, ChatGroq, FastAPI, and Streamlit**

---

## Overview

This project implements a **safety-oriented, agent-based conversational AI system** for mental health support.
It demonstrates modern **agentic AI design** using a **LangGraph ReAct agent** powered by **ChatGroq (LLaMA-3.3-70B)**, with clearly scoped tools for supportive dialogue and emergency escalation.

The system is accessible through:

* a **Command-Line Interface (CLI)** for development and debugging,
* a **FastAPI backend** for programmatic access,
* an **optional Streamlit web interface** for interactive demonstrations.

The project emphasizes **clean architecture**, **separation of concerns**, and **production-ready Python practices**.

---

## Disclaimer

This system is **not a medical or clinical product**.
It does **not provide diagnosis, treatment, or medical advice** and must not be used as a substitute for professional mental health care.

Emergency handling is illustrative and must be integrated with verified crisis-response services before any real-world deployment.

---

## Objectives

* Demonstrate agentic AI workflows with explicit reasoning and tool usage
* Enforce safety through tool-based execution boundaries
* Provide multiple interfaces (CLI, API, UI) over a single agent core
* Maintain modular, testable, and extensible code structure
* Follow best practices for modern Python backend development

---

## High-Level Architecture

```
User (CLI / Streamlit / API Client)
            |
            v
FastAPI Backend
            |
            v
LangGraph ReAct Agent (ChatGroq)
            |
            v
Tool Invocation Layer
 ├─ Mental Health Support Tool
 └─ Emergency Escalation Tool
            |
            v
Structured Response
```

**Core principle:**
Large Language Models perform reasoning and decision-making; tools perform actions.

---

## Technology Stack

* **Python 3.10+**
* **LangGraph** – Agent orchestration
* **LangChain Core** – Tool abstraction
* **ChatGroq** – LLM inference (LLaMA-3.3-70B)
* **FastAPI** – Backend API
* **Streamlit** – Web-based UI
* **python-dotenv** – Environment configuration

---

## Project Structure

```
mental_health_twilio/
│
├── backend/
│   ├── __init__.py
│   └── app/
│       ├── __init__.py
│       ├── main.py                # FastAPI entrypoint
│       ├── cli.py                 # CLI interface
│       ├── config.py              # Environment configuration
│       │
│       ├── agents/
│       │   ├── __init__.py
│       │   ├── supervisor.py      # LangGraph agent definition
│       │   └── prompts.py         # System prompts and policies
│       │
│       ├── tools/
│       │   ├── __init__.py
│       │   ├── therapy.py         # Supportive response tool
│       │   └── emergency.py       # Emergency escalation hook
│       │
│       ├── services/
│       │   ├── __init__.py
│       │   └── orchestration.py   # Stream parsing utilities
│       │
│       └── api/
│           ├── __init__.py
│           ├── routes.py          # API routes
│           └── schemas.py         # Pydantic models
│
├── frontend/
│   └── streamlit_app.py           # Streamlit UI
│
├── .env.example
├── requirements.txt
└── README.md
```

---

## Installation

### 1. Create and Activate Virtual Environment

```bash
python -m venv .venv
```

**Windows**

```powershell
.\.venv\Scripts\Activate.ps1
```

**macOS / Linux**

```bash
source .venv/bin/activate
```

---

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

Example `requirements.txt`:

```txt
fastapi
uvicorn
langchain>=0.1.16
langchain-core>=0.1.33
langgraph>=0.0.30
langchain-groq
python-dotenv
streamlit
requests
```

---

## Environment Configuration

Create a `.env` file in the project root:

```env
GROQ_API_KEY=your_groq_api_key

```



---

## Running the Application

### 1. Command-Line Interface (CLI)

The CLI is useful for local testing and inspecting agent behavior.

```bash
python -m backend.app.cli
```

---

### 2. FastAPI Backend

Start the API server:

```bash
uvicorn backend.app.main:app --reload
```

The API will be available at:

```
http://localhost:8000
```

#### Example Request

```http
POST /ask
Content-Type: application/json

{
  "message": "I feel anxious lately"
}
```

#### Example Response

```json
{
  "response": "I can sense how challenging this anxiety has been for you...",
  "tool_called": "ask_mental_health_specialist"
}
```

---

### 3. Streamlit Web Interface

The Streamlit UI provides a browser-based conversational interface.

#### Step 1: Ensure Backend Is Running

```bash
uvicorn backend.app.main:app --reload
```

#### Step 2: Start Streamlit

```bash
streamlit run frontend/streamlit_app.py
```

Streamlit will open in the browser (typically at `http://localhost:8501`).

---


## Agent Design

### Supervisor Agent

* Implements ReAct-style reasoning using LangGraph
* Selects tools based on user intent
* Does not execute side effects directly

### Tools

| Tool                       | Responsibility                               |
| -------------------------- | -------------------------------------------- |
| Mental Health Support Tool | Generates empathetic, non-clinical responses |
| Emergency Escalation Tool  | Handles crisis escalation logic              |

All tools:

* Are explicitly documented
* Are isolated from reasoning logic
* Are independently testable

---
