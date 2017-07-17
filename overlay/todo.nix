{ stdenv, fetchgit, ocaml, ocamlPackages }:

ocamlPackages.buildOcaml rec {
  name = "todo";
  version = "0.0.1";

  minimumSupportedOcamlVersion = "4.02";

  src = fetchgit {
    url = "git://github.com/rexim/todo.git";
    rev = "4ba780f9d890c781c46e18c8e9f363f1e82fa475";
    sha256 = "";
  };

  configureFlags = "--enable-tests";
  configurePhase = "./configure --prefix $out $configureFlags";

  buildInputs = [ ocaml ocamlPackages.ocaml_oasis ];
}
