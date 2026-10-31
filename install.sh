#!/usr/bin/env bash
# Universal AI Skills Installer
# Seamlessly configures Gemini (Antigravity & Gemini CLI), Claude (Claude Code), and Codex (Cursor / OpenAI).
# Uses symlinks so updates in personal-skills are immediately live across all models.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE} Universal AI Skills Installer${NC}"
echo -e "${BLUE} (Gemini, Claude, Codex, Cursor)${NC}"
echo -e "${BLUE}==============================================${NC}"

# 1. Google Gemini & Antigravity
echo -n "Configuring Gemini & Antigravity... "
mkdir -p "$HOME/.gemini/config/skills"
mkdir -p "$HOME/.gemini/skills"
for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        skill_name="$(basename "$skill")"
        ln -sfn "$skill" "$HOME/.gemini/config/skills/$skill_name"
        ln -sfn "$skill" "$HOME/.gemini/skills/$skill_name"
    fi
done

cat << 'RULE' > "$HOME/.gemini/config/GEMINI.md"
# Global Rules: AI-Assisted Interview Repositories

Whenever creating, transpiling, or scaffolding AI-assisted interview or design coding challenge repositories (multi-language Python, JavaScript, Java, C++):
1. **Always use the `ai-interview-problem-setup` skill** (`~/.gemini/config/skills/ai-interview-problem-setup/SKILL.md`).
2. **Directory Isolation**: Create `python/`, `javascript/`, `java/`, and `c++/`. Direct candidates to `cd <language>`.
3. **No Root Run Scripts**: Keep repository root clean (`README.md`, `.gitignore`, `LICENSE`). Do NOT put runnable scripts at root.
4. **Starter Code Only**: Transpile data structures, types, and method signatures 1:1 with identical docstrings. Do NOT implement business logic/rules. Ensure `main()` test drivers produce identical output across all languages.
5. **Standard Makefiles**: Put identical `Makefile` in each language directory (`make` to run, `make setup`, `make clean`).
6. **Zero-Sudo Java Setup**: Auto-provision Amazon Corretto 21 JDK locally without password prompts.
RULE
echo -e "${GREEN}[OK]${NC}"

# 2. Claude Code (Anthropic)
echo -n "Configuring Claude Code... "
mkdir -p "$HOME/.claude/skills"
for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        skill_name="$(basename "$skill")"
        ln -sfn "$skill" "$HOME/.claude/skills/$skill_name"
    fi
done

cat << 'RULE' > "$HOME/.claude/CLAUDE.md"
# Global User Instructions & Skills

You have access to specialized user skills installed in `~/.claude/skills/`:

- **ai-interview-problem-setup** (`~/.claude/skills/ai-interview-problem-setup/SKILL.md`):
  Universal architecture for scaffolding multi-language (Python, JavaScript, Java, C++) AI-assisted interview repositories.
  Always follow this skill whenever creating, transpiling, or setting up interview problem repos:
  - Isolate into `python/`, `javascript/`, `java/`, and `c++/` directories.
  - Instruct candidates to `cd <language>`.
  - Provide standard Makefiles (`make`, `make setup`, `make clean`) in each directory.
  - Keep root clean (no root run scripts).
  - Only write starter code with 1:1 types and docstrings—never implement the problem rules.
RULE
echo -e "${GREEN}[OK]${NC}"

# 3. Cursor & Codex
echo -n "Configuring Cursor / Codex... "
mkdir -p "$HOME/.cursor/rules"
for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        skill_name="$(basename "$skill")"
        ln -sfn "$skill" "$HOME/.cursor/rules/$skill_name"
    fi
done

cat << 'RULE' > "$HOME/.cursorrules"
# Global Cursor & Codex Rules

When creating, transpiling, or scaffolding AI-assisted interview coding challenges (Python, JavaScript, Java, C++):
- Refer to skills in `~/.cursor/rules/ai-interview-problem-setup/SKILL.md`.
- Separate code into `python/`, `javascript/`, `java/`, and `c++/`.
- Standardize on `Makefile` in every language directory (`make`, `make setup`, `make clean`).
- Keep repository root clean without runnable scripts.
- Starter code only: transpile method signatures and types 1:1 with matching docstrings; do not implement solutions.
RULE
echo -e "${GREEN}[OK]${NC}"

# 4. Universal Fallback (~/.config/ai-skills)
echo -n "Configuring Universal Fallback (~/.config/ai-skills)... "
mkdir -p "$HOME/.config/ai-skills"
for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        skill_name="$(basename "$skill")"
        ln -sfn "$skill" "$HOME/.config/ai-skills/$skill_name"
    fi
done
echo -e "${GREEN}[OK]${NC}"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN} All models successfully linked!${NC}"
echo -e "${GREEN} Edits in $SKILLS_DIR are live immediately.${NC}"
echo -e "${GREEN}==============================================${NC}"
