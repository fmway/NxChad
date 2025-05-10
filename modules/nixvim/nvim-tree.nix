{
  plugins.nvim-tree = {
    enable = true;
    filters.dotfiles = false;
    disableNetrw = true;
    hijackCursor = true;
    syncRootWithCwd = true;
    updateFocusedFile.enable = true;
    updateFocusedFile.updateRoot = false;
    view.width = 30;
    view.preserveWindowProportions = true;
    renderer = {
      rootFolderLabel = false;
      highlightGit = true;
      indentMarkers.enable = true;
      icons.glyphs = {
        default = "󰈚";
        folder = {
          default = "";
          empty = "";
          emptyOpen = "";
          open = "";
          symlink = "";
        };
        git.unmerged = "";
      };
    };
  };
}
