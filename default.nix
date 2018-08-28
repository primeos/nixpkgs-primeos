# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  wlroots = super.wlroots.overrideAttrs (oldAttrs: rec {
    name = "wlroots-unstable-2018-08-11";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "4ed6ee0a4d112711c3764b9b5d0d44ec916fb48a";
      sha256 = "02z52s50whlzw4ard9r90xiiadhhax6iiap33xm4d2bfjbds8fjx";
    };
    # $out for the library, $bin for rootston, and $examples for the example
    # programs (in examples) AND rootston
    outputs = [ "out" "bin" "examples" ];
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
    version = "1.0-alpha.5";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0v2fnvx9z1727cva46j4zrlph8wwvkgb1gqgy9hzizbwixf387sl";
    };
    postPatch = ''
      substituteInPlace meson.build --replace \
        "werror=true" "werror=false"
    '';
    mesonFlags = [ "-Dsway_version=${version}" ];
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
