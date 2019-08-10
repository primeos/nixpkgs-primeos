# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  sway = super.sway.overrideAttrs (oldAttrs: rec {
    name = "sway-${version}";
    version = "1.2-rc1";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "1f2k39c4kbwxxy65qbz85bm1pf9nmgn7az90qjds9hi3m1ff5q4y";
    };
    postPatch = ''
      sed -iE "s/version: '1.1'/version: '${version}'/" meson.build
    '';
  });
}
