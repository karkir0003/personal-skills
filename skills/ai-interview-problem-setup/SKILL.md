---
name: ai-interview-problem-setup
description: >-
  Universal workflow and architecture for scaffolding multi-language (Python, JavaScript,
  Java, C++) AI-assisted interview and system design coding challenge repositories.
  Use this skill whenever creating, transpiling, or standardizing interview problem
  repositories, generating multi-language starter code skeletons, or setting up per-directory
  Makefiles and zero-friction setup scripts.
---

# Universal AI-Assisted Interview Problem Setup

This skill defines the standardized architecture, transpilation protocol, and zero-friction tooling for scaffolding multi-language coding challenge repositories (Python, JavaScript, Java, C++) for AI-assisted interviews and design rounds.

---

## 1. Core Principles

1. **Candidate-Centric Isolation**: Candidates select **one** language. They must be instructed to `cd` directly into their chosen directory (`cd python`, `cd javascript`, `cd java`, or `cd c++`).
2. **No Root Clutter or Run Scripts**: Keep the repository root strictly clean (`README.md`, `.gitignore`, `LICENSE`). Do NOT place runnable scripts, runners, or Makefiles at the root. Candidates must work entirely inside their language directory.
3. **Starter Code Only (Never Solve the Challenge)**:
   - Transpile the core data structures, type definitions, method signatures, parameter defaults, and basic input validation 1:1.
   - **DO NOT implement the core business logic, complex constraints, or rule evaluations.** The starter code must remain the exact starting point for the candidate to solve.
4. **Verbatim Documentation**: Copy the problem statement, rules, edge cases, ASCII diagrams, and method docstrings verbatim into each language's starter file header.
5. **100% Identical Driver Output**: The starter `main()` or test runner in each language must execute the identical test sequence and produce character-for-character identical console output.
6. **Universal `Makefile` Interface**: Every language directory provides the exact same three targets: `make` (run), `make setup` (environment check/install), and `make clean`.

---

## 2. Standardized Repository Anatomy

For any arbitrary problem `<problem-slug>` (e.g., `rate-limiter`, `kv-store`, `trip-manager`, `task-scheduler`):

```text
<repo-root>/
├── README.md               # Directs candidates to cd <lang>; explains Makefile workflow
├── .gitignore              # Language-agnostic essentials (binaries, .class, pycache, modules)
├── LICENSE
├── python/
│   ├── <file_name>.py      # Python starter file (e.g. rate_limiter.py)
│   ├── Makefile            # Standard Makefile (make, make setup, make clean)
│   └── setup.sh            # Validates python3; auto-tests execution
├── javascript/
│   ├── <file_name>.js      # JavaScript starter file (e.g. rate_limiter.js)
│   ├── package.json        # Configures "start" and "test" scripts for npm
│   ├── Makefile            # Standard Makefile
│   └── setup.sh            # Validates/installs Node.js; auto-tests execution
├── java/
│   ├── <ClassName>.java    # Single-file self-contained Java starter (e.g. RateLimiter.java)
│   ├── Makefile            # Standard Makefile
│   └── setup.sh            # Auto-provisions Amazon Corretto 21 JDK without sudo
└── c++/
    ├── <file_name>.cpp     # C++17 starter file (e.g. rate_limiter.cpp)
    ├── Makefile            # Standard Makefile (compiles with -std=c++17)
    └── setup.sh            # Validates C++17 compiler; tests build and run
```

---

## 3. Cross-Language Transpilation Matrix

When transpiling a starter problem from a reference language (e.g. Python) into the other three:

| Concept | Python | JavaScript (Node.js) | Java (Java 11+) | C++ (C++17) |
| :--- | :--- | :--- | :--- | :--- |
| **Naming Convention** | `snake_case.py` | `snake_case.js` | `PascalCase.java` | `snake_case.cpp` |
| **File Structure** | Single file | Single file + `package.json` | Single file (public class first) | Single file |
| **Enum Types** | `class Status(Enum):` | `const Status = Object.freeze({...})` | `enum Status` (with custom `toString()`) | `enum class Status` (with `operator<<`) |
| **Data Models** | `@dataclass class Item:` | `class Item { constructor(...) }` | `class Item { public fields; ... }` | `struct Item { public fields; ... }` |
| **Maps / Dicts** | `dict[K, V]` | `Object` / `Map` | `Map<K, V> = new HashMap<>()` | `std::unordered_map<K, V>` |
| **Lists / Arrays** | `list[T]` | `Array` (`[]`) | `List<T> = new ArrayList<>()` | `std::vector<T>` |
| **Sets** | `set[T]` | `Set` | `Set<T> = new HashSet<>()` | `std::unordered_set<T>` |
| **Dates / Times** | `datetime`, `timedelta` | `Date` (epoch ms math) | `LocalDateTime` / `Instant` | `std::chrono::system_clock::time_point` |
| **Missing Key Error** | `raise KeyError(...)` | `throw new Error(...)` | `throw new NoSuchElementException(...)` | `throw std::out_of_range(...)` |
| **Bad Argument Error**| `raise ValueError(...)`| `throw new Error(...)` | `throw new IllegalArgumentException(...)` | `throw std::invalid_argument(...)` |

### Critical Java Rule: JEP 330 Single-File Execution
In `java/<ClassName>.java`, declare `public class <ClassName>` as the **first class in the file** (before any non-public enums or helper classes). This guarantees that candidates can run `java <ClassName>.java` directly with zero build tools or prior `javac` compilation steps.

### Critical C++ Rule: Standard Chrono & Clean Builds
- Use `using DateTime = std::chrono::system_clock::time_point;` and provide a clean `make_datetime(year, month, day, hour, min, sec)` helper.
- For unused parameters in unfinished starter functions, cast with `(void)param;` so `-Wall -Wextra` compiles with zero compiler warnings.
- Overload `operator<<` for any `enum class` so console output strings match Python's output verbatim.

---

## 4. Standardized Makefile Specification

In **every** language folder, include a `Makefile` implementing these identical targets:

### `python/Makefile`
```makefile
.PHONY: all run setup clean

all: run

run:
	@python3 $(wildcard *.py)

setup:
	@./setup.sh

clean:
	@rm -rf __pycache__ *.pyc
```

### `javascript/Makefile`
```makefile
.PHONY: all run test setup clean

all: run

run:
	@node $(wildcard *.js)

test: run

setup:
	@./setup.sh

clean:
	@rm -rf node_modules
```

### `java/Makefile`
```makefile
.PHONY: all run setup clean

all: run

run:
	@java $(wildcard *.java)

setup:
	@./setup.sh

clean:
	@rm -f *.class
```

### `c++/Makefile`
```makefile
CXX ?= $(shell command -v clang++ >/dev/null 2>&1 && echo clang++ || echo g++)
CXXFLAGS ?= -std=c++17 -Wall -Wextra -O2
SRC = $(wildcard *.cpp)
TARGET = $(basename $(SRC))

.PHONY: all run build setup clean

all: run

build: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC)

run: $(TARGET)
	@./$(TARGET)

setup:
	@./setup.sh

clean:
	@rm -f $(TARGET) *.o
```

---

## 5. Universal Zero-Sudo `setup.sh` Architecture

Every language directory must provide a self-contained, idempotent `setup.sh`. It must automatically detect its directory and the source file:

### Java Setup (`java/setup.sh`) - Zero-Sudo Auto-Provisioning
Java is typically the highest friction language in interviews. The `java/setup.sh` script must automatically download Amazon Corretto JDK locally if Java is missing—requiring **zero sudo / root privileges**:
1. Check `command -v java` and `command -v javac`.
2. If missing on macOS:
   - Detect architecture (`aarch64` vs `x64`).
   - Download the official Amazon Corretto 21 tarball directly from AWS: `https://corretto.aws/downloads/latest/amazon-corretto-21-<arch>-macos-jdk.tar.gz`.
   - Extract to `~/.corretto/` and symlink `java` and `javac` into `~/.local/bin/`.
   - Export to `PATH`.
3. If on Debian/Ubuntu: `sudo apt-get update && sudo apt-get install -y default-jdk`.
4. Test source file execution: `java $(ls *.java | head -n 1) >/dev/null`.

---

## 6. Minimal & Essential `.gitignore`

Always generate a focused `.gitignore` containing only the essentials:

```gitignore
# OS & Editor files
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
.venv/
env/
venv/
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
```

---

## 7. Universal Candidate-Facing `README.md` Template

Always use this exact template for the repository root `README.md`:

```markdown
# <Problem Title> - AI Assisted Design

Welcome to the **<Problem Title>** design round!

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
| **Python** | `python/` | [`python/<file_name>.py`](python/<file_name>.py) |
| **JavaScript** | `javascript/` | [`javascript/<file_name>.js`](javascript/<file_name>.js) |
| **Java** | `java/` | [`java/<ClassName>.java`](java/<ClassName>.java) |
| **C++** | `c++/` | [`c++/<file_name>.cpp`](c++/<file_name>.cpp) |

Every language directory contains a standardized `Makefile` with identical targets (`make`, `make setup`, `make clean`) so your workflow is consistent regardless of which language you choose.
```

---

## 8. Verification Checklist for New Problem Repositories

Before completing setup of any new interview repository, run this automated verification:
1. `(cd python && make && make clean)`
2. `(cd javascript && make && make clean)`
3. `(cd java && make && make clean)`
4. `(cd c++ && make && make clean)`
5. Verify that all four outputs match character-for-character.
6. Verify that `git status` shows zero untracked binaries, `.class` files, or object files.
