# -----------------------------------------------------
# INIT
# -----------------------------------------------------

set -U fish_greeting ""

# -----------------------------------------------------
# Exports
# -----------------------------------------------------
export EDITOR=nvim

if test -d /usr/lib/ccache/bin
    contains /usr/lib/ccache/bin/ $fish_user_paths; or set -g -a fish_user_paths /usr/lib/ccache/bin/
end
contains $HOME/.cargo/bin/ $fish_user_paths; or set -g -a fish_user_paths $HOME/.cargo/bin/
contains $HOME/.local/bin/ $fish_user_paths; or set -g -a fish_user_paths $HOME/.local/bin/
