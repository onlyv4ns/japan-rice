function ls --description 'eza with icons (eza with no args prints nothing, so default to .)'
    if test (count $argv) -eq 0
        eza --icons .
    else
        eza --icons $argv
    end
end
