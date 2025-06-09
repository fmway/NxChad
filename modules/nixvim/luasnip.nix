{ lib, config, ... }:
{
  plugins.friendly-snippets.enable = config.plugins.luasnip.enable;
  plugins.cmp_luasnip.enable = config.plugins.luasnip.enable;
  plugins.luasnip = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = "InsertEnter";
    fromVscode = [
      { exclude.__raw = "vim.vscode_snippets_exclude or {}"; }
      { paths.__raw = "vim.g.vscode_snippets_path or \"\""; }
    ];
    fromSnipmate = [
      { paths.__raw = "vim.g.snipmate_snippets_path or \"\""; }
    ];
    fromLua = [
      { paths.__raw = "vim.g.lua_snippets_path or \"\""; }
    ];
    settings = {
      update_events = [ "TextChanged" "TextChangedI" ];
      link_roots = true;
    };
  };
}
