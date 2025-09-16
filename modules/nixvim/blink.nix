{ lib, config, pkgs, ... }:
{
  _file = ./blink.nix;
  plugins = {
    blink-compat.enable = config.plugins.blink-cmp.enable;
    blink-compat.lazyLoad.enable = true;
    blink-compat.lazyLoad.settings.cmd = [];
  };
  plugins.blink-cmp = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = "InsertEnter";
    setupLspCapabilities = true;
    settings = {
      cmdline.enabled = true;
      completion = {
        keyword.range = "full";
        accept.auto_brackets.enabled = true;
        accept.auto_brackets.semantic_token_resolution.enabled = false;
        trigger = {
          show_in_snippet = true;
          show_on_trigger_character = true;
        };
        ghost_text.enabled = true;
        documentation.auto_show = true;
        documentation.update_delay_ms = 100;
        documentation.window.border = "single";
      };
      signature.enabled = true;

      sources = {
        default = [ "lsp" "path" "snippets" "buffer" ];
      };
      snippets = lib.mkIf config.plugins.luasnip.enable {
        preset = "luasnip";
      };

      keymap = {
        "<C-p>" = [
          "select_prev"
          "fallback"
        ];
        "<C-n>" = [
          "select_next"
          "fallback"
        ];
        "<C-d>" = [
          "scroll_documentation_down"
          "fallback"
        ];
        "<C-f>" = [
          "scroll_documentation_up"
          "fallback"
        ];
        "<C-e>" = [ "hide" ];
        "<C-space>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<C-y>" = [ "select_and_accept" ];
        "<CR>" = [
          "accept"
          "fallback"
        ];
        "<Tab>" = [
          "select_next"
          "snippet_forward"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "snippet_backward"
          "fallback"
        ];
      };
    };
  };
}
