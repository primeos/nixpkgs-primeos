# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  sway = super.sway.overrideAttrs (oldAttrs: rec {
    name = "sway-${version}";
    version = "1.2-rc2";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0bqw246iyrpir2hl3sl6k2wkkzi0cypslsla59a77s9s7gnzymdw";
    };
    postPatch = ''
      sed -iE "s/version: '1.1'/version: '${version}'/" meson.build
    '';
  });
}
