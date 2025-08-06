import streamlit as st
import subprocess
import requests
import time
import os

OLLAMA_MODEL = "llama2"
OLLAMA_URL = "http://localhost:11434/api/generate"

def pull_ollama_model():
    try:
        st.info(f"🔄 Pulling pristine model: {OLLAMA_MODEL} (if not already pulled)...")
        result = subprocess.run(["ollama", "pull", OLLAMA_MODEL], capture_output=True, text=True, encoding="utf-8", errors="ignore")
        if result.returncode == 0:
            st.success("✅ Model pulled successfully!")
        else:
            st.error(f"❌ Failed to pull model: {result.stderr}")
    except Exception as e:
        st.error(f"Error pulling model: {e}")


def start_ollama_model():
    try:
        # Start ollama model in background
        subprocess.Popen(["ollama", "run", OLLAMA_MODEL], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        # Wait until the model is ready
        for _ in range(15):  # wait max ~15 seconds
            try:
                response = requests.post(OLLAMA_URL, json={"model": OLLAMA_MODEL, "prompt": "Hello", "stream": False})
                if response.status_code == 200:
                    return True
            except requests.exceptions.ConnectionError:
                pass
            time.sleep(1)
        st.error("❌ Timed out waiting for Ollama to start.")
    except Exception as e:
        st.error(f"Failed to start Ollama: {e}")

def generate_with_ollama(prompt):
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
        })
        if response.status_code == 200:
            return response.json()["response"]
        else:
            return f"Error: {response.text}"
    except Exception as e:
        return f"Error connecting to Ollama: {e}"

# Auto pull and start model
pull_ollama_model()
start_ollama_model()

# Streamlit UI
st.title("🦙 LLaMA2 via Ollama + Streamlit")
user_input = st.text_area("💬 Enter your prompt:")

if st.button("Generate"):
    with st.spinner("🧠 Thinking..."):
        output = generate_with_ollama(user_input)
        st.markdown("### 📤 Response:")
        st.write(output)
