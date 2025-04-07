oh-my-posh init pwsh --config ~/.config/oh-my-posh/powerlevel10k_lean.omp.json | Invoke-Expression

# Function to manage dotfiles
function config {
    git --git-dir=$HOME\.dotfiles --work-tree=$HOME $args
}

function venv { & .\.venv\Scripts\activate.ps1 }
