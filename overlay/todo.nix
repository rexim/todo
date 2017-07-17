{ stdenv, fetchgit, ocaml, ocamlPackages }:

ocamlPackages.buildOcaml rec {
  name = "todo";
  version = "0.0.1";

  minimumSupportedOcamlVersion = "4.02";

  src = fetchgit {
    url = "git://github.com/rexim/todo.git";
    rev = "f8682f795c97b4c1a88689ff1a869c69ce73d1b4";
    sha256 = "";
  };

  configureFlags = "--enable-tests";
  configurePhase = "./configure --prefix $out $configureFlags";

  buildInputs = [ ocaml ocamlPackages.ocaml_oasis ];
}
