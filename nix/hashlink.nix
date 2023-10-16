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
, mbedtls_2
, libuv
, libGL
, libGLU
}:

stdenv.mkDerivation rec {
  pname = "hashlink";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    sha256 = "lpHW0JWxbLtOBns3By56ZBn47CZsDzwOFBuW9MlERrE=";
  };

  buildInputs = [ libpng libjpeg_turbo libvorbis openal SDL2 mbedtls_2 libuv libGL libGLU pcre sqlite ];

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
