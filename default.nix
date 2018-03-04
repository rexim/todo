let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in rec {
  todoEnv = stdenv.mkDerivation rec {
    name = "todo-env";
    version = "0.0.1";
    src = ./.;
    buildInputs = [ pkgs.ocaml pkgs.opam ];
    shellHook = ''
      opam init --no-setup
      opam switch 4.03.0
      eval `opam config env`
      opam install oasis ounit batteries utop uuidm
    '';
  };
}
