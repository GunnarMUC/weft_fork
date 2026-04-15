# Weft Fork – Klinik Beschwerdebrief-Analyzer

**Original von WeaveMindAI / Quentin Feuillade-Montixi. Adaptiert und erweitert von Gunnar Mueller, ClinicShield® (R) Munich 2026.**

**Lokales, DSGVO-konformes System zur Analyse von Beschwerdebriefen.**

Dieses Fork von Weft ist auf den Einsatz in einem Klinikum zugeschnitten. Es analysiert Beschwerdebriefe mit lokalen Ollama-Modellen (Mistral für strukturierte Bewertung, Qwen für Antwortvorschläge), holt zentrales Human-Feedback von Mitarbeitern ein und archiviert alles auditierbar in Postgres.

Weft ist keine weitere Python-Bibliothek. Es ist eine neue Abstraktionsschicht: LLMs, Datenbanken, APIs und vor allem **Humans** sind first-class Primitives. Der Rust-Compiler prüft die gesamte Architektur zur Compile-Time. Ein interaktiver, faltbarer Graph entsteht automatisch. Bidirektionale Synchronisation zwischen Code und Visualisierung. Durable Execution mit Restate überlebt Crashes, Neustarts und mehrtägige Human-Reviews ohne Datenverlust.

Das ist die Innovation: Statt hunderte Zeilen Glue-Code, State-Management und Polling schreiben Sie (oder Tangle) wenige deklarative Zeilen. Der Compiler fängt Fehler, bevor etwas läuft. Der Graph macht den Prozess für Ärzte und Qualitätsmanagement verständlich. Human-in-the-Loop ist nativ und unverzichtbar – genau richtig für Bescherdemanagement in der Klinik.

### Vorteile gegenüber traditionellen Ansätzen (LangChain, CrewAI etc.)
- **Entwicklung**: 10x weniger Code. Tangle generiert aus natürlicher Sprache validen Workflow.
- **Zuverlässigkeit**: Durable Execution + Compiler. Keine verlorenen Zwischenstände bei langen Reviews.
- **Performance**: Kompiliertes Rust-Binary (winzig, keine Python-Overhead), optimale Nutzung Ihrer 96 GB RAM.
- **Compliance**: Vollständig lokal, klarer Audit-Pfad im Graphen, zentraler Human-Review.
- **Wartbarkeit**: Ein Artefakt (Code + Graph). Keine separaten Diagramme oder Webhooks.

### Schnellstart (5 Minuten)

**Voraussetzungen**
- Mac Studio mit Ollama (Mistral 7B + Qwen 7B geladen)
- Docker Desktop
- Node.js (wird automatisch installiert)

```bash
git clone https://github.com/GunnarMUC/weft_fork.git
cd weft_fork
cp .env.example .env
./start.sh
```

Öffnen Sie http://localhost:5173.

1. Neues Projekt anlegen ("Beschwerde-Analyzer").
2. `workflows/beschwerde-analyzer.weft` öffnen oder Tangle (rechte Sidebar) mit dem Prompt aus `workflows/TANGLE-PROMPT.md` nutzen.
3. Beschwerdebrief eingeben. Der Workflow analysiert, generiert Vorschlag, pausiert für Mitarbeiter-Review (Formular), archiviert bei Freigabe.

Der `HumanQuery`-Node ist der Kern. Er pausiert den gesamten durable Workflow, bis Feedback kommt – ohne eigenen Server.

### Erweiterung
Der Katalog (`catalog/`) enthält bereits Email, Postgres, API-Triggers und mehr. Sagen Sie Tangle: "Füge E-Mail-Versand der freigegebenen Antwort hinzu" oder "Erstelle PDF-Export". Der Compiler validiert alles sofort.

Siehe `DESIGN.md` für Architektur und `workflows/beschwerde-analyzer.weft` für das aktuelle Beispiel.

Fragen? Dieses Fork ist für den internen Klinik-Einsatz. Human-in-the-Loop bleibt immer zentral.

Viel Erfolg bei der Verbesserung der Beschwerdebearbeitung. Weft macht aus chaotischen AI-Pipelines echte, produktionsreife, auditierbare Systeme.

> **Building in public, two months in.** Weft is young. The language, the type system, and the durable executor are the stable parts. The node catalog is small and intentionally opinionated (a few dozen nodes across LLM, code, communication, flow, storage, and triggers). The long-term vision is to let projects define their own nodes fluently in the language itself, but that is still ahead. If you are evaluating it for production, treat it as a foundation to build on, not a finished product. Breaking changes are expected while the shape is still settling; they will be announced, and migration notes will come with them.
>

│   └── triggers/           #   Cron, webhooks, polling
├── crates/
│   ├── weft-core/          # Type system, Weft compiler, executor, Restate objects
│   ├── weft-nodes/         # Node trait, registry, sandbox, node runner binary
│   ├── weft-api/           # REST API (triggers, files, infra, usage)
│   └── weft-orchestrator/  # Restate services and Axum project executor
├── dashboard/              # Web UI (SvelteKit + Svelte 5)
├── extension/              # Browser extension for human-in-the-loop (WXT)
├── scripts/
│   └── catalog-link.sh     # Links catalog/ into crates and dashboard (run by dev.sh)
├── init-db.sh              # PostgreSQL container setup
├── cleanup.sh              # Stop services and reset state
└── dev.sh                  # Development entry point
```

### How nodes work

The `catalog/` directory is the source of truth for every node. Each node is a folder with two files:

- `backend.rs`: the Rust implementation (the `Node` trait).
- `frontend.ts`: the dashboard UI definition (ports, config fields, icon).

`scripts/catalog-link.sh` (run automatically by `dev.sh`) symlinks these into the Rust crate and the dashboard. The `inventory` crate auto-discovers every node at startup. Adding a new node is two files in one folder. The walkthrough is in [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## Development

```bash
./dev.sh server       # Backend (Restate + orchestrator + API + node runner)
./dev.sh dashboard    # Frontend (SvelteKit dev server)
./dev.sh all          # Both (server in background, dashboard in foreground)
./dev.sh extension    # Build browser extension

./cleanup.sh                # Stop everything, clean Restate data + DB
./cleanup.sh --no-db        # Stop everything but keep database
./cleanup.sh --services     # Just stop services
./cleanup.sh --db-destroy   # Remove PostgreSQL container entirely
```

### Infrastructure nodes

Nodes like Postgres Database provision real Kubernetes resources. For local development with infrastructure nodes:

```bash
# Install kind (local K8s)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# Run with local K8s
INFRASTRUCTURE_TARGET=local ./dev.sh server
```

Infrastructure is optional. Projects that do not use infrastructure nodes do not need Kubernetes at all.

### Building without Docker

The `.sqlx` directory is committed, so `cargo build` and `cargo test` work without a running database:

```bash
cargo build          # works without PostgreSQL
cargo test           # works without PostgreSQL
```

---

## Where to go next

- **Use Weft.** Build your first project: [Getting Started](https://weavemind.ai/docs/hello-world).
- **Learn the language.** Start with [Nodes](https://weavemind.ai/docs/nodes), [Connections](https://weavemind.ai/docs/connections), [Types](https://weavemind.ai/docs/types), [Groups](https://weavemind.ai/docs/groups), [Parallel Processing](https://weavemind.ai/docs/parallel).
- **Understand the architecture.** [DESIGN.md](./DESIGN.md) lays out the principles that guide every decision in the language.
- **See what's coming.** [ROADMAP.md](./ROADMAP.md) lists the directions we are exploring.
- **Contribute.** [CONTRIBUTING.md](./CONTRIBUTING.md) walks through the dev loop, the repo layout, and how to add a node.
- **Report a security issue.** [SECURITY.md](./SECURITY.md).
- **Ask a question, share a project, argue with me.** [Discord](https://discord.com/invite/FGwNu6mDkU).

---

## License

[O'Saasy License](./LICENSE). MIT with a SaaS restriction: you can use, modify, and self-host freely, but you cannot offer it as a competing hosted service. See [osaasy.dev](https://osaasy.dev/).

Copyright © 2026 Quentin Feuillade--Montixi.
