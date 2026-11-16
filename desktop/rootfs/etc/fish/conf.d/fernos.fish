# FernOS fish defaults. Per-user settings in ~/.config/fish take precedence.
status is-interactive; or return

set -g fish_greeting
set -q fish_color_command; or set -g fish_color_command 9BAE7D
set -q fish_color_param; or set -g fish_color_param EDE8D8
set -q fish_color_autosuggestion; or set -g fish_color_autosuggestion 788674
set -q fish_color_comment; or set -g fish_color_comment B8B9A5
set -q fish_color_error; or set -g fish_color_error D98A78
