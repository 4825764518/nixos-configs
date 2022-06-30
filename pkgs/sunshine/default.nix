{ stdenv, lib, fetchFromGitHub, avahi, boost, cmake, cudaSupport ? false, cudatoolkit, ffmpeg, libcap, libdrm, libevdev
, libopus, libpulseaudio, libxkbcommon, linuxHeaders, openssl, pkg-config, udev
, xorg, wayland }:

let
  src = fetchFromGitHub {
    owner = "loki-47-6F-64";
    repo = "sunshine";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-XVecR365Xm2iR5JbGTAQERK0u+bmSxt/BQY1r885jr8=";
  };
  version = "0.11.1";
in stdenv.mkDerivation {
  pname = "sunshine";
  inherit src version;

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    avahi
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
  ] ++ (lib.optional cudaSupport cudatoolkit);

  cmakeFlags = [ ''-DSUNSHINE_ASSETS_DIR=$(out)/assets'' ];

  patches = [ ./0001-add-install-rules.patch ];
  postPatch = ''
    substituteInPlace CMakeLists.txt \
    --replace '/usr/include/libevdev-1.0' "$(pkg-config --cflags libevdev | cut -c 3-)" \
    --replace "set(Boost_USE_STATIC_LIBS ON)" "set(Boost_USE_STATIC_LIBS OFF)"
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 sunshine "$out"/bin/sunshine

    # Copy assets
    mkdir -p $out/assets
    cp -r ${src}/assets/* $out/assets/
  '';

  meta = {
    description = "Host for Moonlight Streaming Client";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/loki-47-6F-64/sunshine";
  };
}
