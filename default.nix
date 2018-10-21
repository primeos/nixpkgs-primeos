# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  meson480 = super.meson.overrideAttrs (oldAttrs: rec {
    name = pname + "-" + version;
    pname = "meson";
    version = "0.48.0";

    src = super.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0qawsm6px1vca3babnqwn0hmkzsxy4w0gi345apd2qk3v0cv7ipc";
    };
    patches = builtins.filter # Remove gir-fallback-path.patch
      (str: !(super.lib.hasSuffix "gir-fallback-path.patch" str))
      oldAttrs.patches;
  });
  wlroots = super.wlroots.overrideAttrs (oldAttrs: rec {
    name = "wlroots-${version}";
    version = "0.1";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = version;
      sha256 = "0xfipgg2qh2xcf3a1pzx8pyh1aqpb9rijdyi0as4s6fhgy4w269c";
    };
    patches = [ (super.fetchpatch { # TODO: Only for version 0.1
      url = https://github.com/swaywm/wlroots/commit/be6210cf8216c08a91e085dac0ec11d0e34fb217.patch;
      sha256 = "0njv7mr4ark603w79cxcsln29galh87vpzsx2dzkrl1x5x4i6cj5";
    }) ];
    # $out for the library, $bin for rootston, and $examples for the example
    # programs (in examples) AND rootston
    outputs = [ "out" "bin" "examples" ];
    mesonFlags = [
      "-Dlibcap=enabled" "-Dlogind=enabled" "-Dxwayland=enabled" "-Dx11-backend=enabled"
      "-Dxcb-icccm=enabled" "-Dxcb-xkb=enabled" "-Dxcb-errors=enabled"
    ];
    nativeBuildInputs = [ self.meson480 super.ninja super.pkgconfig ];
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
    version = "1.0-beta.1";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0h9kgrg9mh2acks63z72bw3lwff32pf2nb4i7i5xhd9i6l4gfnqa";
    };
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
