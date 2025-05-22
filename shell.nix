{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
      meson
      ninja
      pkg-config
      vala
      wrapGAppsHook4
      blueprint-compiler
      gobject-introspection

      gtk4
      libadwaita
      glib
      gcr_4
      gtk4-layer-shell
      vala-language-server
      seahorse
    ];
}
