{ fetchFromGitHub
, stdenv
}:

let version = "1.12";
in {
  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    # sha256 = "Mw0AMPK4fdaAdq+BjnFDpo0B9qhTrecD8roLA/JF/a0=";
    sha256 = "AiUGhTxz4Pkrks4oE+SAuAQPMuC5T2B6jo3Jd3sNrkQ=";
  };
}
