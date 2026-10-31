# Personal Skills for AI Coding Agents

A universal collection of agent skills, workflows, and guidelines designed to work seamlessly across **Google Gemini / Antigravity**, **Anthropic Claude Code**, and **OpenAI Codex / Cursor**.

---

## ⚡ 1-Line Universal Setup (All Detected Agents)

Install and link all skills across whichever AI agents are present on your machine:

```bash
curl -fsSL https://raw.githubusercontent.com/karkir0003/personal-skills/main/install.sh | bash
```

*(Or clone and run locally: `git clone https://github.com/karkir0003/personal-skills.git && cd personal-skills && make install`)*

---

## 💻 Installing Common AI Coding Agents

If you or a colleague don't have these agents installed yet, here are the quick 1-line installation commands:

### 1. Google Gemini CLI (`gemini`)
Official command-line coding agent powered by Google Gemini.
```bash
npm install -g @google/gemini-cli
```
*Verify with: `gemini --version`*

### 2. Anthropic Claude Code (`claude`)
Official CLI coding agent powered by Anthropic Claude 3.5 Sonnet.
```bash
npm install -g @anthropic-ai/claude-code
```
*Verify with: `claude --version`*

### 3. Cursor Editor (OpenAI Codex / Claude)
AI-first IDE built on VS Code.
```bash
# macOS via Homebrew
brew install --cask cursor
# Or download directly from: https://www.cursor.com
```

### 4. GitHub Copilot CLI (`gh copilot`)
GitHub's official AI assistant in the terminal.
```bash
gh extension install github/gh-copilot
```

### 5. Aider (`aider`)
Terminal-based AI pair programming tool.
```bash
pip install aider-chat
# Or on macOS: brew install aider
```

---

## 🤖 Activating Skills in Each Agent

Once your agent is installed, wire `personal-skills` into it using any of the methods below:

### 🔹 Google Gemini & Antigravity
- **Auto-link via `install.sh`**:
  ```bash
  ./install.sh
  ```
- **Direct CLI Installation**:
  ```bash
  gemini skills install https://github.com/karkir0003/personal-skills.git --path skills/ai-interview-problem-setup
  ```
- **Local Development Linking**:
  ```bash
  gemini skills link ./skills/ai-interview-problem-setup --scope user --consent
  ```
- **Antigravity IDE**: Automatically discovers skills from `~/.gemini/config/skills/`.

### 🔹 Anthropic Claude Code
- Running `./install.sh` automatically links skills into `~/.claude/skills/` and configures global instructions in `~/.claude/CLAUDE.md`.
- Claude Code will automatically reference and activate these skills across all projects.

### 🔹 Cursor & OpenAI Codex
- Running `./install.sh` links skills into `~/.cursor/rules/` and configures global rules in `~/.cursorrules`.
- You can also copy any `SKILL.md` directly into a project's `.cursorrules` or `.cursor/rules/`.

---

## 🛠️ Adding New Skills to This Repo

1. Create a new directory under `skills/`:
   ```text
   skills/
   └── my-new-skill/
       ├── SKILL.md          # Instructions with YAML frontmatter (name, description)
       └── scripts/          # Optional helper scripts
   ```
2. Re-run `make install`:
   ```bash
   make install
   ```
   The installer dynamically parses the YAML frontmatter and registers the new skill across all installed models automatically.

3. List available skills at any time:
   ```bash
   make list
   # or: ./install.sh --list
   ```

---

## 📚 Available Skills Index

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
