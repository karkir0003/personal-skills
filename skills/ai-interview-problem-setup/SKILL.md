---
name: ai-interview-problem-setup
description: >-
  Universal workflow and architecture for scaffolding multi-language (Python, JavaScript,
  Java, C++) AI-assisted interview and system design coding challenge repositories.
  Use this skill whenever creating, transpiling, or standardizing interview problem
  repositories, generating multi-language starter code skeletons (both single-file and
  multi-file modular packages), or setting up per-directory Makefiles and zero-friction setup scripts.
---

# Universal AI-Assisted Interview Problem Setup

This skill defines the standardized architecture, transpilation protocol, testing frameworks, and zero-friction tooling for scaffolding multi-language coding challenge repositories (Python, JavaScript, Java, C++) for AI-assisted interviews and design rounds.

---

## 1. Core Principles

1. **Candidate-Centric Isolation**: Candidates select **one** language. They must be instructed to `cd` directly into their chosen directory (`cd python`, `cd javascript`, `cd java`, or `cd c++`).
2. **No Root Clutter or Run Scripts**: Keep the repository root strictly clean (`README.md`, `.gitignore`, `LICENSE`). Do NOT place runnable scripts, runners, or Makefiles at the root. Candidates must work entirely inside their language directory.
3. **Respect Problem Architecture (Single-File vs. Multi-File Packages)**:
   - **Never force a multi-file problem into a single file.** If the reference implementation is modular (e.g. separate models, conditions, service layers, and tests), preserve and mirror that modular architecture across all target languages.
   - If the reference implementation is explicitly single-file, retain the single-file structure across all languages.
4. **Starter Code Only (Never Solve the Challenge)**:
   - Transpile core data structures, type definitions, method signatures, parameter defaults, and basic input validation 1:1.
   - **DO NOT implement the core business logic, complex constraints, or rule evaluations.** The starter code must remain the exact starting point for the candidate to solve.
5. **Standardized Testing Frameworks (Zero-Friction Setup)**:
   - Use standard industry testing frameworks with automated, zero-friction setup scripts:
     - **Python**: Standard library `unittest` (zero install, 100% compatible with `pytest`).
     - **Java**: `JUnit 5` via bundled `junit-platform-console-standalone.jar` in `lib/` (zero Maven/Gradle setup required).
     - **C++**: `Google Test` (auto-provisioned via `setup.sh` via Homebrew / apt) or `doctest` single-header.
     - **JavaScript**: Node.js built-in `assert` module (zero npm packages required).
6. **Verbatim Documentation**: Copy problem statements, rules, edge cases, ASCII diagrams, and method docstrings verbatim into each language's starter file header.
7. **Universal `Makefile` Interface**: Every language directory provides the exact same three targets: `make` (run/test), `make setup` (environment check/install), and `make clean`.

---

## 2. Standardized Repository Anatomies

### Archetype A: Single-File Problem (e.g. `rate-limiter`, `kv-store`)

```text
<repo-root>/
├── README.md               # Directs candidates to cd <lang>; explains Makefile workflow
├── .gitignore              # Language-agnostic essentials
├── LICENSE
├── python/
│   ├── <file_name>.py      # Python starter file (e.g. rate_limiter.py)
│   ├── Makefile            # Standard Makefile (make, make setup, make clean)
│   └── setup.sh            # Validates python3; auto-tests execution
├── javascript/
│   ├── <file_name>.js      # JavaScript starter file (e.g. rate_limiter.js)
│   ├── package.json        # Configures "start" and "test" scripts for npm
│   ├── Makefile            # Standard Makefile
│   └── setup.sh            # Validates Node.js; auto-tests execution
├── java/
│   ├── <ClassName>.java    # Single-file self-contained Java starter (JEP 330)
│   ├── Makefile            # Standard Makefile
│   └── setup.sh            # Auto-provisions Amazon Corretto 21 JDK without sudo
└── c++/
    ├── <file_name>.cpp     # C++17 starter file (e.g. rate_limiter.cpp)
    ├── Makefile            # Standard Makefile (compiles with -std=c++17)
    └── setup.sh            # Validates C++17 compiler; tests build and run
```

### Archetype B: Multi-File / Modular Package Problem (e.g. `procurement-form`, `trip-manager`)

```text
<repo-root>/
├── README.md               # Directs candidates to cd <lang>; explains Makefile workflow
├── .gitignore              # Ignores bin/, test_runner, pycache, but preserves java/lib/*.jar
├── LICENSE
├── python/
│   ├── Makefile            # Runs: PYTHONPATH=<pkg> python3 -m unittest discover ...
│   ├── setup.sh            # Validates python3; tests unittest suite
│   └── <pkg_dir>/
│       ├── <module>/       # Domain models, enums, conditions, service layers
│       └── tests/          # test_<slug>.py using unittest
├── javascript/
│   ├── Makefile            # Runs: node tests/test_<slug>.js
│   ├── setup.sh            # Validates Node.js; tests suite
│   ├── package.json        # npm test config
│   ├── <module>/           # Modular domain code (models.js, service.js, etc.)
│   └── tests/              # test_<slug>.js using built-in assert
├── java/
│   ├── Makefile            # Compiles src/ & tests/; executes standalone JUnit 5
│   ├── setup.sh            # Provisions JDK & auto-fetches JUnit standalone jar if missing
│   ├── lib/
│   │   └── junit-platform-console-standalone-1.10.2.jar
│   ├── src/<module>/       # Domain classes and enums
│   └── tests/              # Test<Slug>.java using JUnit 5 (@Test, @BeforeEach)
└── c++/
    ├── Makefile            # Auto-detects Google Test (brew/pkg-config) and compiles into test_runner
    ├── setup.sh            # Validates C++17 compiler & auto-provisions Google Test
    ├── include/<module>/   # Header files (.hpp)
    ├── src/                # Implementation files (.cpp)
    └── tests/              # test_<slug>.cpp using Google Test (TEST, EXPECT_EQ, ASSERT_NE)
```

---

## 3. Cross-Language Transpilation & Testing Matrix

| Concept | Python | JavaScript (Node.js) | Java (Java 11+) | C++ (C++17) |
| :--- | :--- | :--- | :--- | :--- |
| **Naming Convention** | `snake_case.py` | `snake_case.js` | `PascalCase.java` | `snake_case.cpp` |
| **Testing Framework** | `unittest` (standard library) | Built-in `assert` module | `JUnit 5` (standalone console) | `Google Test` (or `doctest`) |
| **Test Assertion** | `self.assertEqual(a, b)` | `assert.strictEqual(a, b)` | `assertEquals(a, b)` | `EXPECT_EQ(a, b)`, `ASSERT_NE(p, nullptr)` |
| **Setup Fixture** | `def setUp(self):` | Per-test setup or helper | `@BeforeEach public void setUp()` | Per-case setup or `TestFixture` |
| **Enum Types** | `class Status(Enum):` | `const Status = Object.freeze({...})` | `enum Status` | `enum class Status` + `to_string()` |
| **Data Models** | `class Item:` / `@dataclass` | `class Item { constructor(...) }` | `class Item { private fields... }` | `class Item` / `struct Item` |
| **Maps / Dicts** | `dict[K, V]` | `Map` or `Object` | `Map<K, V> = new HashMap<>()` | `std::unordered_map<K, V>` |
| **Lists / Arrays** | `list[T]` | `Array` (`[]`) | `List<T> = new ArrayList<>()` | `std::vector<T>` |
| **Sets** | `set[T]` | `Set` | `Set<T> = new HashSet<>()` | `std::unordered_set<T>` |
| **Optional Values** | `Optional[T]` / `None` | `T` / `null` | `T` / `Optional<T>` | `const T*` / `std::optional<T>` |
| **Missing Key Error** | `raise KeyError(...)` | `throw new Error(...)` | `throw new NoSuchElementException(...)` | `throw std::out_of_range(...)` |
| **Bad Argument Error**| `raise ValueError(...)`| `throw new Error(...)` | `throw new IllegalArgumentException(...)` | `throw std::invalid_argument(...)` |

### Critical Multi-Language Rules:
1. **Single-File Java (Archetype A)**: Declare `public class <ClassName>` as the first class in the file to guarantee JEP 330 execution (`java <ClassName>.java`).
2. **Modular Java with JUnit 5 (Archetype B)**: Keep `lib/junit-platform-console-standalone-*.jar` in `java/lib/`. Compile with `javac -cp "lib/*"` and execute with `java -jar lib/junit-platform-console-standalone-*.jar execute --class-path bin --scan-class-path --disable-banner --details=summary`.
3. **C++ Google Test (Archetype B)**: Use `c++/setup.sh` to auto-provision Google Test (`brew install googletest` on macOS or `libgtest-dev` on Linux). In `Makefile`, auto-detect Homebrew prefix or pkg-config to link `-lgtest -lgtest_main -pthread`.
4. **C++ Enum Overloading**: Overload `operator<<` for any `enum class` so console output strings and test failure logs format cleanly.

---

## 4. Standardized Makefile Specifications

### Archetype B: Multi-File / Modular Package Makefiles

- **`c++/Makefile` (Google Test)**:
  ```makefile
  CXX ?= $(shell command -v clang++ >/dev/null 2>&1 && echo clang++ || echo g++)
  CXXFLAGS ?= -std=c++17 -Wall -Wextra -O2 -Iinclude

  GTEST_PREFIX ?= $(shell command -v brew >/dev/null 2>&1 && brew --prefix googletest 2>/dev/null)
  ifneq ($(GTEST_PREFIX),)
      GTEST_CXXFLAGS = -I$(GTEST_PREFIX)/include
      GTEST_LDFLAGS = -L$(GTEST_PREFIX)/lib -lgtest -lgtest_main -pthread
  else
      GTEST_CXXFLAGS = $(shell pkg-config --cflags gtest_main 2>/dev/null)
      GTEST_LDFLAGS = $(shell pkg-config --libs gtest_main 2>/dev/null || echo "-lgtest -lgtest_main -pthread")
  endif

  SRCS = $(wildcard src/*.cpp) tests/test_<slug>.cpp
  TARGET = test_runner

  .PHONY: all run build test setup clean
  all: run
  build: $(TARGET)
  $(TARGET): $(SRCS)
  	@$(CXX) $(CXXFLAGS) $(GTEST_CXXFLAGS) -o $(TARGET) $(SRCS) $(GTEST_LDFLAGS)
  run: build
  	@./$(TARGET)
  test: run
  setup:
  	@./setup.sh
  clean:
  	@rm -f $(TARGET) *.o
  ```

---

## 5. Universal Zero-Sudo `setup.sh` Architecture

Every language directory must provide a self-contained, idempotent `setup.sh` that validates runtimes and auto-provisions dependencies:

### C++ Setup (`c++/setup.sh`)
1. Detects `clang++` or `g++` supporting C++17.
2. Auto-provisions Google Test via `brew install googletest` (macOS) or `libgtest-dev` (Linux).
3. Tests compilation and runs `make && make clean`.

### Java Setup (`java/setup.sh`)
1. Checks `command -v java` and `command -v javac`.
2. If missing on macOS: auto-provisions Amazon Corretto 21 without sudo.
3. In Multi-File / JUnit projects: auto-downloads `junit-platform-console-standalone-1.10.2.jar` into `lib/` if missing.
4. Verifies test execution via `make`.

### Python Setup (`python/setup.sh`)
1. Validates `python3 >= 3.8`.
2. Runs the test suite to verify execution.

### JavaScript Setup (`javascript/setup.sh`)
1. Validates `node >= 14`.
2. Runs the test suite to verify execution.

---

## 6. Minimal & Essential `.gitignore`

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

# Build artifacts
bin/
test_runner

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
*.war
*.ear
*.jar
!java/lib/*.jar

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

```markdown
# <Problem Title> - AI Assisted Design

Welcome to the **<Problem Title>** design round!

### Quick Start Instructions

1. **Choose your language** and change into its directory:
   ```bash
   cd python        # For Python (unittest)
   cd javascript    # For JavaScript (Node.js)
   cd java          # For Java (JUnit 5)
   cd c++           # For C++ (Google Test)
   ```

2. **Verify / install environment** (optional):
   ```bash
   make setup
   ```
   *(Checks compilers/runtimes and automatically installs any missing dependencies).*

3. **Run your tests**:
   ```bash
   make
   ```
   *(Runs the test suite).*

4. **Clean artifacts** (optional):
   ```bash
   make clean
   ```

---

## Directory & File Reference

| Language | Directory | Test Framework | Source Package / File | Test Suite |
| :--- | :--- | :--- | :--- | :--- |
| **Python** | `python/` | `unittest` (standard library, zero install) | [`python/...`](python/) | [`python/.../test_...py`](python/) |
| **JavaScript** | `javascript/` | Built-in Node assertions (zero dependencies) | [`javascript/...`](javascript/) | [`javascript/.../test_....js`](javascript/) |
| **Java** | `java/` | `JUnit 5` (bundled standalone runner) | [`java/src/...`](java/src/) | [`java/tests/Test....java`](java/tests/) |
| **C++** | `c++/` | `Google Test` (auto-provisioned via setup.sh) | [`c++/include/...`](c++/include/) | [`c++/tests/test_....cpp`](c++/tests/) |

Every language directory contains a standardized `Makefile` with identical targets (`make`, `make setup`, `make clean`) so your workflow is consistent regardless of which language you choose.
```

---

## 8. Verification Checklist for New Problem Repositories

Before completing setup of any new interview repository, run this automated verification:
1. `(cd python && make && make clean)`
2. `(cd javascript && make && make clean)`
3. `(cd java && make && make clean)`
4. `(cd c++ && make && make clean)`
5. Verify that all four test suites pass cleanly.
6. Verify that `git status` shows zero untracked binaries, `.class` files, or object files.
