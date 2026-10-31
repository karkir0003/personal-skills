#!/usr/bin/env bash
# Universal AI Skills Installer & Registry
# Defaults to configuring Google Gemini & Antigravity.
# Use --all, --claude, or --cursor to install for additional models.
#
# Usage:
#   ./install.sh                 (Installs for Gemini / Antigravity)
#   ./install.sh --all           (Installs for all models: Gemini, Claude, Cursor)
#   ./install.sh --claude        (Installs for Claude Code)
#   ./install.sh --cursor        (Installs for Cursor IDE)
#   ./install.sh --agents        (Installs for Universal Codex / Copilot Agent Standard)
#   ./install.sh --list          (Lists all available skills)
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

# Python helper to parse skill metadata
parse_skills_py() {
python3 -c "
import os, glob

skills_dir = '$SKILLS_DIR'
skills = []
for skill_file in sorted(glob.glob(os.path.join(skills_dir, '*/SKILL.md'))):
    name = os.path.basename(os.path.dirname(skill_file))
    desc_lines = []
    in_desc = False
    try:
        with open(skill_file) as f:
            content = f.read()
        if '---' in content:
            frontmatter = content.split('---', 2)[1]
            for line in frontmatter.splitlines():
                if line.startswith('description:'):
                    in_desc = True
                    val = line.split('description:', 1)[1].strip(' >-\"')
                    if val:
                        desc_lines.append(val)
                elif in_desc:
                    if line.startswith('  ') or line.startswith('\t'):
                        desc_lines.append(line.strip())
                    else:
                        break
    except Exception:
        pass
    desc = ' '.join(desc_lines) if desc_lines else 'Specialized agent skill'
    skills.append((name, desc))

mode = '$1'
if mode == 'list':
    for name, desc in skills:
        print(f'  • \033[1m{name}\033[0m: {desc}')
elif mode == 'index':
    with open('/tmp/personal_skills_index.md', 'w') as f:
        f.write('# Available Personal Skills\\n\\n')
        f.write('You have access to the following specialized skills:\\n\\n')
        for name, desc in skills:
            f.write(f'- **{name}**: {desc}\\n')
" "$1"
}

# 1. Handle --list flag
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    echo -e "${BOLD}Available Skills in personal-skills:${NC}\n"
    parse_skills_py "list"
    exit 0
fi

# Filter specific skill if requested
TARGET_SKILL=""
INSTALL_GEMINI=true
INSTALL_CLAUDE=false
INSTALL_CURSOR=false
INSTALL_AGENTS=false

for arg in "$@"; do
    case "$arg" in
        --all)
            INSTALL_CLAUDE=true
            INSTALL_CURSOR=true
            INSTALL_AGENTS=true
            ;;
        --claude)
            INSTALL_CLAUDE=true
            ;;
        --cursor)
            INSTALL_CURSOR=true
            ;;
        --agents|--copilot)
            INSTALL_AGENTS=true
            ;;
        --gemini)
            INSTALL_GEMINI=true
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

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE} Personal Skills Installer${NC}"
echo -e "${BLUE} Source: $SOURCE_DIR${NC}"
echo -e "${BLUE}====================================================${NC}"

# Generate dynamic markdown index
parse_skills_py "index"
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

# 1. Google Gemini & Antigravity (Default)
if [ "$INSTALL_GEMINI" = true ]; then
    echo -n "Installing for Gemini & Antigravity... "
    link_skills "$HOME/.gemini/config/skills"
    link_skills "$HOME/.gemini/skills"
    cat << RULE > "$HOME/.gemini/config/GEMINI.md"
$SKILLS_INDEX

When the user's task matches any of the skills listed above, activate and follow the corresponding skill instructions from \`~/.gemini/config/skills/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
fi

# 2. Anthropic Claude Code (Only when requested)
if [ "$INSTALL_CLAUDE" = true ]; then
    echo -n "Installing for Claude Code... "
    link_skills "$HOME/.claude/skills"
    cat << RULE > "$HOME/.claude/CLAUDE.md"
$SKILLS_INDEX

When the user's request matches any of the skills above, review and follow the skill instructions located in \`~/.claude/skills/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
fi

# 3. Cursor IDE (Only when requested)
if [ "$INSTALL_CURSOR" = true ]; then
    echo -n "Installing for Cursor IDE... "
    link_skills "$HOME/.cursor/rules"
    cat << RULE > "$HOME/.cursorrules"
$SKILLS_INDEX

When the task matches any of the skills above, follow the guidelines in \`~/.cursor/rules/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
fi

# 4. Universal / Codex / Copilot Agent Standard (Only when requested)
if [ "$INSTALL_AGENTS" = true ]; then
    echo -n "Installing for Universal Agent Standard (~/.agents/skills)... "
    link_skills "$HOME/.agents/skills"
    echo -e "${GREEN}[OK]${NC}"
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${BLUE}====================================================${NC}"
