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
  sway = super.sway.overrideAttrs (oldAttrs: rec {
    name = "sway-${version}";
    version = "1.1-rc1";
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "036gx8zzsfhj89w8i7vdmzcw18b0220l2wg1pqmspk006hbd4sd6";
    };
    patches = builtins.filter
      (str: !(super.lib.hasSuffix "bcde298a719f60b9913133dbd2a169dedbc8dd7d.patch" str))
      oldAttrs.patches;
    postPatch = ''
      sed -iE "s/version: '1.0'/version: '${version}'/" meson.build
    '';
  });
}
