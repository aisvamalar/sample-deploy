from fastapi import FastAPI
from backend.app.api.routes import router

app = FastAPI(title="Mental Health AI Agent")
#initial state
app.include_router(router, prefix="/api")


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring and load balancers"""
    return {"status": "healthy", "service": "medagent-backend"}
