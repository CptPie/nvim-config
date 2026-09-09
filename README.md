# nvim

Personal Neovim configuration. Lua, [lazy.nvim](https://github.com/folke/lazy.nvim) for plugins,
[Mason](https://github.com/williamboman/mason.nvim) for language servers and formatters.

## Install

```bash
git clone <this-repo> ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself on first launch (`lua/cptpie/lazy.lua`) and Mason installs its
packages in the background. Install the system dependencies below first, or the first run will
fail in ways that are annoying to diagnose.

## Layout

```
init.lua                    entry point
lazy-lock.json              plugin version pins
lua/cptpie/
  lazy.lua                  lazy.nvim bootstrap, plugin imports, auto-update
  core/
    init.lua
    options.lua             editor options
    keymaps.lua             general keymaps, leader = <space>
  plugins/                  one file per plugin spec
    lsp/
      mason.lua             which servers/tools Mason installs
      lspconfig.lua         LSP keymaps, capabilities, server setup
spell/
  de.utf-8.spl              German dictionary (see Notes)
```

Everything here is source. Runtime state lives outside the repo, in
`~/.local/share/nvim/{lazy,mason}` and `~/.local/state/nvim`, so there is nothing to gitignore.

## System dependencies

### Required

| Tool | Arch package | Needed by |
| --- | --- | --- |
| Neovim >= 0.11 | `neovim` | `vim.lsp.buf.hover({...})` table args, `vim.lsp.inlay_hint` |
| git | `git` | lazy.nvim bootstrap clone |
| curl, unzip, tar, gzip | `curl`, `unzip`, `base` | Mason downloads and extraction |
| gcc, make | `base-devel` | `telescope-fzf-native` build, `LuaSnip` jsregexp, treesitter parsers |
| ripgrep | `ripgrep` | Telescope `live_grep` / `grep_string`, todo-comments |
| fd | `fd` | Telescope `find_files` |
| clipboard bridge | `wl-clipboard` or `xclip` | `clipboard=unnamedplus` in `options.lua` |
| a Nerd Font | e.g. `ttf-jetbrains-mono-nerd` | devicons, alpha header, lualine, nvim-tree, diagnostic signs |

### Runtimes Mason shells out to

`lsp/mason.lua` pulls 9 language servers and 8 formatters. Mason does not vendor the toolchains
they are built with:

- `nodejs`, `npm` — pyright, prettier, html-lsp, css-lsp
- `python`, `python-pip` — black, isort
- `go` — gopls (also provides `gofmt`, used by conform)
- `rust` / `rustup` — rust-analyzer
- GHC toolchain (`ghcup-hs-bin`, or `ghc` + `cabal-install`) — haskell-language-server, which must
  match the installed GHC version

### Referenced by the config, not installed by Mason

These fail silently when missing:

- `lazygit` — `plugins/lazygit.lua`, bound to `<leader>lg`
- `tmux` — `vim-tmux-navigator` is inert outside tmux
- `golangci-lint` — Go linter in `plugins/linting.lua`
- `pylint` (`python-pylint`) — Python linter
- `eslint_d` — JS/TS/Svelte linter, **not in Mason's list**: `npm i -g eslint_d`
- `grcov` + LLVM (`grcov`, `llvm`) — `plugins/coverage.lua` hardcodes `--llvm-path /usr/bin`
- `coverage` + `pytest` (`python-coverage`, `python-pytest`) — Python coverage command
- a TeX distribution (`texlive-basic`, `texlive-binextra` for latexmk) — texlab LSP is configured
  and treesitter installs the `latex` and `bibtex` parsers

### Arch one-liner

```bash
sudo pacman -S --needed neovim git base-devel curl unzip ripgrep fd \
  wl-clipboard lazygit tmux nodejs npm python python-pip go rust \
  golangci-lint python-pylint python-pytest python-coverage grcov llvm \
  latexmk ttf-jetbrains-mono-nerd
npm i -g eslint_d
```

Haskell (via `ghcup`) and TeX packages beyond `latexmk` are installed separately.

## Notes

- **`lazy-lock.json` does not pin anything in practice.** `lua/cptpie/lazy.lua` registers a
  `VimEnter` autocmd that runs `lazy.update()` on every launch, so the committed lock file is
  rewritten seconds after startup. Remove that autocmd if reproducible clones matter, or drop the
  lock file if they do not — keeping both is contradictory.
- **`spell/de.utf-8.spl` is currently unused.** Nothing sets `spell` or `spelllang`, and Neovim
  offers to download the dictionary on demand. It is committed (2.6 MB binary) only so offline
  clones have it available.
- `lsp/lspconfig.lua` calls `mason_lspconfig.setup({ handlers = ... })`, but the pinned
  `mason-lspconfig.nvim` commit is post-2.0, where `handlers` was removed. The explicit
  `lspconfig.gopls.setup()` immediately after suggests that path may already not be firing —
  worth checking whether other servers attach with completion capabilities.

## Keymaps

Leader is `<space>`. Highlights:

| Key | Action |
| --- | --- |
| `jk` | exit insert mode |
| `<leader>ee` | toggle file explorer |
| `<leader>ff` / `<leader>fs` | find files / grep in cwd |
| `<leader>ca` / `<leader>rn` | LSP code action / rename |
| `<leader>mp` | format file or selection |
| `<leader>lg` | lazygit |
| `<leader>xw` / `<leader>xd` | trouble workspace / document diagnostics |
| `<leader>sv` / `<leader>sh` / `<leader>sm` | split vertical / horizontal / maximize |
| `<leader>wr` / `<leader>ws` | restore / save session for cwd |
| `<leader>cl` / `<leader>ct` / `<leader>cr` | coverage load / toggle / run instrumented tests |

`which-key` shows the rest after a 500 ms leader pause.
