#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Weft Klinik Beschwerdebrief-Analyzer"
echo "   Innovation: First-Class Human-in-the-Loop, Rust-Compiler, Durable Workflows"
echo "=========================================="
echo ""

# 1. Ollama prüfen (zentral für lokale LLMs)
if ! curl -s --max-time 3 http://localhost:11434/v1/models > /dev/null; then
    echo "❌ Ollama nicht erreichbar (localhost:11434). Starte Ollama und lade Modelle."
    exit 1
fi
echo "✅ Ollama erkannt – mistral:7b (Analyse), qwen:7b (Vorschläge)"

# 2. .env sicherstellen (angepasst für lokalen Betrieb)
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ .env aus Beispiel erstellt (Ollama-Defaults, keine Cloud-Keys nötig)"
fi

# 3. Postgres via Docker (klinik-spezifisch)
echo "🐘 Starte PostgreSQL (Port 5433 für Klinik-Archiv)..."
docker compose up -d postgres
echo "   Warte auf healthy DB..."
sleep 5

# 4. Weft Server (Backend, Restate, DB-Init) im Hintergrund
echo "🔧 Starte Weft Server + Restate (durable Execution)..."
./dev.sh server > weft-server.log 2>&1 &
SERVER_PID=$!
echo "   Server PID: $SERVER_PID (Logs in weft-server.log)"
sleep 10  # Zeit für Restate + DB-Init

# 5. Dashboard (interaktiver Editor + Graph + Tangle)
echo "📊 Starte Weft Dashboard (http://localhost:5173)..."
echo ""
echo "✅ System läuft! Öffne http://localhost:5173"
echo "   → Neues Projekt 'Beschwerde-Analyzer' anlegen"
echo "   → workflows/beschwerde-analyzer.weft öffnen ODER Tangle mit Prompt aus workflows/TANGLE-PROMPT.md nutzen"
echo "   → Human-Review ist zentraler Bestandteil – Mitarbeiter erhalten Formular + Pause/Resume"
echo ""
echo "Drücke Ctrl+C zum Beenden des Dashboards. Server läuft weiter (kill $SERVER_PID zum Stoppen)."
echo "Für vollständigen Stopp: docker compose down && pkill -f 'dev.sh server'"

./dev.sh dashboard
