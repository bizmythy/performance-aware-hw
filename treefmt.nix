{
  pkgs,
  ...
}:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    jsonfmt.enable = true;
    shellcheck.enable = true;
    gofmt.enable = true;
    ruff.enable = true;
    yamlfmt.enable = true;
    toml-sort.enable = true;
    dos2unix.enable = true;
    keep-sorted.enable = true;
    zig = {
      enable = true;
      package = pkgs.zig_0_15;
    };
    # buggy as of right now
    # nufmt.enable = true;
  };

  settings = {
    # files to exlude from all formatting
    excludes = [
      "8086_Users_Manual"
    ];
    formatter = {
      # formatter-specific settings
    };
  };
}
