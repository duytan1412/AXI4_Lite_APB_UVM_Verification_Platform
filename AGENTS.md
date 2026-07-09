# AGENTS.md — AXI4-Lite to APB Verification Capstone

> [!IMPORTANT]
> Xưng hô: **"Cậu chủ"**.
> Use Knowns MCP first for project memory, CLI tools for Git/simulation, and evidence-first DV workflow.

## Scope

This repo is the public capstone for AI-assisted DV portfolio work.

## Rules

- Do not claim `full coverage`, `sign-off`, `production-ready`, or `industry-grade` without source evidence.
- Every README/portfolio claim must point to source, log, waveform, coverage summary, or vPlan evidence.
- Prefer APB/AXI protocol correctness, scoreboard reasoning, SVA, coverage intent, and regression reproducibility over broad feature claims.
- Codex may propose tests and review artifacts, but cannot claim pass/fail without fresh command output.
- Keep edits small and boring; do not add commercial simulator-only claims unless logs exist.

## Tool/Skill Routing Addendum — 2026-07-09

- Before choosing a tool/skill, use `D:\Project\_tooling\tools\TOOL_SKILL_REGISTRY.md` as the canonical routing table.
- Active workflow source is Knowns MCP + local `kn-*` skills. Third-party agent repos under `D:\Project\_tooling\tools\ECC` and `D:\Project\_tooling\tools\agent-patterns` are reference-only unless a specific subfolder/file is scanned and approved.
- If skills overlap, keep all complementary skills but route by source of truth: Knowns tasks/specs use `kn-*`; OpenSpec changes use `openspec-*`; general coding discipline uses `karpathy-guidelines`, `systematic-debugging`, `test-driven-development`, and `verification-before-completion`.
- Do not bulk import or activate external hooks, agents, commands, MCP servers, installers, package scripts, or skills without `D:\Project\_shortcuts\scan-skills.ps1`.

### Installed Safe Web + Diagram Routes — 2026-07-09

- Web crawl/docs extraction: prefer `D:\Project\_shortcuts\crawl4ai.ps1`; Crawl4AI runtime lives at `D:\Project\_tooling\.venv_antigravity` and is verified with `crawl4ai.ps1 doctor`.
- Social/YT/GitHub research: use `D:\Project\_shortcuts\agent-reach.ps1` only through the safe wrapper; runtime is isolated at `D:\Project\_tooling\runtimes\agent-reach`; raw upstream `agent-reach` skill remains reference-only.
- YouTube transcript route: `yt-dlp` is installed in the Agent-Reach runtime and configured with Node.js via `C:\Users\LENOVO\AppData\Roaming\yt-dlp\config`.
- GitHub route: `gh` is installed via Scoop; run `gh auth login` only when authenticated/private GitHub access is explicitly needed.
- Chip/FPGA diagrams: use `D:\Project\_tooling\.agents\skills\drawio-local` and `D:\Project\_shortcuts\drawio-local.ps1`; draw.io desktop is installed at `C:\Users\LENOVO\AppData\Local\Programs\draw.io\draw.io.exe`.
- Mermaid remains fallback for small FSMs, short flows, and Markdown-only notes; draw.io is primary for RTL/module/datapath/bus/block diagrams.

## Folder-Specific Tool Routes — AXI4_Lite_APB_UVM_Verification_Platform

- Domain: AXI4-Lite to APB bridge/platform verification, cross-protocol transactions, adapters, scoreboards, and integration regressions.
- First skill after baseline: `dv-artifact-assistant`; use `drawio-local` for AXI-to-APB bridge datapath/control, transaction conversion, address mapping, and end-to-end UVM environment diagrams.
- Use `crawl4ai.ps1` for AMBA/APB/AXI references; use `agent-reach.ps1` for GitHub examples only after local TB/docs are checked.
- Keep bridge behavior proven by tests and logs; diagrams are explanatory artifacts, not proof.
