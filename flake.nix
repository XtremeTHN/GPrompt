{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
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
    ];
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        vala-language-server
      ] ++ nativeBuildInputs ++ buildInputs;
    };

    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = "test";
      version = "0.1";
      src = ./.;
      inherit nativeBuildInputs buildInputs;
    };
  };
}
