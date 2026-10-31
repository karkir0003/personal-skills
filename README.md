# Personal Skills for AI Agents

A curated collection of specialized skills, workflows, and prompts for AI coding agents (**Google Gemini CLI & Antigravity**, **Claude Code**, **Cursor IDE**, and the **Universal Agent Standard / Codex**).

---

## ⚡ Quick Start

### Local Setup (Recommended)
Clone and link all skills into your local agent environment:
```bash
git clone https://github.com/karkir0003/personal-skills.git
cd personal-skills
make install
```
*(Uses live symlinks: any edits made in `skills/` are immediately active across your agents).*

### Remote One-Liner (Any Machine)
```bash
curl -fsSL https://raw.githubusercontent.com/karkir0003/personal-skills/main/install.sh | bash
```

### Gemini CLI
Install a specific skill directly via the official Gemini CLI:
```bash
gemini skills install https://github.com/karkir0003/personal-skills.git --path skills/ai-interview-problem-setup
```

---

## 📚 Available Skills

| Skill | Focus | Description |
| :--- | :--- | :--- |
| [`ai-interview-problem-setup`](skills/ai-interview-problem-setup/SKILL.md) | Multi-Language Scaffolding | Standardizes Python, JavaScript, Java, and C++ interview repositories with isolated directories, uniform Makefiles, and zero-sudo setup scripts. |

---

## 🤖 Supported Agents

<details open>
<summary><b>Google Gemini CLI & Antigravity (Default)</b></summary>

- **Antigravity IDE**: Global skills auto-discovered from `~/.gemini/config/skills/`.
- **Gemini CLI**: Automatically linked into `~/.gemini/skills/`.
- **Verification**: `gemini skills list`
</details>

<details>
<summary><b>Anthropic Claude Code</b></summary>

- **Install Agent (Native - Recommended)**:
  ```bash
  curl -fsSL https://claude.ai/install.sh | bash
  # Or via Homebrew: brew install --cask claude-code
  ```
- **Enable Skills**: `./install.sh --claude`
- Automatically links to `~/.claude/skills/` and configures global instructions in `~/.claude/CLAUDE.md`.
</details>

<details>
<summary><b>Cursor IDE</b></summary>

- **Install Agent**: `brew install --cask cursor`
- **Enable Skills**: `./install.sh --cursor`
- Automatically links to `~/.cursor/rules/` and configures global rules in `~/.cursorrules`.
</details>

<details>
<summary><b>Universal Agent Standard (Codex / Copilot / AGENTS.md)</b></summary>

- **Specification**: Agent Skills open standard (`SKILL.md` with YAML frontmatter).
- **Enable Skills**: `./install.sh --agents`
- Automatically links to `~/.agents/skills/` (the native standard path for Codex and portable agents).
</details>

---

## 🛠️ Adding a New Skill

1. **Create the skill folder**:
   ```text
   skills/<skill-name>/
   └── SKILL.md
   ```

2. **Add frontmatter**:
   ```markdown
   ---
   name: <skill-name>
   description: Brief description of what the skill does and when to use it.
   ---
   # Skill Instructions...
   ```

3. **Register**:
   ```bash
   make install
   ```
   *(The installer parses metadata and registers the skill across your active agents).*

4. **List all registered skills**:
   ```bash
   make list
   ```
