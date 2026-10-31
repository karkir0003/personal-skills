#!/usr/bin/env bash
# Universal AI Skills Installer & Registry
#
# Automatically detects installed AI agents on your machine and uses each
# provider's native CLI command or standard configuration paths.
#
# Usage:
#   ./install.sh                 (Auto-detects installed agents & links skills)
#   ./install.sh --gemini        (Target only Gemini CLI & Antigravity)
#   ./install.sh --claude        (Target only Claude Code)
#   ./install.sh --cursor        (Target only Cursor IDE)
#   ./install.sh --agents        (Target only Universal / Codex Agent Standard)
#   ./install.sh --all           (Force install for all supported agents)
#   ./install.sh --list          (Lists all available skills in this repo)
#   ./install.sh --skill <name>  (Installs only a specific skill)

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

REPO_URL="https://github.com/karkir0003/personal-skills.git"

# Determine source directory (local clone or cached clone)
if [ -d "./skills" ] && [ -f "./install.sh" ]; then
    SOURCE_DIR="$(pwd)"
else
    INSTALL_CACHE="$HOME/.personal-skills"
    echo -e "${BLUE}Updating personal-skills cache in $INSTALL_CACHE...${NC}"
    if [ -d "$INSTALL_CACHE/.git" ]; then
        git -C "$INSTALL_CACHE" pull --quiet origin main 2>/dev/null || true
    else
        rm -rf "$INSTALL_CACHE"
        git clone --quiet "$REPO_URL" "$INSTALL_CACHE"
    fi
    SOURCE_DIR="$INSTALL_CACHE"
fi

SKILLS_DIR="$SOURCE_DIR/skills"
PARSE_SCRIPT="$SOURCE_DIR/scripts/parse_skills.py"

# 1. Handle --list flag
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    echo -e "${BOLD}Available Skills in personal-skills:${NC}\n"
    python3 "$PARSE_SCRIPT" "$SKILLS_DIR" list
    exit 0
fi

# Parse target options
TARGET_SKILL=""
MODE="auto"
TARGET_GEMINI=false
TARGET_CLAUDE=false
TARGET_CURSOR=false
TARGET_AGENTS=false

for arg in "$@"; do
    case "$arg" in
        --all)
            MODE="manual"
            TARGET_GEMINI=true
            TARGET_CLAUDE=true
            TARGET_CURSOR=true
            TARGET_AGENTS=true
            ;;
        --gemini)
            MODE="manual"
            TARGET_GEMINI=true
            ;;
        --claude)
            MODE="manual"
            TARGET_CLAUDE=true
            ;;
        --cursor)
            MODE="manual"
            TARGET_CURSOR=true
            ;;
        --agents|--codex|--copilot)
            MODE="manual"
            TARGET_AGENTS=true
            ;;
        --skill|-s)
            TARGET_SKILL="$2"
            ;;
    esac
done

if [ -n "$TARGET_SKILL" ] && [ ! -d "$SKILLS_DIR/$TARGET_SKILL" ]; then
    echo -e "${YELLOW}Skill '$TARGET_SKILL' not found in $SKILLS_DIR${NC}"
    exit 1
fi

# Auto-detect installed agents if running in auto mode
if [ "$MODE" = "auto" ]; then
    command -v gemini >/dev/null 2>&1 && TARGET_GEMINI=true
    [ -d "$HOME/.gemini/config" ] && TARGET_GEMINI=true
    command -v claude >/dev/null 2>&1 && TARGET_CLAUDE=true
    (command -v cursor >/dev/null 2>&1 || [ -d "/Applications/Cursor.app" ]) && TARGET_CURSOR=true
    command -v codex >/dev/null 2>&1 && TARGET_AGENTS=true

    # Fallback to Gemini if nothing specifically detected
    if [ "$TARGET_GEMINI" = false ] && [ "$TARGET_CLAUDE" = false ] && [ "$TARGET_CURSOR" = false ] && [ "$TARGET_AGENTS" = false ]; then
        TARGET_GEMINI=true
    fi
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE} Personal Skills Installer${NC}"
echo -e "${BLUE} Source: $SOURCE_DIR${NC}"
echo -e "${BLUE}====================================================${NC}"

# Generate dynamic markdown index
python3 "$PARSE_SCRIPT" "$SKILLS_DIR" index
SKILLS_INDEX="$(cat /tmp/personal_skills_index.md)"
rm -f /tmp/personal_skills_index.md

# Helper to link skills into target directories
link_skills() {
    local target_dir="$1"
    mkdir -p "$target_dir"
    for skill_path in "$SKILLS_DIR"/*; do
        if [ -d "$skill_path" ]; then
            local sname="$(basename "$skill_path")"
            if [ -z "$TARGET_SKILL" ] || [ "$TARGET_SKILL" = "$sname" ]; then
                ln -sfn "$skill_path" "$target_dir/$sname"
            fi
        fi
    done
}

# 1. Google Gemini CLI (Uses official CLI command) & Antigravity IDE
if [ "$TARGET_GEMINI" = true ]; then
    echo -e "${BOLD}Google Gemini & Antigravity:${NC}"
    if command -v gemini >/dev/null 2>&1; then
        echo -n "  • Gemini CLI: Registering via native 'gemini skills link'... "
        for skill_path in "$SKILLS_DIR"/*; do
            if [ -d "$skill_path" ]; then
                sname="$(basename "$skill_path")"
                if [ -z "$TARGET_SKILL" ] || [ "$TARGET_SKILL" = "$sname" ]; then
                    yes 2>/dev/null | gemini skills link "$skill_path" >/dev/null 2>&1 || true
                fi
            fi
        done
        echo -e "${GREEN}[OK] (Provider linked)${NC}"
    else
        echo -n "  • Gemini CLI: Linking to ~/.gemini/skills... "
        link_skills "$HOME/.gemini/skills"
        echo -e "${GREEN}[OK]${NC}"
    fi

    # Antigravity IDE global discovery
    if [ -d "$HOME/.gemini/config" ] || [ -d "$HOME/.gemini" ]; then
        echo -n "  • Antigravity IDE: Linking to ~/.gemini/config/skills... "
        link_skills "$HOME/.gemini/config/skills"
        cat << RULE > "$HOME/.gemini/config/GEMINI.md"
$SKILLS_INDEX

When the user's task matches any of the skills listed above, activate and follow the corresponding skill instructions from \`~/.gemini/config/skills/<skill_name>/SKILL.md\`.
RULE
        echo -e "${GREEN}[OK]${NC}"
    fi
fi

# 2. Anthropic Claude Code
if [ "$TARGET_CLAUDE" = true ]; then
    echo -e "${BOLD}Anthropic Claude Code:${NC}"
    echo -n "  • Claude Code: Linking skills & updating ~/.claude/CLAUDE.md... "
    link_skills "$HOME/.claude/skills"
    cat << RULE > "$HOME/.claude/CLAUDE.md"
$SKILLS_INDEX

When the user's request matches any of the skills above, review and follow the skill instructions located in \`~/.claude/skills/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
fi

# 3. Cursor IDE
if [ "$TARGET_CURSOR" = true ]; then
    echo -e "${BOLD}Cursor IDE:${NC}"
    echo -n "  • Cursor IDE: Linking rules & updating ~/.cursorrules... "
    link_skills "$HOME/.cursor/rules"
    cat << RULE > "$HOME/.cursorrules"
$SKILLS_INDEX

When the task matches any of the skills above, follow the guidelines in \`~/.cursor/rules/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
fi

# 4. Universal / Codex / Copilot Agent Standard
if [ "$TARGET_AGENTS" = true ]; then
    echo -e "${BOLD}Universal Agent Standard (Codex / Copilot):${NC}"
    echo -n "  • Linking to ~/.agents/skills... "
    link_skills "$HOME/.agents/skills"
    echo -e "${GREEN}[OK]${NC}"
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}All targeted agents configured successfully!${NC}"
echo -e "${BLUE}====================================================${NC}"
