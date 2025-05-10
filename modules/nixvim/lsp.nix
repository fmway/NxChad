{ internal, lib, ... }: let
  inherit (lib.nixvim) mkRawFn nKeymap' nvKeymap' toLuaObject;
in
{ lib, config, pkgs, ... }:
{
  _file = ./default.nix;
  plugins.lsp = {
    enable = true;
    servers.lua_ls = {
      enable = true;
      settings = {
        diagnostics.globals = [ "vim" ];
        workspace.library = [
          { __raw = ''vim.fn.expand "$VIMRUNTIME/lua"''; }
          "${pkgs.vimPlugins.nvchad-ui}/nvchad_types"
          "\${3rd}/luv/library"
        ];
      };
    };
    servers.nixd.enable = true;
    inlayHints = true;
    lazyLoad.enable = true;
    lazyLoad.settings = {
      event = "User FilePost";
      cmd = [ "LspRestart" "LspLog" "LspInfo" "LspStart" "LspStop" ];
    };
    keymaps.lspBuf = {
      "gD" = "declaration";
      "gd" = "definition";
      "gi" = "implementation";
      "gr" = "references";
      "<leader>sh" = "signature_help";
      "<leader>wa" = "add_workspace_folder";
      "<leader>wr" = "remove_workspace_folder";
      "<leader>D" = "type_definition";
    };

    keymaps.extra = [
      (nvKeymap' "<leader>ca" {
        __raw = "vim.lsp.buf.code_action";
      } "Code action")
      (nKeymap' "<leader>wl" (mkRawFn ''
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      '') "List workspace folders")
    ];

    setupWrappers = let
      capabilities = toLuaObject {
        textDocument.completion.completionItem = {
          documentationFormat = [ "markdown" "plaintext" ];
          snippetSupport = true;
          preselectSupport = true;
          insertReplaceSupport = true;
          labelDetailsSupport = true;
          deprecatedSupport = true;
          commitCharactersSupport = true;
          tagSupport = { valueSet = [ 1 ]; };
          resolveSupport = {
            properties = [
              "documentation"
              "detail"
              "additionalTextEdits"
            ];
          };
        };
      };
    in [
      (str: /* lua */ ''
        vim.tbl_deep_extend("force", {
          on_init = function(client, _)
            if client.supports_method "textDocument/semanticTokens" then
              client.server_capabilities.semanticTokensProvider = nil
            end
          end,
          capabilities = ${capabilities}
        }, ${str})
      '')
    ];
  };
}
