FROM ubuntu:22.04

# Install basic tools
RUN apt-get update && \
    apt-get install -y curl sudo git python3 python3-pip

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Add ollama to PATH
ENV PATH="/root/.ollama/bin:${PATH}"

# Pull llama2 model
RUN /root/.ollama/bin/ollama pull llama2

# Copy app
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Expose Streamlit port
EXPOSE 8501

# Start Ollama and Streamlit together
CMD ollama serve & streamlit run app.py --server.port=8501 --server.address=0.0.0.0
