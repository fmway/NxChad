{
  plugins.telescope = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings = {
      cmd = "Telescope";
    };
    settings = {
      defaults = {
        prompt_prefix = "   ";
        selection_caret = " ";
        entry_prefix = " ";
        sorting_strategy = "ascending";
        layout_config = {
          horizontal = {
            prompt_position = "top";
            preview_width = 0.55;
          };
          width = 0.87;
          height = 0.80;
        };
      };
    };
  };
}
