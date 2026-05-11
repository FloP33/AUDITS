#!/bin/bash

echo "[+] Creating Audit Factory structure..."

mkdir -p backend/core backend/data frontend/src output

# docker
cat > docker-compose.yml <<EOF
version: "3.9"

services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
      - ./output:/output

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"

  llm:
    image: ollama/ollama
    ports:
      - "11434:11434"
EOF

# backend minimal
cat > backend/requirements.txt <<EOF
fastapi
uvicorn
python-docx
pyyaml
requests
EOF

cat > backend/Dockerfile <<EOF
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > backend/main.py <<EOF
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"status": "Audit Factory running"}
EOF

# findings sample
cat > backend/data/findings.yaml <<EOF
findings:
  AD_001:
    title: "SMB Signing non requis"
    severity: "High"
    description: "SMB Signing désactivé"
    impact: "Relay NTLM possible"
    recommendation: "Activer SMB Signing"
EOF

# frontend minimal
cat > frontend/package.json <<EOF
{
  "name": "audit-ui",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18",
    "axios": "^1.5.0"
  },
  "scripts": {
    "start": "react-scripts start"
  }
}
EOF

cat > frontend/Dockerfile <<EOF
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD ["npm", "start"]
EOF

cat > frontend/src/App.js <<EOF
export default function App() {
  return <h1>Audit Factory v3</h1>;
}
EOF

echo "[✔] Project generated"
