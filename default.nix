let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in rec {
  todoEnv = stdenv.mkDerivation rec {
    name = "todo-env";
    version = "0.0.1";
    src = ./.;
    buildInputs = [ pkgs.ocaml
                    pkgs.ocamlPackages.ocaml_oasis
                    pkgs.ocamlPackages.findlib
                    pkgs.ocamlPackages.utop ];
  };
}
