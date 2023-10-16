{ pkgs ? import <nixpkgs> {}
}:

with pkgs;
with {
  hl = callPackage ./nix/hashlink.nix {};
  haxe = callPackage ./nix/haxe.nix {};
};
stdenv.mkDerivation {
  name = "dev-shell";
  buildInputs = [ haxe.haxe_4_2_3 hl
                    # Below for the C-target? Not sure.
                    #hlSrc.src
                    libpng libjpeg_turbo libvorbis openal SDL2 mbedtls libuv libGL libGLU pcre sqlite
                ];
}
