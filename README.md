# Personal Skills

Personal Skills collection for AI coding assistants: **Google Gemini / Antigravity**, **Anthropic Claude Code**, and **OpenAI Codex / Cursor**.

## ⚡ Universal One-Command Setup

To link all personal skills across all AI models on this machine:

```bash
./install.sh
```

### How It Works
- **Symlinked in Real-Time**: `install.sh` creates symbolic links into each model's configuration directory. Any edits or additions you make in `skills/` are **immediately reflected across all models** without needing to reinstall.
- **Gemini & Antigravity**: Configures `~/.gemini/config/skills/`, `~/.gemini/skills/`, and `~/.gemini/config/GEMINI.md`.
- **Claude Code**: Configures `~/.claude/skills/` and global instructions in `~/.claude/CLAUDE.md`.
- **Cursor & Codex**: Configures `~/.cursor/rules/` and global rules in `~/.cursorrules`.
- **Universal Fallback**: Links to `~/.config/ai-skills/`.

---

## 📦 Installing on Remote Machines (Gemini CLI)

If you are on a new machine with `gemini` CLI installed, install directly from GitHub:

```bash
gemini skills install https://github.com/karkir0003/personal-skills.git --path skills/ai-interview-problem-setup
```

---

## 🛠️ Available Skills

### [`ai-interview-problem-setup`](skills/ai-interview-problem-setup/SKILL.md)
Universal workflow and architecture for scaffolding multi-language (Python, JavaScript, Java, C++) AI-assisted interview and system design coding challenge repositories:
- **Directory Isolation**: Standalone `python/`, `javascript/`, `java/`, and `c++/` subdirectories. Candidates work strictly inside their language of choice.
- **Starter Code Only**: Transpiles data structures, models, and method signatures 1:1 with verbatim docstrings without implementing the problem's solution rules.
- **Standardized Makefiles**: Uniform `make` (run), `make setup`, and `make clean` across all languages.
- **Zero-Sudo Java Setup**: Auto-provisions Amazon Corretto 21 without password prompts.
- **Scaffolding Helper**: Includes `scripts/scaffold_repo.py` to bootstrap new repositories instantly.
