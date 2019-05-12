# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  wlroots = super.wlroots.overrideAttrs (oldAttrs: rec {
    name = "wlroots-${version}";
    version = "0.6.0";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = version;
      sha256 = "1rdcmll5b8w242n6yfjpsaprq280ck2jmbz46dxndhignxgda7k4";
    };
    buildInputs = oldAttrs.buildInputs ++ [ super.freerdp ];
    mesonFlags = oldAttrs.mesonFlags ++ [ "-Dfreerdp=enabled" ];
    postPatch = "";
  });
}
