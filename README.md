# Welcome to my DotFiles!

These are made with [chezmoi](https://www.chezmoi.io/) and are inspired by [this video](https://www.youtube.com/watch?v=-RkANM9FfTM) and [this one](https://www.youtube.com/watch?v=ud7YxC33Z3w)

> [!WARNING]
> **If you don't know what these do, don't just install them!**  
> These are configuration files for my specific way of working. They setup many things - including 1Password for SSH/Git keys. Just installing these without research *will* result in a headache!

## Getting up to speed
The two-liner to install these and get going is this:
```zsh
export GITHUB_USERNAME=limegorilla
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```
