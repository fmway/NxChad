{ internal, allModules, ... }:
{ lib, ... }:
{
  imports = allModules;
  luaLoader.enable = lib.mkDefault true;
  plugins.lsp = {
    servers.lua_ls = {
      cmd = lib.mkDefault [ "lua-language-server" ];
      filetypes = lib.mkDefault [ "lua" ];
      rootMarkers = lib.mkDefault [ ".luarc.json" ".luarc.jsonc" ".luacheckrc" ".stylua.toml" "stylua.toml" "selene.toml" "selene.yml" ".git" ];
    };
    servers.nixd = {
      cmd = lib.mkDefault ["nixd"];
      rootMarkers = lib.mkDefault [ "flake.nix" ".git" ];
      filetypes = lib.mkDefault [ "nix" ];
    };
  };
}
