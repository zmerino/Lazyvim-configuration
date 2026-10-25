# Managing the config with GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) creates symlinks from a directory in this repo into
your home directory. Instead of copying config files back and forth, `~/.config/nvim` becomes a
symlink into the repo, so every change you make in Neovim is already a change in the repo, ready
to commit.

## How it works

Stow treats each top-level directory in the repo as a **package**. Everything inside a package
mirrors the path it should have relative to the target (`~`):

```
Lazyvim-configuration/
└── nvim/                      ← stow package
    └── .config/
        └── nvim/              ← becomes ~/.config/nvim
            ├── init.lua
            ├── lazyvim.json
            ├── lazy-lock.json
            ├── stylua.toml
            ├── .neoconf.json
            └── lua/
                ├── config/
                └── plugins/
```

Running `stow -t ~ nvim` from the repo root creates:

```
~/.config/nvim  →  ~/Lazyvim-configuration/nvim/.config/nvim
```

Only directories you pass to `stow` are linked, so `docs/` and `README.md` are never touched.

> **Always pass `-t ~`.** By default Stow targets the *parent* of the directory you run it from,
> which is wrong unless the repo is cloned directly into `~`.

## Install Stow

```bash
sudo apt install -y stow
stow --version
```

## One-time: switch an existing machine over to Stow

The `nvim/` package already holds a copy of the config. On a machine that still has a real
`~/.config/nvim` directory (such as the one the config was copied from), replace that directory
with the Stow symlink:

```bash
cd ~/Documents/github/Lazyvim-configuration     # wherever the repo is cloned

diff -r ~/.config/nvim nvim/.config/nvim        # check nothing changed since the copy;
                                                # copy over any newer files first
mv ~/.config/nvim ~/.config/nvim.bak            # keep a backup

stow -nv -t ~ nvim                              # dry run: show what would be linked
stow -v  -t ~ nvim                              # create the symlink

ls -l ~/.config/nvim                            # should point into the repo
```

Open `nvim` and confirm everything loads as before. Plugins, Mason tools and parsers live in
`~/.local/share/nvim`, which is not moved, so nothing is reinstalled.

## New machine

After installing Neovim and the dependencies from [lazyvim-setup.md](lazyvim-setup.md) (steps 1–5):

```bash
git clone git@github.com:zmerino/Lazyvim-configuration.git ~/Lazyvim-configuration
cd ~/Lazyvim-configuration
stow -v -t ~ nvim
nvim                                            # lazy.nvim installs plugins on first launch
```

### As a submodule of my dotfiles repo

This repo is also pulled into [zmerino/dotfiles](https://github.com/zmerino/dotfiles) as a git
submodule at `modules/lazyvim`, and that repo's `bootstrap.sh` stows it for you. To do the same
step by hand from the dotfiles checkout:

```bash
cd ~/dotfiles
git submodule update --init modules/lazyvim
stow -v -d modules/lazyvim -t ~ nvim            # -d points Stow at this repo's packages
```

Edits to `~/.config/nvim` land in the submodule's working tree, so commit and push them from
`modules/lazyvim`, then commit the updated submodule pointer in the dotfiles repo.

## Day-to-day workflow

Because `~/.config/nvim` is a symlink into the repo, edits made in Neovim and files LazyVim writes
(`lazyvim.json` from `:LazyExtras`, `lazy-lock.json` from `:Lazy update`) show up in `git status`:

```bash
cd ~/Lazyvim-configuration
git status
git add -A && git commit -m "Describe the change"
git push
```

On another machine, `git pull` is all that's needed. Re-run `stow` only when you **add new files**
to a package and Stow hasn't linked a whole directory already (see below).

## Common commands

| Command | Effect |
| --- | --- |
| `stow -nv -t ~ nvim` | Dry run — print what would happen, change nothing |
| `stow -v -t ~ nvim` | Create symlinks |
| `stow -R -v -t ~ nvim` | Restow — remove and recreate links (after restructuring the package) |
| `stow -D -v -t ~ nvim` | Delete the symlinks (repo files are untouched) |

To skip typing `-t ~`, add a `.stowrc` to the repo root:

```
--target=~
```

## Troubleshooting

**`existing target is neither a link nor a directory` / `cannot stow ... over existing target`**
Something already exists at `~/.config/nvim`. Back it up and run stow again:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
stow -v -t ~ nvim
```

`stow --adopt` is an alternative: it moves the existing files *into the repo* (overwriting the
repo's versions) and then links them. Only use it when you want the machine's copy to win, and
check `git diff` afterwards.

**Stow linked individual files instead of the `nvim` directory.**
If `~/.config/nvim` already existed as a real directory, Stow links each file inside it instead of
the directory as a whole ("unfolding"). Then new files added to the repo won't appear until you
restow. Fix it by removing the real directory and restowing:

```bash
stow -D -t ~ nvim
rm -rf ~/.config/nvim           # only after confirming it contains nothing but stow links
stow -v -t ~ nvim
```

**Undo everything.**

```bash
stow -D -v -t ~ nvim                            # remove the symlink
cp -r ~/Lazyvim-configuration/nvim/.config/nvim ~/.config/nvim   # optional: plain copy instead
```
