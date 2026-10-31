#!/usr/bin/env python3
import sys
import os
import glob

def main():
    if len(sys.argv) < 3:
        print("Usage: parse_skills.py <skills_dir> <list|index>")
        sys.exit(1)

    skills_dir = sys.argv[1]
    mode = sys.argv[2]
    skills = []

    for skill_file in sorted(glob.glob(os.path.join(skills_dir, "*/SKILL.md"))):
        name = os.path.basename(os.path.dirname(skill_file))
        desc_lines = []
        in_desc = False
        try:
            with open(skill_file, "r", encoding="utf-8") as f:
                content = f.read()
            if "---" in content:
                frontmatter = content.split("---", 2)[1]
                for line in frontmatter.splitlines():
                    if line.startswith("description:"):
                        in_desc = True
                        val = line.split("description:", 1)[1].strip(" >-\"'")
                        if val:
                            desc_lines.append(val)
                    elif in_desc:
                        if line.startswith("  ") or line.startswith("\t"):
                            desc_lines.append(line.strip())
                        else:
                            break
        except Exception:
            pass
        desc = " ".join(desc_lines) if desc_lines else "Specialized agent skill"
        skills.append((name, desc))

    if mode == "list":
        for name, desc in skills:
            print(f"  • \033[1m{name}\033[0m: {desc}")
    elif mode == "index":
        index_file = "/tmp/personal_skills_index.md"
        with open(index_file, "w", encoding="utf-8") as f:
            f.write("# Available Personal Skills\n\n")
            f.write("You have access to the following specialized skills:\n\n")
            for name, desc in skills:
                f.write(f"- **{name}**: {desc}\n")

if __name__ == "__main__":
    main()
