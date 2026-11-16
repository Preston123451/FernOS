# FernOS prompt:  user@host ~/path (git-branch) ❯
# Override by creating ~/.config/fish/functions/fish_prompt.fish or running fish_config.
function fish_prompt
    set -l last_status $status
    set -l arrow_color 9BAE7D
    test $last_status -ne 0; and set arrow_color D98A78

    if fish_is_root_user
        set_color D4B483
    else
        set_color 82966B
    end
    printf '%s@%s ' $USER (prompt_hostname)

    set_color EDE8D8
    printf '%s' (prompt_pwd)
    set_color B8B9A5
    printf '%s' (fish_vcs_prompt ' (%s)')

    set_color $arrow_color
    printf ' ❯ '
    set_color normal
end
