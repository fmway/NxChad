{ internal, lib, ... }: let
  inherit (lib.nixvim) mkRawFn;
in { lib, config, ... }:
{
  plugins.friendly-snippets.enable = config.plugins.luasnip.enable;
  plugins.cmp_luasnip.enable = config.plugins.luasnip.enable;
  plugins.luasnip = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings = {
      event = "InsertEnter";
      after = mkRawFn /* lua */ ''
        ${config.plugins.luasnip.luaConfig.content}
        vim.api.nvim_create_autocmd("InsertLeave", {
          callback = function()
            if
              require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
              and not require("luasnip").session.jump_active
            then
              require("luasnip").unlink_current()
            end
          end,
        })
      '';
    };
    fromVscode = [
      { exclude.__raw = /* lua */ "vim.vscode_snippets_exclude or {}"; }
      { paths.__raw = /* lua */ "vim.g.vscode_snippets_path or \"\""; }
    ];
    fromSnipmate = [
      { paths.__raw = /* lua */ "vim.g.snipmate_snippets_path or \"\""; }
    ];
    fromLua = [
      { paths.__raw = /* lua */ "vim.g.lua_snippets_path or \"\""; }
    ];
    settings = {
      update_events = [ "TextChanged" "TextChangedI" ];
      link_roots = true;
    };
  };
}
