import streamlit as st
import requests
import os

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000/api/ask")

st.set_page_config(page_title="SafeSpace", page_icon="🧠")

st.title("🧠 SafeSpace – Mental Health Support Assistant")
st.caption(
    "This AI provides supportive conversation only. "
    "It is not a therapist and does not provide medical advice."
)

if "chat" not in st.session_state:
    st.session_state.chat = []

msg = st.chat_input("What's on your mind?")
if msg:
    st.session_state.chat.append(("user", msg))

    try:
        res = requests.post(
            BACKEND_URL,
            json={"message": msg},
            timeout=10,
        )
        res.raise_for_status()
        data = res.json()

        st.session_state.chat.append(("assistant", data["response"]))

        if data.get("escalated"):
            st.error(
                "⚠️ If you're feeling unsafe, please contact your local emergency "
                "number or a trusted person immediately."
            )

    except requests.RequestException:
        st.error("Unable to reach support service. Please try again later.")

for role, text in st.session_state.chat:
    with st.chat_message(role):
        st.write(text)
