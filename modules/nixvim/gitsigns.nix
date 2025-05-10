{
  plugins.gitsigns = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = "User FilePost";
    settings = {
      signs.delete.text = "󰍵";
      signs.changedelete.text = "󱕖";
    };
  };
}
