# Todo

CLI tool for manipulating source code TODOs

## Usage ##

```
Usage: todo [<id> --] <files...>
```

### Examples

```console
$ todo src/main.ml           # show all TODOs in the src/main.ml file
$ todo $(git ls-repo)        # show all TODOs in the current git repo
$ todo 23 -- $(git ls-repo)  # find TODO(23) in the current git repo
```

### Build and Dev ###

```console
$ opam install oasis ounit
$ oasis setup -setup-update dynamic
$ make
$ ./todo.native
$ ./configure --enable-tests
$ make test
```

#### NixOS Development Environment ####

We have `default.nix` for NixOS user, but **please, read default.nix
file before nix-shell-ing it!** It is not pure and it manipulates
`.opam/` in the home directory of the current user.

If you have better ideas on organizing the dev environment, feel free
to file an issue or a PR.
