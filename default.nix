# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  meson471 = super.meson.overrideAttrs (oldAttrs: rec {
    name = pname + "-" + version;
    pname = "meson";
    version = "0.47.1";

    src = super.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "090vap8bckllg4k58j65jm6472qp53l49iacy0gpcykcxirjbxwp";
    };
  });
  wlroots = super.wlroots.overrideAttrs (oldAttrs: rec {
    name = "wlroots-unstable-2018-09-19";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "842368ec983cdf671cf16f5be51633392ed52d5e";
      sha256 = "0cnndpv0s6502s2a2a4nm2az752fkdzcpp6v973dn69gv9rijnyp";
    };
    # $out for the library, $bin for rootston, and $examples for the example
    # programs (in examples) AND rootston
    outputs = [ "out" "bin" "examples" ];
    mesonFlags = [
      "-Dlibcap=enabled" "-Dlogind=enabled" "-Dxwayland=enabled" "-Dx11-backend=enabled"
      "-Dxcb-icccm=enabled" "-Dxcb-xkb=enabled" "-Dxcb-errors=enabled"
    ];
    nativeBuildInputs = [ self.meson471 super.ninja super.pkgconfig ];
    buildInputs = (with super; [
      wayland libGL wayland-protocols libinput libxkbcommon
      pixman libcap mesa_noglu
      libpng ffmpeg_4 ])
      ++ (with super.xorg; [ xcbutilwm libX11 xcbutilimage xcbutilerrors ]);
    postInstall = ''
      # Install rootston (the reference compositor) to $bin and $examples
      for output in "$bin" "$examples"; do
        mkdir -p $output/bin
        cp rootston/rootston $output/bin/
        mkdir $output/lib
        cp libwlroots* $output/lib/
        patchelf \
          --set-rpath "$output/lib:${super.lib.makeLibraryPath buildInputs}" \
          $output/bin/rootston
        mkdir $output/etc
        cp ../rootston/rootston.ini.example $output/etc/rootston.ini
      done
      # Install ALL example programs to $examples:
      # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
      # screenshot output-layout multi-pointer rotation tablet touch pointer
      # simple
      mkdir -p $examples/bin
      for binary in $(find ./examples -executable -type f | grep -vE '\.so'); do
        patchelf \
          --set-rpath "$examples/lib:${super.lib.makeLibraryPath buildInputs}" \
          "$binary"
        cp "$binary" $examples/bin/
      done
    '';
    meta = oldAttrs.meta // {
      broken = false;
    };
  });
  sway = super.sway.overrideAttrs (oldAttrs: rec {
    name = "sway-${version}";
    version = "1.0-alpha.6";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0358c4ga8jm45apqck1y3hqws4qxnsf8z8r881q905b9g54nli8k";
    };
    postPatch = ''
      substituteInPlace meson.build --replace \
        "werror=true" "werror=false"
    '';
    mesonFlags = [ "-Dsway-version=${version}" ];
    nativeBuildInputs = with super; [
      meson pkgconfig ninja
      # ++ stdenv.lib.optional buildDocs
      scdoc
    ];
    buildInputs = with super; [
      json_c pcre self.wlroots wayland xwayland
      libxkbcommon cairo pango gdk_pixbuf libcap libinput pam
      # TODO:
      mesa_noglu
      # dbus_libs #libXdmcp #libpthreadstubs
    ];
  });
}
