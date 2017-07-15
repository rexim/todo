# Todo

CLI tool for manipulating source code TODOs

## Usage

```console
$ opam install oasis ounit
$ oasis setup -setup-update dynamic
$ make
$ ./todo.native
$ ./configure --enable-tests
$ make test
```

### NixOS Development Environment

We have `default.nix` for NixOS user, but **please, read default.nix
file before nix-shell-ing it!** It is not pure and it manipulates
`.opam/` in the home directory of the current user.

If you have better ideas on organizing the dev environment, feel free
to file an issue or a PR.
