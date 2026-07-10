function la --description 'eza -la with icons (eza with no args prints nothing, so default to .)'
    if test (count $argv) -eq 0
        eza --icons -la .
    else
        eza --icons -la $argv
    end
end
