# LazyVim setup

Step-by-step installation of [LazyVim](https://www.lazyvim.org/) and its dependencies on a fresh
machine, plus a description of my customizations. Primary target is **Ubuntu 22.04**; notes for
newer releases are at the end.

---

## Requirements

| Requirement | Why | Ubuntu 22.04 source |
| --- | --- | --- |
| Neovim **>= 0.11.2** | LazyVim minimum | GitHub release tarball (apt ships 0.6 — too old) |
| Git >= 2.19 | lazy.nvim plugin manager | apt |
| C compiler, `make`, `unzip`, `curl`, `tar` | treesitter parsers, Mason | apt (`build-essential`) |
| `tree-sitter` CLI **>= 0.26.1** | builds treesitter parsers | `cargo install` (see note below) |
| A [Nerd Font](https://www.nerdfonts.com/) | icons | manual download |
| `ripgrep`, `fd` | file/grep pickers | apt |
| `fzf`, `lazygit` | pickers, `<leader>gg` git UI | GitHub (apt versions missing/old) |
| Node.js + npm | Mason installs prettier, pyright, yamlls, markdownlint, dockerls via npm | nvm |
| Python 3 + `venv` | Mason installs ruff, cmakelang via pip | apt |
| Go | `gopls`, `gofumpt`, `goimports` (lang.go extra) | go.dev tarball |
| Ollama + model | CodeCompanion AI plugin (my customization) | ollama.com script |
| `xclip` (X11) or `wl-clipboard` (Wayland) | system clipboard | apt |

---

## 1. System packages

```bash
sudo apt update
sudo apt install -y git build-essential curl unzip tar \
  ripgrep fd-find xclip \
  python3 python3-pip python3-venv \
  cmake clang luarocks

# Ubuntu names the fd binary "fdfind"; expose it as "fd"
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

Make sure `~/.local/bin` is on your `PATH` (Ubuntu's default `~/.profile` adds it once the directory exists; log out/in or `source ~/.profile`).

On Wayland, replace `xclip` with `wl-clipboard`.

## 2. Neovim

The apt package is far too old, so install the official release into `/opt/nvim`:

```bash
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo mv /opt/nvim-linux-x86_64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

nvim --version   # should print v0.11.2 or newer
```

(On ARM machines use `nvim-linux-arm64.tar.gz` and adjust the directory name.)

To **upgrade** Neovim later, re-run the same block.

## 3. Nerd Font

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -fLo /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont
fc-cache -f
```

Then set your terminal's font to **JetBrainsMono Nerd Font** (or *JetBrainsMono Nerd Font Mono*).
The terminal also needs true-color support (GNOME Terminal, Kitty, WezTerm, Alacritty all work).

## 4. Language runtimes and CLI tools

### Node.js (via nvm)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
source ~/.bashrc
nvm install --lts
```

### Go

```bash
GO_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -1)
curl -LO "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
```

### tree-sitter CLI — ⚠️ Ubuntu 22.04 gotcha

LazyVim's treesitter setup needs `tree-sitter` CLI **0.26.1+**. LazyVim tries to install it through
Mason, but the prebuilt Mason/npm binary is linked against **glibc 2.39**, and Ubuntu 22.04 ships
glibc 2.35. On 22.04 it fails with:

```
tree-sitter: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
```

Build it from source with Cargo instead (which links against your system glibc):

```bash
# install Rust if you don't have it
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

cargo install --locked tree-sitter-cli
tree-sitter --version   # >= 0.26.1
```

Don't install `tree-sitter-cli` through npm on 22.04 — it ships the same prebuilt binary.
If an older one is already on your `PATH` (e.g. `npm i -g tree-sitter-cli`), remove it with
`npm uninstall -g tree-sitter-cli` so it doesn't shadow the cargo build.

### fzf

The apt version on 22.04 is old; install from git:

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### lazygit

```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
  | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit -D -t /usr/local/bin/
```

### Ollama (for the CodeCompanion AI plugin)

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5-coder:1.5b
```

Skip this if you don't want local AI; the plugin will simply fail to connect when used.

## 5. Back up any existing Neovim setup

```bash
mv ~/.config/nvim        ~/.config/nvim.bak        2>/dev/null
mv ~/.local/share/nvim   ~/.local/share/nvim.bak   2>/dev/null
mv ~/.local/state/nvim   ~/.local/state/nvim.bak   2>/dev/null
mv ~/.cache/nvim         ~/.cache/nvim.bak         2>/dev/null
```

## 6. Install the config

**Option A — my config (recommended).** Clone this repo and symlink the config into
`~/.config/nvim` with GNU Stow. The full walkthrough is in [stow.md](stow.md); the short version:

```bash
sudo apt install -y stow
git clone git@github.com:zmerino/Lazyvim-configuration.git ~/Lazyvim-configuration
cd ~/Lazyvim-configuration
stow -v -t ~ nvim
```

The config includes `lazy-lock.json`, which pins every plugin to the exact commit I last tested.
To use the newest plugin versions instead, run `:Lazy update` after the first launch.

**Option B — plain LazyVim.** Start from the stock starter, without my customizations:

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

## 7. First launch and verification

```bash
nvim
```

On first start lazy.nvim installs all plugins, then Mason installs the language servers and
formatters. Wait for it to finish, then restart Neovim and check:

| Command | What to look for |
| --- | --- |
| `:checkhealth lazyvim` | no errors; `rg`, `fd`, `fzf`, `lazygit`, `tree-sitter` all found |
| `:Lazy` | all plugins installed, none failed |
| `:Mason` | LSPs/formatters installed (pyright, gopls, clangd, ruff, ...) |
| `:LazyExtras` | the enabled extras listed in [Customizations](#customizations) |
| `<leader>ac` | CodeCompanion chat opens (requires Ollama running) |

---

## Customizations

Everything below differs from the stock [LazyVim starter](https://github.com/LazyVim/starter).
Files not listed (`init.lua`, `lua/config/lazy.lua`, `lua/config/keymaps.lua`,
`lua/plugins/example.lua`, `stylua.toml`, `.neoconf.json`) are unchanged starter defaults.

### Enabled LazyVim extras — `lazyvim.json`

| Extra | Adds |
| --- | --- |
| `formatting.prettier` | prettier formatter (used for Markdown, JSON, YAML, JS/TS, CSS, HTML) |
| `lang.clangd` | clangd LSP, clangd_extensions (C/C++) |
| `lang.cmake` | neocmakelsp, cmake-tools, cmakelint, cmakelang |
| `lang.docker` | dockerfile & docker-compose LSPs, hadolint |
| `lang.git` | git commit/rebase/config treesitter parsers |
| `lang.go` | gopls, gofumpt, goimports, golangci-lint |
| `lang.markdown` | marksman, markdownlint-cli2, render-markdown, markdown-preview |
| `lang.python` | pyright, ruff, venv-selector |
| `lang.yaml` | yaml-language-server, SchemaStore |

Toggle extras interactively with `:LazyExtras` (writes to `lazyvim.json`).

### Editor options — `lua/config/options.lua`

```lua
vim.o.winborder = "rounded"   -- rounded borders on all floating windows (Neovim 0.11+)
```

### Colorscheme tweak — `lua/plugins/colorscheme.lua`

Keeps the default **tokyonight** theme and overrides highlights via `on_highlights`:

- window split lines (`WinSeparator`, `VertSplit`) are teal (`#66b2b2`)
- the 80-column guide line (`VirtColumn`, see below) is magenta (`#ff00ff`)

### Markdown line width — `lua/plugins/markdown.lua`

Passes extra arguments to prettier (via conform.nvim) for Markdown files only, so formatting
(on save, or `<leader>cf`) rewraps prose to **80 columns**:

- `--print-width 80 --prose-wrap always` — reflow paragraphs to 80 characters
- `--config-precedence prefer-file` — a project's own `.prettierrc` takes priority

Lines prettier can't break (long URLs, code blocks, tables) are still flagged by markdownlint's
MD013 rule. Requires the `formatting.prettier` extra above.

### 80-column guide — `lua/plugins/virt-column.lua`

Adds [virt-column.nvim](https://github.com/lukas-reineke/virt-column.nvim), which draws a thin `│`
at column 81 (just after the 80th character) in every buffer, colored by the `VirtColumn`
highlight from `colorscheme.lua`. Loaded on LazyVim's `LazyFile` event. Unlike Neovim's built-in
`colorcolumn`, it draws a line instead of shading the whole column.

### AI assistant — `lua/plugins/codecompanion.lua`

Adds [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) wired to a **local
Ollama** model, so no API key or cloud account is needed:

- chat, inline and cmd modes all use the `ollama` adapter
- model `qwen2.5-coder:1.5b`, context window `num_ctx = 8192`
- lazy-loaded on `:CodeCompanion`, `:CodeCompanionChat`, `:CodeCompanionActions`

### AI keymaps — `lua/plugins/codecompanion-keymaps.lua`

| Keys | Action |
| --- | --- |
| `<leader>a` | which-key group "AI" |
| `<leader>ac` | `:CodeCompanionChat` — open chat |
| `<leader>aa` | `:CodeCompanionActions` — action palette |
| `<leader>ai` | `:CodeCompanion` — inline prompt |

### Inactive — `lua/config/autocmds.lua`

Contains a fully commented-out experiment that set green (`#9ece6a`) `WinSeparator` / `VertSplit` /
`FloatBorder` highlights through an autocmd. It has no effect; the colorscheme override above
replaced it.

---

## Newer OS notes (Ubuntu 24.04+ / Debian 13+)

- glibc is 2.39+, so the Mason/npm `tree-sitter` binary works and the Cargo build step is optional.
- `fzf` from apt is recent enough: `sudo apt install fzf`.
- `lazygit` is in apt on 25.04+: `sudo apt install lazygit`.
- Everything else is identical.

## Updating

| Task | Command |
| --- | --- |
| Update plugins | `:Lazy sync` |
| Update LSPs/tools | `:MasonUpdate`, then `U` inside `:Mason` |
| Update treesitter parsers | `:TSUpdate` |
| Save config changes | Nothing to copy — with Stow, `~/.config/nvim` *is* the repo. Just `git commit` (see [stow.md](stow.md#day-to-day-workflow)) |
