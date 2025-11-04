# GPrompt
A `Gcr.Prompt` implementation written in vala. It features a libadwaita window to unlock the gnome keyring.

## TODO

- [x] Unlock keyring
- [x] New password
- [ ] Confirm request (idk what this means, i never seen this feature before)

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
https://github.com/user-attachments/assets/b295a105-bdb4-4729-a55d-691b9e12f7f5
