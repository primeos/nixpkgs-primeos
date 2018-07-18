# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  wlroots = super.wlroots.overrideAttrs (oldAttrs: rec {
    name = "wlroots-unstable-2018-07-17";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "2a58d4467f83c5660bbee6733a73cc1ed92ca478";
      sha256 = "16h59jglnn1y4h0q71200i429pl1qv3b93ygr7zkvzpsgnm9vci0";
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
    version = "1.0-alpha.4";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0ki6f2b2z4fi8jibdaggjfzs4xaw3zllvc4k4la4rj55kbq7m64c";
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
