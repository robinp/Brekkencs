{ fetchFromGitHub
, stdenv
}:

let version = "1.13";
in {
  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    sha256 = "lpHW0JWxbLtOBns3By56ZBn47CZsDzwOFBuW9MlERrE=";
  };
}
