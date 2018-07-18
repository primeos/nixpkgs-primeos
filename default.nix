# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  # Until f43da349ba0722784ad7088ddddd4812a7fa9990 is in nixos-unstable
  wayland_1_15 = super.wayland.overrideAttrs (oldAttrs: rec {
    name = "wayland-${version}";
    version = "1.15.0";
    src = super.fetchurl {
      url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
      sha256 = "1c5fnys8hi71cnzjv5k7j0r8gx80p0yyqlrpmn06mmarhnxvwgzb";
    };
  });
  # Until 280fba591d8839919110081839b542133a5dbf9a is in nixos-unstable
  wayland-protocols_1_14 = super.wayland.overrideAttrs (oldAttrs: rec {
    name = "wayland-protocols-${version}";
    version = "1.14";
    src = super.fetchurl {
      url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
      sha256 = "1xknjcfhqvdi1s4iq4kk1q61fg2rar3g8q4vlqarpd324imqjj4n";
    };
    buildInputs = [ self.wayland_1_15 ];
  });
  xwayland_sway = super.lib.overrideDerivation super.xorg.xorgserver (oldAttrs: {
    name = "xwayland-${super.xorg.xorgserver.version}";
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs
      ++ [ self.wayland_1_15 self.wayland-protocols_1_14 ]
      ++ (with super; [ epoxy libxslt makeWrapper libunwind ]);
    configureFlags = [
      "--disable-docs"
      "--disable-devel-docs"
      "--enable-xwayland"
      "--disable-xorg"
      "--disable-xvfb"
      "--disable-xnest"
      "--disable-xquartz"
      "--disable-xwin"
      "--enable-glamor"
      "--with-default-font-path="
      "--with-xkb-bin-directory=${super.xorg.xkbcomp}/bin"
      "--with-xkb-path=${super.xkeyboard_config}/etc/X11/xkb"
      "--with-xkb-output=$(out)/share/X11/xkb/compiled"
    ];
    postInstall = ''
      rm -fr $out/share/X11/xkb/compiled
    '';
  }) // {
    meta = with super.lib; {
      description = "An X server for interfacing X11 apps with the Wayland protocol";
      homepage = http://wayland.freedesktop.org/xserver.html;
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
  wlroots = super.wlroots.overrideAttrs (oldAttrs: {
    name = "wlroots-unstable-2018-07-17";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "2a58d4467f83c5660bbee6733a73cc1ed92ca478";
      sha256 = "16h59jglnn1y4h0q71200i429pl1qv3b93ygr7zkvzpsgnm9vci0";
    };
    buildInputs = (with super; [
      self.wayland_1_15 libGL self.wayland-protocols_1_14 libinput libxkbcommon
      pixman libcap mesa_noglu ])
      ++ (with super.xorg; [ xcbutilwm libX11 xcbutilimage xcbutilerrors ]);
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
    ]; #++ stdenv.lib.optional buildDocs [ asciidoc libxslt docbook_xsl ];
    # TODO: Replace asciidoc with scdoc
    buildInputs = with super; [
      json_c pcre self.wlroots self.wayland_1_15 self.xwayland_sway
      libxkbcommon cairo pango gdk_pixbuf libcap libinput pam
      # TODO:
      mesa_noglu
      # dbus_libs #libXdmcp #libpthreadstubs
    ];
  });
}
