# Personal Skills for AI Agents

A universal collection of agent skills, workflows, and guidelines designed for **Google Gemini / Antigravity**, **Anthropic Claude Code**, and **OpenAI Codex / Cursor**.

---

## ⚡ 1-Line Universal Install (Any Machine & Any Agent)

Install and link all skills for any AI agents detected on your system with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/karkir0003/personal-skills/main/install.sh | bash
```

*(Or clone and run locally: `git clone https://github.com/karkir0003/personal-skills.git && cd personal-skills && ./install.sh`)*

The installer automatically detects which AI agents exist on the machine and configures them. If run locally, it uses **live symbolic links** so any edits made in `skills/` are immediately active across all agents without re-installing.

---

## 🤖 Agent-Specific Instructions

### Google Gemini & Antigravity
- **Via Gemini CLI**:
  ```bash
  gemini skills install https://github.com/karkir0003/personal-skills.git --path skills/ai-interview-problem-setup
  ```
- **Local Linking**:
  ```bash
  gemini skills link ./skills/ai-interview-problem-setup --scope user --consent
  ```
- **Antigravity IDE**: Global skills are automatically discovered from `~/.gemini/config/skills/`.

### Anthropic Claude Code
- Configured in `~/.claude/skills/` and global instructions in `~/.claude/CLAUDE.md`.
- Works across all projects opened with `claude`.

### Cursor & OpenAI Codex
- Configured in `~/.cursor/rules/` and global rules in `~/.cursorrules`.
- Can also be copied into any project's `.cursorrules`.

---

## 🛠️ Available Skills

### [`ai-interview-problem-setup`](skills/ai-interview-problem-setup/SKILL.md)
Universal workflow and architecture for scaffolding multi-language (Python, JavaScript, Java, C++) AI-assisted interview and system design coding challenge repositories:
- **Directory Isolation**: Standalone `python/`, `javascript/`, `java/`, and `c++/` subdirectories. Candidates work strictly inside their language of choice.
- **Starter Code Only**: Transpiles data structures, models, and method signatures 1:1 with verbatim docstrings without implementing the problem's solution rules.
- **Standardized Makefiles**: Uniform `make` (run), `make setup`, and `make clean` across all languages.
- **Zero-Sudo Java Setup**: Auto-provisions Amazon Corretto 21 without password prompts.
- **Scaffolding Helper**: Includes `scripts/scaffold_repo.py` to bootstrap new repositories instantly:
  ```bash
  ~/.gemini/config/skills/ai-interview-problem-setup/scripts/scaffold_repo.py "<Problem Name>" <dest_dir>
  ```
