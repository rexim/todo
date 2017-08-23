# Todo

CLI tool for manipulating source code TODOs

## Usage ##

```
Usage: todo [<id> --] [register --] <files...>
```

### Examples

```console
$ todo src/main.ml                # show all TODOs in the src/main.ml file
$ todo $(git ls-repo)             # show all TODOs in the current git repo
$ todo 23 -- $(git ls-repo)       # find TODO(23) in the current git repo
$ todo register -- $(git ls-repo) # for every ID-less TODO in git repo assign a random V4 UUID
```

## Build and Dev ##

```console
$ opam install oasis ounit uuidm batteries
$ ./configure --enable-tests
$ make
$ make test
$ make install
```

### NixOS Development Environment ###

We have `default.nix` for NixOS user, but **please, read default.nix
file before nix-shell-ing it!** It is not pure and it manipulates
`.opam/` in the home directory of the current user.

If you have better ideas on organizing the dev environment, feel free
to file an issue or a PR.

### NixOS overlay ###

To install the overlay just symlink the `overlay` folder to the
corresponding place:

```console
$ ln -s ./overlay ~/.config/nixpkgs/overlays/todo-overlay
$ nix-env -iA nixos.todo
```

## License ##

Copyright © 2017 Alexey Kutepov <reximkut@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
