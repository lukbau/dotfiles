#!/bin/bash



backup_home_item() {
    local item="$1"
    local home_dir="$HOME"
    local backup_dir="$home_dir/.bak"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if HOME exists and argument is given
    if [[ -z "$item" ]]; then
        echo "Usage: backup_home_item <relative_path_to_item_in_HOME>"
        return 1
    fi

    if [[ ! -d "$home_dir" ]]; then
        echo "HOME directory does not exist."
        return 1
    fi

    # Ensure backup directory exists
    mkdir -p "$backup_dir"

    local target_in_home="$home_dir/$item"
    local backup_target="$backup_dir/$item"
    local source_in_script_dir="$script_dir/$item"

    # Check if source exists
    if [[ ! -e "$source_in_script_dir" ]]; then
        echo "Source item '$source_in_script_dir' does not exist."
        return 1
    fi

    cp -ar "$source_in_script_dir" "$backup_target"

    echo "Backed up '$item' from script directory to '$backup_target'."
}


install_ohmyzsh_plugin() {
    local plugin_repo="$1"
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins"

    # Check if plugin repo URL was provided
    if [[ -z "$plugin_repo" ]]; then
        echo "Usage: install_ohmyzsh_plugin <git_repo_url>"
        return 1
    fi

    # Check if plugin directory exists
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Directory '$plugin_dir' does not exist. Is Oh My Zsh installed?"
        return 1
    fi

    # Check if git is installed
    if ! command -v git >/dev/null 2>&1; then
        echo "Git is not installed. Please install git to proceed."
        return 1
    fi

    # Extract plugin name from repo URL (last part, without .git)
    local plugin_name
    plugin_name="$(basename -s .git "$plugin_repo")"

    local target_dir="$plugin_dir/$plugin_name"

    # If already exists, skip
    if [[ -d "$target_dir" ]]; then
        echo "Plugin '$plugin_name' already exists at '$target_dir'."
        return 0
    fi

    # Clone the plugin
    git clone "$plugin_repo" "$target_dir"

    if [[ $? -eq 0 ]]; then
        echo "Successfully installed '$plugin_name' into '$target_dir'."
    else
        echo "Failed to clone plugin from '$plugin_repo'."
        return 1
    fi
}


# check if zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "Zsh is not installed. Exiting script."
  exit 1
else
  echo "Zsh is installed. Switching to Zsh..."
  exec zsh
fi


# install oh my zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# copy zsh and tmux config
backup_home_item(".zshrc")
backup_home_item(".tmux.conf")

#install oh my zsh plugins

install_ohmyzsh_plugin("https://github.com/zdharma-continuum/fast-syntax-highlighting.git")
install_ohmyzsh_plugin("https://github.com/marlonrichert/zsh-autocomplete.git")
install_ohmyzsh_plugin("https://github.com/zsh-users/zsh-autosuggestions.git")
install_ohmyzsh_plugin("https://github.com/zsh-users/zsh-syntax-highlighting.git")

#change login shell
chsh -s /bin/zsh 
