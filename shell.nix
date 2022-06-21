{ pkgs ? import <nixos> {}
}:

with pkgs;
stdenv.mkDerivation {
  name = "dev-shell";
  buildInputs = [ haxe ];
}
