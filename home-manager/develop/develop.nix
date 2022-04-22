{ pkgs, config, ... }:
let
  rust-env = pkgs.fenix.combine (with pkgs.fenix.complete; [
    cargo
    clippy-preview
    rust-std
    rustc
    rustfmt-preview
    rust-src
    rust-docs
    rust-analyzer-preview
    rust-analysis
    miri-preview
    rls-preview
  ]);
  python3-env = pkgs.python3.withPackages (ps:
    with ps; [
      pynvim
      numpy
      # pytorchWithCuda
      # tensorflowWithCuda
      pandas
      matplotlib
      django
      pygobject3
      ipython
      pylint
      jedi
      pip
      setuptools
    ]);
in
{
  imports = [ ./git.nix ./vscode.nix ];
  programs.go = {
    enable = true;
    goBin = ".local/bin.go";
    goPath = "工作空间/Go";
  };
  home.file.".pip/pip.conf".text = ''
    [global]
    index-url = https://pypi.mirrors.ustc.edu.cn/simple
  '';
  home.file.".config/direnv/direnvrc".text = ''
    use_flake() {
      watch_file flake.nix
      watch_file flake.lock
      eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
    }
  '';
  home.sessionVariables = with pkgs; {
    RUSTUP_DIST_SERVER = "http://mirrors.ustc.edu.cn/rust-static";
    RUSTUP_UPDATE_ROOT = "http://mirrors.ustc.edu.cn/rust-static/rustup";
    RUST_BACKTRACE = "1";
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
    # PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$PATH";
  };
  home.packages = with pkgs; [
    rnix-lsp
    nixfmt
    x11docker
    socat
    pandoc
    devtodo
    graphviz
    httpie
    curlie
    highlight
    xlsx2csv
    inotify-tools

    pkg-config
    ctags
    global
    gnumake
    ninja
    cmake
    unstable.clang-tools
    # clang
    libcxx
    clang-analyzer
    ccls
    # gcc-unwrapped
    llvm
    rust-env

    fzf
    ptags
    global
    file

    timewarrior
    taskwarrior
    taskwarrior-tui

    sumneko-lua-language-server
    nodePackages.typescript-language-server
    nodejs
    nodePackages.typescript
    nodePackages.pyright
    cmake-language-server
    lua5_4

    jdk
    maven
    gradle

    docker-compose
    beekeeper-studio
    k9s
    kubectl
    kubernetes-helm

    new-unstable.wangzi-neovim
    neovim-remote
    python2
    luajitPackages.luacheck
    google-java-format
    stylua
    shfmt
    shellcheck
    deno
    nodePackages.live-server
    nodePackages.yaml-language-server

    (pkgs.buildEnv {
      name = "cpp_compiler";
      paths = with pkgs;[
        clang
        gcc
        gdb
        lldb
        bintools-unwrapped
        python3-env
      ];
      ignoreCollisions = true;
    })
  ];
}
