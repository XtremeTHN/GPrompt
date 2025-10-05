{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nativeBuildInputs = with pkgs; [
        meson
        ninja
        pkg-config
        vala
        wrapGAppsHook4
        blueprint-compiler
        gobject-introspection
      ];

      buildInputs = with pkgs; [
        gtk4
        libadwaita
        glib
        gcr_4
        gtk4-layer-shell
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit nativeBuildInputs buildInputs;

        packages = with pkgs; [
          seahorse
          vala-language-server
          uncrustify
        ];
      };

      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "gprompt";
        version = "0.1";
        src = ./.;
        inherit nativeBuildInputs buildInputs;
      };
    };
}
