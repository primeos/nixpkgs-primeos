{ stdenv, wlroots, pkg-config, wayland
, wayland-protocols, libxkbcommon, systemd, libGL, libX11, pixman
}:

stdenv.mkDerivation {
  pname = "tinywl";
  version = wlroots.version;

  src = wlroots.src;

  nativeBuildInputs = [ pkg-config wayland ];
  buildInputs = [
    wayland-protocols wlroots libxkbcommon systemd libGL libX11 pixman
  ];

  buildPhase = "cd tinywl && make";

  installPhase = "install -Dt $out/bin tinywl";

  meta = with stdenv.lib; {
    description = ''
      The "minimum viable product" Wayland compositor based on wlroots
    '';
    longDescription = ''
      TinyWL is the "minimum viable product" Wayland compositor based on
      wlroots. It aims to implement a Wayland compositor in the fewest lines of
      code possible, while still supporting a reasonable set of features.
    '';
    homepage = "https://github.com/swaywm/wlroots/tree/${wlroots.version}/tinywl";
    license = licenses.cc0;
    platforms = platforms.unix;
    maintainers = with maintainers; [ primeos ];
  };
}
