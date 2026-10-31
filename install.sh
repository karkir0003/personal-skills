#!/usr/bin/env bash
# Universal AI Skills Installer & Registry
# Dynamically discovers ALL skills in skills/* and configures any installed AI agent (Gemini, Claude, Cursor, Codex).
# Usage:
#   ./install.sh                 (Installs/links all skills)
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
if [ "$1" = "--skill" ] || [ "$1" = "-s" ]; then
    TARGET_SKILL="$2"
    if [ -z "$TARGET_SKILL" ] || [ ! -d "$SKILLS_DIR/$TARGET_SKILL" ]; then
        echo -e "${YELLOW}Skill '$TARGET_SKILL' not found in $SKILLS_DIR${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE} Universal AI Skills Installer${NC}"
echo -e "${BLUE} Source: $SOURCE_DIR${NC}"
echo -e "${BLUE}====================================================${NC}"

# Detect installed agent environments
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

# 1. Google Gemini & Antigravity
if [ "$HAS_GEMINI" = true ] || [ "$1" = "--all" ]; then
    echo -n "Installing for Gemini & Antigravity... "
    link_skills "$HOME/.gemini/config/skills"
    link_skills "$HOME/.gemini/skills"
    cat << RULE > "$HOME/.gemini/config/GEMINI.md"
$SKILLS_INDEX

When the user's task matches any of the skills listed above, activate and follow the corresponding skill instructions from \`~/.gemini/config/skills/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "Gemini environment not detected ${YELLOW}[SKIPPED]${NC}"
fi

# 2. Anthropic Claude Code
if [ "$HAS_CLAUDE" = true ] || [ "$1" = "--all" ]; then
    echo -n "Installing for Claude Code... "
    link_skills "$HOME/.claude/skills"
    cat << RULE > "$HOME/.claude/CLAUDE.md"
$SKILLS_INDEX

When the user's request matches any of the skills above, review and follow the skill instructions located in \`~/.claude/skills/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "Claude Code not detected ${YELLOW}[SKIPPED]${NC}"
fi

# 3. Cursor & Codex
if [ "$HAS_CURSOR" = true ] || [ "$1" = "--all" ]; then
    echo -n "Installing for Cursor / Codex... "
    link_skills "$HOME/.cursor/rules"
    cat << RULE > "$HOME/.cursorrules"
$SKILLS_INDEX

When the task matches any of the skills above, follow the guidelines in \`~/.cursor/rules/<skill_name>/SKILL.md\`.
RULE
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "Cursor / Codex not detected ${YELLOW}[SKIPPED]${NC}"
fi

# 4. Universal Fallback Registry (~/.config/ai-skills)
echo -n "Installing for Universal Registry (~/.config/ai-skills)... "
link_skills "$HOME/.config/ai-skills"
echo -e "${GREEN}[OK]${NC}"

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}All skills installed!${NC}"
echo -e "Any future additions to ${BOLD}skills/<new-skill>/${NC} will be automatically recognized."
echo -e "${BLUE}====================================================${NC}"
