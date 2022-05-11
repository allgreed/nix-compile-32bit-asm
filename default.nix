let
  nixpkgs = builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    # 2022-05-11
    rev = "2a3aac479caeba0a65b2ad755fe5f284f1fde74d";
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  };
  pkgs = import nixpkgs { config = {}; };
in
with pkgs; pkgsi686Linux.mkShell {
  buildInputs =
  (
    with pkgsi686Linux;
    [
      nasm
      gcc
      gdb
    ]
  )
  ++
  [
    git
    gnumake
    entr
  ];
}
