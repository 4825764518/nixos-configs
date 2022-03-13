{ stdenv, lib, fetchFromGitHub, boost, cmake, ffmpeg, libcap, libdrm, libevdev
, libopus, libpulseaudio, libxkbcommon, linuxHeaders, openssl, pkg-config, udev
, xorg, wayland }:

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

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    boost
    ffmpeg
    libcap
    libdrm
    libevdev
    libopus
    libpulseaudio
    libxkbcommon
    linuxHeaders
    openssl
    udev
    xorg.libX11
    xorg.libxcb
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
    wayland
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
    --replace '/usr/include/libevdev-1.0' "$(pkg-config --cflags libevdev | cut -c 3-)" \
    --replace "set(Boost_USE_STATIC_LIBS ON)" "set(Boost_USE_STATIC_LIBS OFF)"
  '';

  meta = {
    description = "Host for Moonlight Streaming Client";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/loki-47-6F-64/sunshine";
  };
}
