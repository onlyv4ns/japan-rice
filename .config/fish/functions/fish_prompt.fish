function fish_prompt
    set -l pink   (set_color ff5e7d)
    set -l purple (set_color 7aa2f7)
    set -l cyan   (set_color c0caf5)
    set -l normal (set_color normal)

    echo -n $pink$USER$normal@$purple"bspwm"$normal" "$cyan(prompt_pwd)$normal
    echo
    echo -n $pink"❯ "$normal
end
