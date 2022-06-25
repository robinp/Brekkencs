{ pkgs ? import <nixpkgs> {}
}:

with pkgs;
with {
  hl = callPackage ./nix/hashlink.nix {};
  hlSrc = callPackage ./nix/hashlink-sources.nix {};
};
stdenv.mkDerivation {
  name = "dev-shell";
  buildInputs = [ haxe hl hlSrc.src
                    libpng libjpeg_turbo libvorbis openal SDL2 mbedtls libuv libGL libGLU pcre sqlite ];
}
