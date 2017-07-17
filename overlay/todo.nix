{ stdenv, buildOcaml, fetchgit }:

buildOcaml rec {
  name = "todo";
  version = "0.0.1";

  minimumSupportedOcamlVersion = "4.03";

  src = fetchgit {
    url = "git://github.com/rexim/todo.git";
    rev = "f8682f795c97b4c1a88689ff1a869c69ce73d1b4";
    sha256 = "";
  };
}
