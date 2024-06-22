{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
    	url = "github:oxalica/rust-overlay";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
      inputs = with pkgs; [
            openssl
            pkg-config
	    rust-bin.stable.latest.default
          ];
      in {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "code2prompt";
          version = "0.0.1";

          # src = ./.;
          src = pkgs.lib.cleanSource ./.;

          cargoLock.lockFile = ./Cargo.lock;
          
	  buildInputs = inputs;
	  nativeBuildInputs = inputs;

          buildPhase = ''
			cargo build --release 
          '';
          installPhase = ''
		   mkdir -p $out/bin
                   cp code2prompt $out/bin/
		  '';
        };
        devShells.default = pkgs.mkShell {
          packages = inputs;
        };
      });
}
