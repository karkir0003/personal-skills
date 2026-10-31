#!/usr/bin/env python3
"""
Universal Scaffolder for Multi-Language AI-Assisted Interview Repositories.
Usage:
    scaffold_repo.py <problem_name> [dest_dir]

Example:
    scaffold_repo.py "Rate Limiter" .
    scaffold_repo.py "Key Value Store" /path/to/repo
"""

import os
import re
import sys

MAKEFILE_PYTHON = """.PHONY: all run setup clean

all: run

run:
\t@python3 $(wildcard *.py)

setup:
\t@./setup.sh

clean:
\t@rm -rf __pycache__ *.pyc
"""

MAKEFILE_JS = """.PHONY: all run test setup clean

all: run

run:
\t@node $(wildcard *.js)

test: run

setup:
\t@./setup.sh

clean:
\t@rm -rf node_modules
"""

MAKEFILE_JAVA = """.PHONY: all run setup clean

all: run

run:
\t@java $(wildcard *.java)

setup:
\t@./setup.sh

clean:
\t@rm -f *.class
"""

MAKEFILE_CPP = """CXX ?= $(shell command -v clang++ >/dev/null 2>&1 && echo clang++ || echo g++)
CXXFLAGS ?= -std=c++17 -Wall -Wextra -O2
SRC = $(wildcard *.cpp)
TARGET = $(basename $(SRC))

.PHONY: all run build setup clean

all: run

build: $(TARGET)

$(TARGET): $(SRC)
\t$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC)

run: $(TARGET)
\t@./$(TARGET)

setup:
\t@./setup.sh

clean:
\t@rm -f $(TARGET) *.o
"""

SETUP_PYTHON = """#!/usr/bin/env bash
set -e
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
RED='\\033[0;31m'
NC='\\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up Python Environment ==="
if command -v python3 >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Found $(python3 --version)"
else
    echo -e "${YELLOW}[!]${NC} Python 3 not found."
    exit 1
fi

PY_FILE=$(ls "$SCRIPT_DIR"/*.py 2>/dev/null | head -n 1 || true)
if [ -f "$PY_FILE" ]; then
    echo -n "Testing starter script execution... "
    python3 "$PY_FILE" >/dev/null
    echo -e "${GREEN}[SUCCESS]${NC}"
fi

echo "You can run Python with:"
echo "  make"
"""

SETUP_JS = """#!/usr/bin/env bash
set -e
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
RED='\\033[0;31m'
NC='\\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up JavaScript (Node.js) Environment ==="
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Found Node.js $(node -v)"
else
    echo -e "${YELLOW}[!]${NC} Node.js not found. Installing..."
    OS="$(uname -s)"
    if [ "$OS" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install node
        else
            curl -fsSL https://nodejs.org/dist/v20.18.0/node-v20.18.0.pkg -o /tmp/node.pkg
            sudo installer -pkg /tmp/node.pkg -target /
            rm -f /tmp/node.pkg
        fi
    elif [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y nodejs npm
    fi
fi

JS_FILE=$(ls "$SCRIPT_DIR"/*.js 2>/dev/null | head -n 1 || true)
if [ -f "$JS_FILE" ]; then
    echo -n "Testing starter script execution... "
    node "$JS_FILE" >/dev/null
    echo -e "${GREEN}[SUCCESS]${NC}"
fi

echo "You can run JavaScript with:"
echo "  make"
"""

SETUP_JAVA = """#!/usr/bin/env bash
set -e
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
RED='\\033[0;31m'
NC='\\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up Java Environment ==="
export PATH="$HOME/.local/bin:$HOME/.corretto/amazon-corretto-21.jdk/Contents/Home/bin:$PATH"

if command -v java >/dev/null 2>&1 && command -v javac >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Found Java: $(javac -version 2>&1)"
else
    echo -e "${YELLOW}[!]${NC} Java JDK not found in PATH."
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    if [ "$OS" = "Darwin" ]; then
        CORRETTO_ARCH="aarch64"
        if [ "$ARCH" = "x86_64" ]; then CORRETTO_ARCH="x64"; fi
        INSTALL_DIR="$HOME/.corretto"
        mkdir -p "$INSTALL_DIR" "$HOME/.local/bin"
        echo "Downloading Amazon Corretto 21 JDK for macOS ($CORRETTO_ARCH)..."
        curl -sL "https://corretto.aws/downloads/latest/amazon-corretto-21-${CORRETTO_ARCH}-macos-jdk.tar.gz" | tar -xz -C "$INSTALL_DIR"
        JDK_HOME=$(find "$INSTALL_DIR" -maxdepth 1 -type d -name "amazon-corretto-21*" | head -n 1)/Contents/Home
        ln -sf "$JDK_HOME/bin/java" "$HOME/.local/bin/java"
        ln -sf "$JDK_HOME/bin/javac" "$HOME/.local/bin/javac"
        export PATH="$HOME/.local/bin:$PATH"
        echo -e "${GREEN}[OK]${NC} Amazon Corretto 21 installed without sudo"
    elif [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y default-jdk
    fi
fi

JAVA_FILE=$(ls "$SCRIPT_DIR"/*.java 2>/dev/null | head -n 1 || true)
if [ -f "$JAVA_FILE" ]; then
    echo -n "Testing starter script execution... "
    java "$JAVA_FILE" >/dev/null
    echo -e "${GREEN}[SUCCESS]${NC}"
fi

echo "You can run Java with:"
echo "  make"
"""

SETUP_CPP = """#!/usr/bin/env bash
set -e
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
RED='\\033[0;31m'
NC='\\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up C++ Environment ==="
CXX_CMD=""
if command -v clang++ >/dev/null 2>&1; then
    CXX_CMD="clang++"
elif command -v g++ >/dev/null 2>&1; then
    CXX_CMD="g++"
else
    echo -e "${RED}[!]${NC} No C++ compiler found. Please install Xcode CLT (macOS) or build-essential (Linux)."
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Found $($CXX_CMD --version | head -n 1)"

CPP_FILE=$(ls "$SCRIPT_DIR"/*.cpp 2>/dev/null | head -n 1 || true)
if [ -f "$CPP_FILE" ]; then
    echo -n "Testing compilation and execution... "
    TMP_BIN="$SCRIPT_DIR/test_starter_bin"
    "$CXX_CMD" -std=c++17 "$CPP_FILE" -o "$TMP_BIN"
    "$TMP_BIN" >/dev/null
    rm -f "$TMP_BIN"
    echo -e "${GREEN}[SUCCESS]${NC}"
fi

echo "You can run C++ with:"
echo "  make"
"""

GITIGNORE = """# OS & Editor files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
*.swp
*.swo
*~
.idea/
.vscode/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
dist/
build/

# Java
*.class
*.jar
*.war
*.ear

# C / C++
*.o
*.obj
*.out
a.out
*.dSYM/

# Node / JavaScript
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
"""

README_TEMPLATE = """# {title} - AI Assisted Design

Welcome to the **{title}** design round!

### Quick Start Instructions

1. **Choose your language** and change into its directory:
   ```bash
   cd python        # For Python
   cd javascript    # For JavaScript (Node.js)
   cd java          # For Java
   cd c++           # For C++
   ```

2. **Verify / install environment** (optional):
   ```bash
   make setup
   ```
   *(Checks compilers/runtimes and automatically installs any missing dependencies).*

3. **Run your code**:
   ```bash
   make
   ```
   *(Runs the starter code / test scenario).*

4. **Clean artifacts** (optional):
   ```bash
   make clean
   ```

---

## Directory & File Reference

| Language | Directory | Starter File |
| :--- | :--- | :--- |
| **Python** | `python/` | `python/{file_slug}.py` |
| **JavaScript** | `javascript/` | `javascript/{file_slug}.js` |
| **Java** | `java/` | `java/{class_name}.java` |
| **C++** | `c++/` | `c++/{file_slug}.cpp` |

Every language directory contains a standardized `Makefile` with identical targets (`make`, `make setup`, `make clean`) so your workflow is consistent regardless of which language you choose.
"""


def to_slug(s):
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


def to_pascal(s):
    words = re.split(r"[^a-zA-Z0-9]+", s)
    return "".join(w.capitalize() for w in words if w)


def scaffold(problem_title, dest_dir="."):
    file_slug = to_slug(problem_title)
    class_name = to_pascal(problem_title)

    dirs = ["python", "javascript", "java", "c++"]
    for d in dirs:
        os.makedirs(os.path.join(dest_dir, d), exist_ok=True)

    # Write Makefiles
    with open(os.path.join(dest_dir, "python", "Makefile"), "w") as f:
        f.write(MAKEFILE_PYTHON)
    with open(os.path.join(dest_dir, "javascript", "Makefile"), "w") as f:
        f.write(MAKEFILE_JS)
    with open(os.path.join(dest_dir, "java", "Makefile"), "w") as f:
        f.write(MAKEFILE_JAVA)
    with open(os.path.join(dest_dir, "c++", "Makefile"), "w") as f:
        f.write(MAKEFILE_CPP)

    # Write package.json for javascript
    pkg_json = f"""{{
  "name": "{file_slug}",
  "version": "1.0.0",
  "description": "{problem_title} - JavaScript Starter",
  "main": "{file_slug}.js",
  "scripts": {{
    "start": "node {file_slug}.js",
    "test": "node {file_slug}.js"
  }}
}}
"""
    with open(os.path.join(dest_dir, "javascript", "package.json"), "w") as f:
        f.write(pkg_json)

    # Write .gitignore
    with open(os.path.join(dest_dir, ".gitignore"), "w") as f:
        f.write(GITIGNORE)

    # Write README.md
    with open(os.path.join(dest_dir, "README.md"), "w") as f:
        f.write(README_TEMPLATE.format(title=problem_title, file_slug=file_slug, class_name=class_name))

    # Write setup.sh in each directory
    scripts = {
        "python": SETUP_PYTHON,
        "javascript": SETUP_JS,
        "java": SETUP_JAVA,
        "c++": SETUP_CPP,
    }
    for d, script in scripts.items():
        p = os.path.join(dest_dir, d, "setup.sh")
        with open(p, "w") as f:
            f.write(script)
        os.chmod(p, 0o755)

    print(f"Successfully scaffolded standardized interview structure for '{problem_title}' in '{dest_dir}'.")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: scaffold_repo.py <problem_title> [dest_dir]")
        sys.exit(1)
    title = sys.argv[1]
    dest = sys.argv[2] if len(sys.argv) > 2 else "."
    scaffold(title, dest)
