FROM ubuntu:22.04

# 1. Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    git \
    python3 \
    python3-pip \
    lsb-release \
    gnupg \
    software-properties-common

# 2. Install Ollama system-wide
RUN curl -fsSL https://ollama.com/install.sh | bash

# 3. Add Ollama to PATH
ENV PATH="/usr/local/bin:/root/.ollama/bin:$PATH"

# 4. Pull the llama2 model
RUN ollama pull llama2

# 5. Set working directory
WORKDIR /app

# 6. Copy app files
COPY . /app

# 7. Install Python requirements
RUN pip3 install -r requirements.txt

# 8. Expose Streamlit port
EXPOSE 8501

# 9. Run Ollama + Streamlit together
CMD ollama serve & streamlit run app.py --server.port=8501 --server.address=0.0.0.0
