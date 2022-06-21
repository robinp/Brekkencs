{ pkgs ? import <nixos> {}
}:

with pkgs;
with {
  hl = callPackage ./nix/hashlink.nix {};
  hlSrc = callPackage ./nix/hashlink-sources.nix {};
};
stdenv.mkDerivation {
  name = "dev-shell";
  buildInputs = [ haxe hl hlSrc.src ];
}
