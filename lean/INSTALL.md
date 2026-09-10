# Installing Lean on macOS

Lean is not installed directly. What gets installed is `elan`, a version
multiplexer — the same idea as `nvm` or `rustup` — and `elan` then fetches
compilers on demand.

That indirection is not ceremony. Every Lean project pins an exact toolchain in a
`lean-toolchain` file, because Mathlib is enormous and is distributed as prebuilt
`.olean` files that are valid for one compiler version and no other. Ask for the
wrong version and you do not get an error, you get an hour of compiling Mathlib
from source. `elan` reads that file and hands the project the compiler it asked
for, so several projects on different versions coexist without anyone thinking
about it.

## Before you start

Apple Silicon and Intel are both fine; `elan` ships native builds for each and
Rosetta is not involved.

You need `git`, which on macOS comes with the Command Line Tools:

```sh
xcode-select -p || xcode-select --install
```

If that prints a path, you already have them and nothing further is needed.

Budget about 10 GB of disk. Measured on this machine after a first successful
build: 2.7 GB under `~/.elan` for the toolchain, which is shared by every project
pinning that version, and 7.5 GB under `lean/.lake` for Mathlib's sources and
prebuilt `.olean` files, which is per project.

## The recommended way: elan's own installer

```sh
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- -y --default-toolchain stable
source "$HOME/.elan/env"
```

This unpacks `elan` into `~/.elan/bin` and appends a line to your shell profile
that puts it on `PATH`. New terminals pick that up on their own; the `source` line
is only so that the terminal you are sitting in does not need restarting.

Three flags are worth knowing. `-y` skips the confirmation prompt.
`--default-toolchain stable` gives you a compiler for scratch files that live
outside any project — leave it as `none` if you only ever work in pinned projects.
`--no-modify-path` suppresses the profile edit, for those who would rather manage
`PATH` themselves.

Prefer this over Homebrew if you have no reason not to: it is upstream, and it can
update itself.

## Alternative: Homebrew

```sh
brew install elan-init
elan default stable
```

The formula lands its shims in `/opt/homebrew/bin`, which is already on your
`PATH`, so there is no profile to edit and no `source` step. Three caveats:

It conflicts with the `lean-cli` formula, which installs a `lean` binary of its
own — you cannot have both.

It is compiled with self-update switched off, so `elan self update` will refuse.
Use `brew upgrade elan-init` instead.

It sets no default toolchain, hence the second command. Skip it if you want
nothing but pinned projects.

## What is on the machine now

Only `elan`, plus shims named `lean`, `lake` and `leanc` that forward to whichever
toolchain the current directory calls for. No compiler yet — that arrives the first
time you build something. Check that the plumbing works:

```sh
elan --version    # elan 4.2.4 (...)
lake --version    # Lake version 5.x.x (Lean version 4.x.y)
```

`lean --version` outside a project answers for the default toolchain, and errors if
you set `--default-toolchain none`. That is correct behaviour, not a broken install.

## First build

From this directory:

```sh
cd lean
lake exe cache get
lake build
```

The first command that needs a compiler triggers the download of the exact version
named in `lean-toolchain` — once per version, shared by every project that pins it.

`lake exe cache get` then fetches prebuilt Mathlib. Do not skip it, and do not
interrupt `lake build` wondering whether it has hung: with a warm cache the build
is minutes, without one it is an hour.

## Editor

Lean's tooling assumes a VS Code-family editor, so Cursor works. Install the
**Lean 4** extension (`leanprover.lean4`), open a file under `lean/`, and an
infoview opens beside it showing the proof state at the cursor: the goal still
outstanding and everything in scope that might close it. It is not a luxury —
writing Lean without it is like writing assembly without a debugger.

One macOS-specific trap. Applications launched from the Dock or Spotlight do not
inherit your shell's `PATH`, so the extension may report that it cannot find
`lake` even though the terminal finds it perfectly well. Either launch the editor
from a terminal:

```sh
cd lean && cursor .
```

or point the extension at the toolchain explicitly, in settings:

```json
{ "lean4.toolchainPath": "~/.elan/toolchains/leanprover--lean4---v4.33.1" }
```

(`elan toolchain list` prints the directory names.)

## Housekeeping

```sh
elan toolchain list                 # what is installed, and which is default
elan default stable                 # change the fallback for scratch files
elan update                         # refresh the named channels
elan toolchain uninstall <name>     # reclaim ~2.7 GB per version
```

Two macOS-only conveniences worth the minute they take. Exclude the build
directory from Time Machine and Spotlight — it is a few gigabytes of generated
binaries that will be reindexed on every build and are reproducible anyway:

```sh
touch lean/.lake/.metadata_never_index
sudo tmutil addexclusion lean/.lake
```

## When it goes wrong

| Symptom | Cause | Fix |
| --- | --- | --- |
| `zsh: command not found: lake` | profile not reloaded | `source "$HOME/.elan/env"`, or open a new terminal |
| Editor cannot find `lake`, terminal can | GUI apps do not inherit shell `PATH` | launch via `cursor .`, or set `lean4.toolchainPath` |
| Build compiles thousands of Mathlib files | cache missed | `lean-toolchain` and the `rev` in `lakefile.toml` must name the same version |
| `lake exe cache get` fails midway | transient network | rerun it; it resumes, and is safe to repeat |
| `no such file or directory: lean-toolchain` | wrong directory | run from `lean/`, not the repository root |
| `xcrun: error: invalid active developer path` | Command Line Tools missing | `xcode-select --install` |
| `elan self update` refuses | Homebrew build has self-update disabled | `brew upgrade elan-init` |

When a build looks stale rather than broken — output not matching the source —
delete `.lake` and rerun `lake exe cache get`. Nothing in it is precious.

## Uninstalling

```sh
elan self uninstall        # or: brew uninstall elan-init
rm -rf ~/.elan             # toolchains, if anything is left behind
rm -rf lean/.lake          # Mathlib and build output
```

Lean writes nothing outside those directories and the one line it added to your
shell profile, which `elan self uninstall` removes.
