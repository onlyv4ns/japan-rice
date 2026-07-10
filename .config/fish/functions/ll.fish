function ll --description 'eza -l with icons (eza with no args prints nothing, so default to .)'
    if test (count $argv) -eq 0
        eza --icons -l .
    else
        eza --icons -l $argv
    end
end
