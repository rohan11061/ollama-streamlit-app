FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    git \
    python3 \
    python3-pip \
    lsb-release \
    gnupg \
    software-properties-common

# Install Ollama system-wide
RUN curl -fsSL https://ollama.com/install.sh | bash

# Add Ollama to PATH
ENV PATH="/usr/local/bin:/root/.ollama/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy app files
COPY . /app

# Install Python requirements
RUN pip3 install -r requirements.txt

# Expose Streamlit port
EXPOSE 8501

# CMD: pull model at runtime, then run ollama + streamlit
CMD ollama pull llama2 && ollama serve & streamlit run app.py --server.port=8501 --server.address=0.0.0.0
