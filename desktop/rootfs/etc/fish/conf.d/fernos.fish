# FernOS fish defaults. Per-user settings in ~/.config/fish take precedence.
status is-interactive; or return

set -q fish_color_command; or set -g fish_color_command 9BAE7D
set -q fish_color_param; or set -g fish_color_param EDE8D8
set -q fish_color_autosuggestion; or set -g fish_color_autosuggestion 788674
set -q fish_color_comment; or set -g fish_color_comment B8B9A5
set -q fish_color_error; or set -g fish_color_error D98A78

# Welcome screen: the FernOS tree + system info (/etc/xdg/fastfetch/config.jsonc).
# Turn it off with:  set -U fernos_quiet 1
# (or write your own ~/.config/fish/functions/fish_greeting.fish)
if not test -e ~/.config/fish/functions/fish_greeting.fish
    function fish_greeting
        if not set -q fernos_quiet; and command -q fastfetch
            fastfetch
        end
    end
end

# Colored man pages
if command -q bat
    set -gx MANROFFOPT -c
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

fish_add_path -g ~/.local/bin ~/.cargo/bin

# Listings with icons (eza)
if command -q eza
    alias ls 'eza -al --color=always --group-directories-first --icons=always'
    alias la 'eza -a --color=always --group-directories-first --icons=always'
    alias ll 'eza -l --color=always --group-directories-first --icons=always'
    alias lt 'eza -aT --color=always --group-directories-first --icons=always'
end

# Shortcuts
alias update 'sudo pacman -Syu'
alias fixpacman 'sudo rm /var/lib/pacman/db.lck'
alias grubup 'sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias big "expac -H M '%m\t%n' | sort -h | nl"
alias psmem 'ps auxf | sort -nr -k 4 | head -10'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias game 'fernos-mode game'
alias work 'fernos-mode work'
alias normal 'fernos-mode normal'
