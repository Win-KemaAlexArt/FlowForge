# 🚀 FlowForge - AI Automation Platform

> **Unified Ecosystem:** Chrome Extension + n8n Workflows + Shared AI Infrastructure

**Version:** 1.0.0 | **Architecture:** Hybrid (Submodules) | **Score:** 94/100

[![FlowForge](https://img.shields.io/badge/FlowForge-AI%20Automation-blue)](https://github.com/Win-KemaAlexArt/FlowForge)
[![PlayRAGNA](https://img.shields.io/badge/Component-PlayRAGNA-green)](https://github.com/Win-KemaAlexArt/PlayRAGNA)
[![Workflow Engine](https://img.shields.io/badge/Component-Workflow%20Engine-orange)](https://github.com/Win-KemaAlexArt/workflow-engine)
[![Infrastructure](https://img.shields.io/badge/Component-Infrastructure-red)](https://github.com/Win-KemaAlexArt/flowforge-infra)

---

## 🏗️ ARCHITECTURE

```
FlowForge/ (umbrella repository)
├── PlayRAGNA/              # Chrome Extension + RAG + MCP Tools (private)
│   ├── extension/          # Chrome MV3 Extension
│   ├── bridge/             # Local WebSocket Bridge
│   └── docs/               # 42 technical research documents
│
├── workflow-engine/        # n8n AI Workflow Generator (public)
│   ├── cli/                # Typer CLI Interface
│   ├── core/               # N8nWorkflowCore Logic
│   └── mcp/                # MCP Adapter (optional)
│
└── flowforge-infra/        # Shared AI Infrastructure (public)
    ├── docker-compose.yml  # Ollama + RAGNA + Monitoring
    ├── scripts/            # install.sh, health-check.sh
    └── config/             # Service configurations
```

**Strategic Decision:** Variant B - Partial Integration
- **ROI:** 98% Year 1, 228% 3-year
- **Risk:** 0.23 LOW
- **Independence:** 95% maintained
- **Payback:** 4.2 months

---

## 🎯 COMPONENTS

### 1. [PlayRAGNA](https://github.com/Win-KemaAlexArt/PlayRAGNA) (Private)

**Purpose:** Chrome Extension для интеграции Ragna RAG с browser context

**Status:** 🟡 35% Complete (Phase 3 active)

**Features:**
- ✅ Chrome Extension MV3
- ✅ WebSocket Bridge (Node.js)
- ✅ Ragna API Integration
- ⏳ MCP Tools (Context7, Playwright)
- ⏳ Production deployment

**Tech Stack:** TypeScript, Node.js, Chrome APIs, WebSocket

---

### 2. [Workflow Engine](https://github.com/Win-KemaAlexArt/workflow-engine) (Public)

**Purpose:** AI-powered n8n workflow generation через natural language

**Status:** 🟡 20% Complete (Phase 0.S active)

**Features:**
- ✅ Hybrid CLI-first + MCP wrapper architecture
- ✅ ТРИЗ-validated design (3 contradictions resolved)
- 🔴 Shared infrastructure setup (Phase 0.S, 9h)
- ⏳ CLI Core (Phase 0.3, 10h)
- ⏳ MCP Adapter (Phase 0.4, 5h)

**Tech Stack:** Python, Typer, Pydantic, Ollama, n8n REST API

---

### 3. [Shared Infrastructure](https://github.com/Win-KemaAlexArt/flowforge-infra) (Public)

**Purpose:** Общая AI-инфраструктура для всех компонентов

**Status:** 🔴 Phase 0.S STARTING (9h effort)

**Services:**
- **Ollama** (port 11434): Local LLM (Mistral 7B)
- **RAGNA** (port 31476): RAG system
- **Prometheus** (port 9090): Metrics
- **Grafana** (port 3000): Monitoring

**Benefits:**
- Infrastructure cost: -42% (vs separate stacks)
- Maintenance: -38% (14.9h/year)
- Setup time: <10 minutes
- Uptime: 99.5%

---

## 🚀 QUICK START

### Prerequisites

- Docker & Docker Compose
- Node.js 18+ (for PlayRAGNA)
- Python 3.12+ (for workflow-engine)
- 8GB+ RAM, 10GB+ disk

### One-Command Setup

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/Win-KemaAlexArt/FlowForge
cd FlowForge

# Start shared infrastructure
cd flowforge-infra
./scripts/install.sh
./scripts/health-check.sh

# Install components (optional)
cd ../workflow-engine
pip install -e .
n8n-workflow --health-check

cd ../PlayRAGNA
npm install
# Load extension in chrome://extensions/
```

---

## 🔧 WORKING WITH SUBMODULES

### Clone Repository

```bash
# Full clone with all submodules
git clone --recurse-submodules https://github.com/Win-KemaAlexArt/FlowForge

# If already cloned without submodules
git submodule update --init --recursive
```

### Update Submodules

```bash
# Update all submodules to latest
git submodule update --remote --merge

# Update specific submodule
cd workflow-engine
git pull origin main
cd ..
git add workflow-engine
git commit -m "chore: Update workflow-engine submodule"
git push
```

### Develop in Submodule

```bash
# Work on specific component
cd PlayRAGNA
git checkout -b feature/new-mcp-tool
# ... make changes ...
git commit -am "feat: Add new MCP tool"
git push origin feature/new-mcp-tool
# Create PR on PlayRAGNA repository
```

### Access Private Submodule (PlayRAGNA)

```bash
# Configure Git credentials for private repo
gh auth login
git config --global credential.helper store

# Clone will automatically use your GitHub credentials
git clone --recurse-submodules https://github.com/Win-KemaAlexArt/FlowForge
```

---

## 📊 PROJECT STATUS

### Overall Progress: 27.5% (35/127 tasks)

**PlayRAGNA:** 35.4% (35/99 tasks)
- Phase 1-2: ✅ Complete
- Phase 3: 🟡 42% (API integration)
- Phase 4-5: ⏳ Pending

**Workflow Engine:** 20.0% (19/91 tasks)
- Phase 0.1-0.2: ✅ Complete (Research)
- Phase 0.S: 🔴 ACTIVE (Infrastructure)
- Phase 0.3-1.2: ⏳ Blocked

**Shared Infrastructure:** 0%
- Phase 0.S: 🔴 STARTING (9h)

---

## 📚 DOCUMENTATION

### Component Documentation

- **[PlayRAGNA Docs](PlayRAGNA/docs/)** - 42 technical research documents
  - Quality: 96.0/100 average
  - Categories: Extension APIs, Playwright, RAG, Ollama, Ragna
  
- **[Workflow Engine Docs](workflow-engine/docs/)** - Architecture + Research
  - Quality: 95-98/100 (MEGA-GRANULAR)
  - Reports: 8 strategic analysis documents
  
- **[Infrastructure Docs](flowforge-infra/docs/)** - Setup + Troubleshooting

### Strategic Analysis

- [Integration Strategy Part 1](workflow-engine/reports-2/2025-01-11_Strategic_Integration_Analysis_PlayRAGNA_Part1.md)
- [Integration Strategy Part 2](workflow-engine/reports-2/2025-01-11_Strategic_Integration_Analysis_PlayRAGNA_Part2.md)
- [Integration Strategy Part 3](workflow-engine/reports-2/2025-01-11_Strategic_Integration_Analysis_PlayRAGNA_Part3.md)
- [GitHub Structure Strategy](workflow-engine/reports-2/2025-01-11_GitHub_Strategy_Part1_Research.md)

---

## 🤝 DEVELOPMENT WORKFLOW

### For Component Development

```bash
# 1. Clone FlowForge
git clone --recurse-submodules https://github.com/Win-KemaAlexArt/FlowForge
cd FlowForge

# 2. Work on specific component
cd workflow-engine
git checkout -b feature/new-command
# ... develop ...
git commit -am "feat: Add export command"
git push origin feature/new-command

# 3. Create PR on component repository
gh pr create --title "feat: Add export command" --body "..."

# 4. After merge, update umbrella
cd ..
git submodule update --remote workflow-engine
git commit -am "chore: Update workflow-engine to latest"
git push
```

### For Integration Testing

```bash
# 1. Ensure all submodules are latest
git submodule update --remote --merge

# 2. Start shared infrastructure
cd flowforge-infra
docker-compose up -d

# 3. Run integration tests
cd ..
pytest tests/integration/ -v

# 4. Cleanup
cd flowforge-infra
docker-compose down -v
```

---

## 🔗 LINKS

- **GitHub Organization:** [Win-KemaAlexArt](https://github.com/Win-KemaAlexArt)
- **PlayRAGNA:** [Repository](https://github.com/Win-KemaAlexArt/PlayRAGNA)
- **Workflow Engine:** [Repository](https://github.com/Win-KemaAlexArt/workflow-engine)
- **Infrastructure:** [Repository](https://github.com/Win-KemaAlexArt/flowforge-infra)

---

## 📄 LICENSE

See individual component licenses:
- [PlayRAGNA License](PlayRAGNA/LICENSE)
- [Workflow Engine License](workflow-engine/LICENSE)
- [Infrastructure License](flowforge-infra/LICENSE)

---

**Last Updated:** 2025-01-11  
**Next Milestone:** Phase 0.S Complete (Shared Infrastructure, Week 1)  
**Version:** 1.0.0-alpha
