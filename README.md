# dotfiles

Config for my shell and terminal setup (Ghostty, Zsh, tmux). Uses symlinks into this repo so everything stays in one place.

## What's inside

| File | What it does |
|------|--------------|
| `install.sh` | Main setup. Installs packages, Oh My Zsh, Powerlevel10k, plugins, TPM. Backs up and symlinks configs. |
| `install-apps.sh` | Installs apps from their curl installers (opencode, bun). Skips anything already present. |
| `.zshrc` | Zsh config |
| `.zshenv` | Zsh env (sets `skip_global_compinit` so zsh-autocomplete owns completion) |
| `.p10k.zsh` | Powerlevel10k theme config |
| `.tmux.conf` | Tmux config |
| `.gitconfig` | Git config |
| `ghostty/` | Ghostty terminal config (default terminal) |
| `kitty/` | Kitty terminal config |
| `gnome-termial-profile.dconf` | Gnome Terminal profile |

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/devroy10/dotfiles/main/install.sh | bash
```

For the apps script:

```bash
curl -fsSL https://raw.githubusercontent.com/devroy10/dotfiles/main/install-apps.sh | bash
```

## Notes

- Run from a fresh machine or an existing one. The main script backs up old configs before symlinking.
- Oh My Zsh and Powerlevel10k are handled by `install.sh`, so they don't appear in `install-apps.sh`.
- Install a Nerd Font (MesloLGS NF works) in your terminal so the Powerlevel10k icons render properly.
- Secrets (e.g. `GITHUB_TOKEN`) live in `~/.secrets` (untracked, `chmod 600`), which `.zshrc` sources if present. They are never committed to this repo.

## Add an app

Drop a new install function in `install-apps.sh`, call it at the bottom, and check it with `command -v`.

```bash
install_myapp() {
  if command -v myapp >/dev/null 2>&1; then
    echo "myapp already installed"
    return
  fi
  curl -fsSL https://example.com/install | bash
}
```

Symlink new configs by adding a line to `install.sh` after the existing ones.
