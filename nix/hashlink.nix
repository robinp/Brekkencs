# Until https://github.com/NixOS/nixpkgs/pull/168289/files is merged.
{ stdenv
, lib
, fetchFromGitHub
, libpng
, libjpeg_turbo
, libvorbis
, openal
, pcre
, SDL2
, sqlite
, mbedtls
, libuv
, libGLU
}:

stdenv.mkDerivation rec {
  pname = "hashlink";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    # sha256 = "Mw0AMPK4fdaAdq+BjnFDpo0B9qhTrecD8roLA/JF/a0=";
    sha256 = "AiUGhTxz4Pkrks4oE+SAuAQPMuC5T2B6jo3Jd3sNrkQ=";
  };

  buildInputs = [ libpng libjpeg_turbo libvorbis openal SDL2 mbedtls libuv libGLU pcre sqlite ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A virtual machine for Haxe";
    homepage = "https://hashlink.haxe.org/";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ iblech ];
  };
}
