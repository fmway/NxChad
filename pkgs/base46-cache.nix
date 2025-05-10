{ vimPlugins
, stdenvNoCC
, writeText
, neovim
, chadrc ? {}
, helpers
, ... }:
let
  inherit (vimPlugins) base46 nvchad-ui;
  chadrc-lua = writeText "chadrc.lua" /* lua */ ''
    local M = ${helpers.toLuaObject chadrc}
    return M
  '';
in stdenvNoCC.mkDerivation (finalAttrs: {
  src = base46;
  pname = "base46-cache";
  inherit (base46) version;

  buildInputs = [
    neovim
  ];

  buildPhase = ''
    cp ${chadrc-lua} lua/chadrc.lua
    mkdir cache
    substituteInPlace lua/base46/init.lua \
      --replace-warn "cache_path = vim.g.base46_cache" 'cache_path = "'$PWD/cache'/"' \
      --replace-warn "if not vim.uv.fs_stat(vim.g.base46_cache) then" "if false then" \
      --replace-warn "loadstring" "load"
    nvim +":lua package.path = package.path .. \";$PWD/lua/?.lua;$PWD/lua/?/init.lua;${nvchad-ui.outPath}/lua/?.lua;${nvchad-ui.outPath}/lua/?/init.lua\"" -l <(echo "require(\"base46\").compile()")
  '';

  installPhase = ''
    mkdir $out
    cp -r cache/* $out
  '';
})
