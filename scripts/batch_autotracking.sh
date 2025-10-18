#!/bin/bash
# Batch AUTO-TRACKING Addition Script
# Target: workflow-engine/reports-2/*.md

TEMPLATE='

<!-- AUTO-TRACKING_PROMPT: v1.0 -->
<!-- RESEARCH-SYNC: FlowForge Ecosystem | Last Sync: 2025-01-11 -->
<!-- Paradigm: Docker MCP Toolkit + GPU Acceleration | Refs: [MASTER-ROADMAP](../../../MASTER-ROADMAP.md) -->
'

FILES=(
  "2025-01-11_GitHub_Strategy_Part2_Implementation.md"
  "2025-01-11_MCP_Framework_Research_Part3.md"
  "2025-01-11_MCP_vs_CLI_Architecture_Analysis_Part1.md"
  "2025-01-11_MCP_vs_CLI_Architecture_Analysis_Part2.md"
  "2025-01-11_MCP_vs_CLI_Architecture_Analysis_Part3.md"
  "2025-01-11_Phase_0.1_Architecture_REPORT_Part2.md"
  "2025-01-11_Phase_0.1_Architecture_REPORT_Part3.md"
  "2025-01-11_Phase_0.2_Progress_Summary.md"
  "2025-01-11_PlayRAGNA_Audit_Part2.md"
  "2025-01-11_PlayRAGNA_Documentation_Quality_Recommendations.md"
  "2025-01-11_Strategic_Integration_Analysis_PlayRAGNA_Part1.md"
  "2025-01-11_Strategic_Integration_Analysis_PlayRAGNA_Part2.md"
  "2025-01-11_Strategic_Integration_Analysis_PlayRAGNA_Part3.md"
)

cd "$(dirname "$0")/../workflow-engine/reports-2" || exit 1

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    if ! grep -q "AUTO-TRACKING_PROMPT" "$file"; then
      echo "$TEMPLATE" >> "$file"
      echo "✅ $file"
    else
      echo "⏭️  $file (already has AUTO-TRACKING)"
    fi
  else
    echo "❌ $file (not found)"
  fi
done

echo ""
echo "🎉 Batch AUTO-TRACKING complete!"
echo "📊 Coverage: $(grep -l "AUTO-TRACKING_PROMPT" *.md | wc -l)/18"
