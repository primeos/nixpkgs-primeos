# Primeos's (random) nixpkgs overlay
# This overlay isn't meant to be used directly (contains unstable and
# customized versions).
self: super:

{
  tinywl = super.callPackage ./pkgs/tinywl { };
}
