import os
from dotenv import load_dotenv

load_dotenv()


def _require_env(var_name: str) -> str:
    value = os.getenv(var_name)
    if not value:
        raise RuntimeError(f"Missing required environment variable: {var_name}")
    return value


class Settings:
    GROQ_API_KEY: str = _require_env("GROQ_API_KEY")

    MODEL_NAME: str = os.getenv(
        "MODEL_NAME", "openai/gpt-oss-120b"
    )
    TEMPERATURE: float = float(
        os.getenv("TEMPERATURE", "0.3")
    )


settings = Settings()
