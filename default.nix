# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  wlroots = super.wlroots.overrideAttrs (oldAttrs: {
    name = "wlroots-unstable-2018-04-08";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "ba5c0903f9c288e7b617e537ef80eed2a42e08ed";
      sha256 = "0jldmp5zgndyiz9bqxxck60910gb1i42pgfzvaxh97rgj4jhhkz8";
    };
    meta = oldAttrs.meta // {
      broken = false;
    };
  });
  sway = super.sway.overrideAttrs (oldAttrs: rec {
    name = "sway-${version}";
    version = "1.0-alpha.1";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0nbl8py2bra5px86z71v0fh3gnmh877a0nn9lbxnrw5zwcys5b46";
    };
    patches = [
      ./sway.patch
      (self.fetchpatch {
        name = "set-POSIX-C-SOURCE-properly.patch";
        url = "https://github.com/swaywm/sway/pull/1815/commits/0d67d56c2ab10573e8d19f4e330303215d2aef69.patch";
        sha256 = "0x093p0rakxr6mbdmcgzn0hlqxpm35gymh0rwjfzwjbq6j85mdjz";
      })
    ];
    postPatch = ''
      substituteInPlace meson.build --replace \
        "werror=true" "werror=false"
    '';
    mesonFlags = [ "-Dsway_version=${version}" ];
    nativeBuildInputs = with super; [
      meson pkgconfig ninja
    ]; #++ stdenv.lib.optional buildDocs [ asciidoc libxslt docbook_xsl ];
    buildInputs = with super; [
      json_c pcre self.wlroots wayland xwayland libxkbcommon cairo pango
      gdk_pixbuf libcap libinput pam
      # TODO:
      mesa_noglu
      # dbus_libs #libXdmcp #libpthreadstubs
    ];
  });
}
