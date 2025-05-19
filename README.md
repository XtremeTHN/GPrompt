# GPrompt
A `Gcr.Prompt` implementation written in vala. It features a libadwaita window to unlock the gnome keyring.

## Building 
### NixOs
Run `nix build`

### Meson
You need the following dependencies (archlinux pkgs names).
- `gcr-4`
- `gtk4`
- `libadwaita`
- `gtk4-layer-shell`
Then run:
```bash
meson build
meson -C build compile
```
An executable with the name of `gprompt` will be available at `build/src`.

## Preview
![preview](/.github/assets/preview.png)