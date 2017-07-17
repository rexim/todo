self: super:

{
  todo = super.callPackage ./todo.nix {
    buildOcaml = self.ocamlPackages.buildOcaml;
  };
}
