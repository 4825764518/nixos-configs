{ stdenv, lib, fetchFromGitHub, boost, cmake, openssl }:

let version = "0.11.1";
in stdenv.mkDerivation {
  pname = "sunshine";
  inherit version;

  src = fetchFromGitHub {
    owner = "loki-47-6F-64";
    repo = "sunshine";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "1lgczf3hjckr5r44mvka6jnha5ja2mpj72bwjqfyf61vkhg0gd32";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost openssl ];

  cmakeFlags = [ "-DBoost_USE_STATIC_LIBS=OFF" ];

  meta = {
    description = "Host for Moonlight Streaming Client";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/loki-47-6F-64/sunshine";
  };
}
