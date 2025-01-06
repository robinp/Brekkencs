# Using latest, since using heaps github latest implies hlsdl latest,
# but that implies using hashlink latest (probably 1.13 when released).
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
, libGL
, libGLU
}:

stdenv.mkDerivation rec {
  pname = "hashlink";
  version = "c9c4c8b1180375bfed2a4a4b14ecc518d06f3870";

  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    # sha256 = "Mw0AMPK4fdaAdq+BjnFDpo0B9qhTrecD8roLA/JF/a0=";
    sha256 = "oEzMKyAmwc8wQBpicj2G9/z/lSl7G3N0s3qv2hww0VA=";
  };

  buildInputs = [ libpng libjpeg_turbo libvorbis openal SDL2 mbedtls libuv libGL libGLU pcre sqlite ];

  #patches = [ ./hashlink.patch ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A virtual machine for Haxe";
    homepage = "https://hashlink.haxe.org/";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ iblech ];
  };
}
