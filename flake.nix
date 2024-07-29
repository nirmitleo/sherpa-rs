{
  description = "forked-sherpa-rs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        rust = pkgs.rust-bin.stable."1.79.0".default.override {
          # for rust-analyzer
          extensions = [ "rust-src" ];
          targets = [
            "aarch64-apple-darwin"
          ];
        };

        inherit (pkgs) inotify-tools terminal-notifier fontconfig;
        inherit (pkgs.lib) optionals;
        inherit (pkgs.stdenv) isDarwin isLinux;

        linuxDeps = optionals isLinux [ inotify-tools ];
        darwinDeps = optionals isDarwin [ terminal-notifier ]
          ++ (with pkgs.darwin.apple_sdk.frameworks; optionals isDarwin [
          Foundation
          CoreServices
          CoreVideo
          CoreFoundation
          CoreML
          AppKit
          Accelerate
          CoreAudio
          AudioToolbox
        ]);
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.openssl
            rust
            pkgs.ffmpeg_5
            pkgs.rust-analyzer
            pkgs.cmake # this is needed for sherpa-rs
            pkgs.openblas
            pkgs.pkg-config
          ] ++ darwinDeps ++ linuxDeps;
          shellHook = ''
            export CARGO_INSTALL_ROOT=$PWD/.nix-cargo
            export CARGO_HOME=$PWD/.nix-cargo
            mkdir -p $CARGO_HOME
            platform=$(uname);
            export PATH=$CARGO_HOME/bin:bin:$PATH
          '';
        };
      }
    );
}