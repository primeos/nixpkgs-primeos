# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  wlroots = super.wlroots.overrideAttrs (oldAttrs: {
    name = "wlroots-unstable-2018-05-13";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "383ce3d5b73c54c3f9f1c90576df3277ebd2eee7";
      sha256 = "0qykhjx14aa1r4l0crzaprvg24ivjq8vsawanx7g4drkia0521cv";
    };
    meta = oldAttrs.meta // {
      broken = false;
    };
  });
  sway = super.sway.overrideAttrs (oldAttrs: rec {
    name = "sway-${version}";
    version = "1.0-alpha.2";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0578sw8spfg4fb2jkk0xdfb1jlyn80208lhnqmsjr10b0r2ql4g7";
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
      json_c pcre self.wlroots wayland xwayland libxkbcommon cairo pango
      gdk_pixbuf libcap libinput pam
      # TODO:
      mesa_noglu
      # dbus_libs #libXdmcp #libpthreadstubs
    ];
  });
}
