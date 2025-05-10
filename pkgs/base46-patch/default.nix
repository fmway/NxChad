{ vimPlugins, ... }:
vimPlugins.base46.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    ./000-to-the-point.patch
  ];
})
