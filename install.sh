#!/usr/bin/env bash
# Universal AI Skills Installer
# Works locally or via one-liner: curl -fsSL https://raw.githubusercontent.com/karkir0003/personal-skills/main/install.sh | bash
# Detects and configures any installed AI agent (Gemini, Claude Code, Cursor, Copilot, Universal)

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/karkir0003/personal-skills.git"

# Determine source directory (local clone or clone into ~/.personal-skills)
if [ -d "./skills" ] && [ -f "./install.sh" ]; then
    SOURCE_DIR="$(pwd)"
else
    INSTALL_CACHE="$HOME/.personal-skills"
    echo -e "${BLUE}Downloading personal-skills repository to $INSTALL_CACHE...${NC}"
    if [ -d "$INSTALL_CACHE/.git" ]; then
        git -C "$INSTALL_CACHE" pull --quiet origin main || true
    else
        rm -rf "$INSTALL_CACHE"
        git clone --quiet "$REPO_URL" "$INSTALL_CACHE"
    fi
    SOURCE_DIR="$INSTALL_CACHE"
fi

SKILLS_DIR="$SOURCE_DIR/skills"

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE} Universal AI Skills Installer${NC}"
echo -e "${BLUE} Source: $SOURCE_DIR${NC}"
echo -e "${BLUE}====================================================${NC}"

# Detect available environments
HAS_GEMINI=false
HAS_CLAUDE=false
HAS_CURSOR=false

if command -v gemini >/dev/null 2>&1 || [ -d "$HOME/.gemini" ]; then
    HAS_GEMINI=true
fi
if command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ]; then
    HAS_CLAUDE=true
fi
if [ -d "$HOME/.cursor" ] || [ -f "$HOME/.cursorrules" ]; then
    HAS_CURSOR=true
fi

# 1. Google Gemini & Antigravity
if [ "$HAS_GEMINI" = true ] || [ "$1" = "--all" ]; then
    echo -n "Configuring for Gemini & Antigravity... "
    mkdir -p "$HOME/.gemini/config/skills"
    mkdir -p "$HOME/.gemini/skills"
    for skill in "$SKILLS_DIR"/*; do
        if [ -d "$skill" ]; then
            name="$(basename "$skill")"
            ln -sfn "$skill" "$HOME/.gemini/config/skills/$name"
            ln -sfn "$skill" "$HOME/.gemini/skills/$name"
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
    echo -e "${GREEN}[INSTALLED]${NC}"
else
    echo -e "Gemini environment not detected ${YELLOW}[SKIPPED]${NC}"
fi

# 2. Anthropic Claude Code
if [ "$HAS_CLAUDE" = true ] || [ "$1" = "--all" ]; then
    echo -n "Configuring for Claude Code... "
    mkdir -p "$HOME/.claude/skills"
    for skill in "$SKILLS_DIR"/*; do
        if [ -d "$skill" ]; then
            name="$(basename "$skill")"
            ln -sfn "$skill" "$HOME/.claude/skills/$name"
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
    echo -e "${GREEN}[INSTALLED]${NC}"
else
    echo -e "Claude Code not detected ${YELLOW}[SKIPPED]${NC}"
fi

# 3. Cursor & Codex
if [ "$HAS_CURSOR" = true ] || [ "$1" = "--all" ]; then
    echo -n "Configuring for Cursor / Codex... "
    mkdir -p "$HOME/.cursor/rules"
    for skill in "$SKILLS_DIR"/*; do
        if [ -d "$skill" ]; then
            name="$(basename "$skill")"
            ln -sfn "$skill" "$HOME/.cursor/rules/$name"
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
    echo -e "${GREEN}[INSTALLED]${NC}"
else
    echo -e "Cursor / Codex not detected ${YELLOW}[SKIPPED]${NC}"
fi

# 4. Universal Fallback (~/.config/ai-skills) - Always created
echo -n "Configuring Universal Skills Registry (~/.config/ai-skills)... "
mkdir -p "$HOME/.config/ai-skills"
for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        name="$(basename "$skill")"
        ln -sfn "$skill" "$HOME/.config/ai-skills/$name"
    fi
done
echo -e "${GREEN}[INSTALLED]${NC}"

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}Setup complete! Skills are active for detected agents.${NC}"
echo -e "${BLUE}====================================================${NC}"
