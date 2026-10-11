# Lazyvim-configuration

My [LazyVim](https://www.lazyvim.org/) setup, with instructions for recreating it on a new
machine (primarily Ubuntu 22.04).

## Repository layout

```
Lazyvim-configuration/
├── README.md                  ← this file
├── docs/
│   ├── lazyvim-setup.md       ← install Neovim, dependencies and LazyVim; list of my customizations
│   └── stow.md                ← symlink the config into ~/.config/nvim with GNU Stow
└── nvim/                      ← stow package
    └── .config/nvim/          ← linked to ~/.config/nvim
        ├── init.lua
        ├── lazyvim.json       ← enabled LazyVim extras
        ├── lazy-lock.json     ← pinned plugin versions
        └── lua/
            ├── config/        ← options, keymaps, autocmds, lazy.nvim bootstrap
            └── plugins/       ← colorscheme tweaks, CodeCompanion (Ollama) + keymaps,
                                 Markdown 80-col formatting, 80-col guide line
```

## Quick start

1. Install the prerequisites: [docs/lazyvim-setup.md](docs/lazyvim-setup.md), steps 1–5.
2. Link the config: [docs/stow.md](docs/stow.md#new-machine).
3. Run `nvim` and let lazy.nvim install the plugins.
