# Personal Skills

Personal Skills collection for Google Antigravity & Gemini CLI (`gemini`).

## Installation via Gemini CLI

To install the `ai-interview-problem-setup` skill globally into **Gemini CLI**:

```bash
gemini skills install https://github.com/karkir0003/personal-skills.git --path skills/ai-interview-problem-setup
```

Or to link it directly from your local repository so updates are reflected immediately:

```bash
gemini skills link ~/Desktop/personal-skills/skills/ai-interview-problem-setup --scope user --consent
```

Verify with:
```bash
gemini skills list
```

---

## Available Skills

### [`ai-interview-problem-setup`](skills/ai-interview-problem-setup/SKILL.md)
Universal workflow and architecture for scaffolding multi-language (Python, JavaScript, Java, C++) AI-assisted interview and system design coding challenge repositories:
- **Directory Isolation**: Standalone `python/`, `javascript/`, `java/`, and `c++/` subdirectories. Candidates work strictly inside their language of choice.
- **Starter Code Only**: Transpiles data structures, models, and method signatures 1:1 with verbatim docstrings without implementing the problem's solution rules.
- **Standardized Makefiles**: Uniform `make` (run), `make setup`, and `make clean` across all languages.
- **Zero-Sudo Java Setup**: Auto-provisions Amazon Corretto 21 without password prompts.
- **Scaffolding Helper**: Includes `scripts/scaffold_repo.py` to bootstrap new repositories instantly.
