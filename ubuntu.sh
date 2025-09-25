#!/bin/bash
#set -x
set -euo pipefail

installed=""
not_installed=""

install_brave()
{
    echo Installing BRAVE
    sudo apt install curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update -y -q
    sudo apt install -y -q brave-browser 
    installed+="Brave\n"
}

set_dark_theme()
{
    echo "Setting up theme to Yaru-dark"
    declare release
    release="$(lsb_release -r | awk -F '\t' '{print $2}')"
    if [[ "${release}" = "20.04" ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    elif [[ "${release}" = "22.04" ]] || [[ "${release}" = "24.04" ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark # Legacy apps, can specify an accent such as Yaru-olive-dark
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark # new apps
        installed+="Dark Theme\n"

    else
        echo "Cannot setup theme for Ubuntu ${release}!"
        not_installed+="Dark Theme\n"
    fi
}

install_oh_my_zsh()
{
    if [[ ! -d "$HOME/.oh-my-zsh" ]]
    then
    {
        echo "Installing oh-my-zsh"
        wget --no-cache -O "$HOME/.zshrc" "https://raw.githubusercontent.com/manuelgustavo/ubuntu-setup/main/.zshrc"
        sudo apt-get install -y -q zsh fonts-powerline
        # chsh -s "$(which zsh)"
        #sudo apt-get install -y -q zsh-autosuggestions zsh-syntax-highlighting
        # install oh-my-zsh
        rm -fr "$HOME/.oh-my-zsh"
        sh -c "$(wget --no-cache -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --skip-chsh --keep-zshrc"
        git clone --quiet --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone --quiet --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone --quiet --depth 1 https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open
        
        # Change the default shell
        sudo sed -i -E "s/($USER.*)(bash)/\1zsh/" /etc/passwd
        sudo update-passwd
        installed+="oh-my-zsh\n"
    }
    else
    {
        echo "If you want to install oh-my-zsh, delete the ~/.oh-my-zsh directory"
        not_installed+="oh-my-zsh\n"
    }
    fi
}

install_extension()
{
    gdbus call --session \
                --dest org.gnome.Shell.Extensions \
                --object-path /org/gnome/Shell/Extensions \
                --method org.gnome.Shell.Extensions.InstallRemoteExtension \
                "${1}" 2>/dev/null || true
}

install_gnome_extensions()
{
    sudo apt-get install -y -q \
            gnome-tweaks \
            gnome-shell-extensions \
            chrome-gnome-shell \
            gir1.2-gtop-2.0 \
            gir1.2-nm-1.0 \
            gir1.2-clutter-1.0 \
            gnome-system-monitor

    declare gnome_extension

    gnome_extension="dash-to-panel@jderose9.github.com"
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/${gnome_extension}" ]]
    then
    {
        echo "Installing Gnome Extension -- Dash to Panel https://extensions.gnome.org/extension/1160/dash-to-panel/"
        install_extension "${gnome_extension}"
        dconf write /org/gnome/shell/extensions/dash-to-panel/trans-use-custom-opacity true
        dconf write /org/gnome/shell/extensions/dash-to-panel/trans-panel-opacity 0.4
        installed+="Gnome Extension -- Dash to Panel\n"
    }
    else
    {
        echo "Skipping Dash to Panel -- already installed."
        not_installed+="Gnome Extension -- Dash to Panel\n"
    }
    fi

    gnome_extension="system-monitor-next@paradoxxx.zero.gmail.com"
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/${gnome_extension}" ]]
    then
    {
        echo "Installing Gnome Extension -- system-monitor-next https://extensions.gnome.org/extension/3010/system-monitor-next/"
        install_extension "${gnome_extension}"
        installed+="Gnome Extension -- system-monitor-next\n"
    }
    else
    {
        echo "Skipping system-monitor-next -- already installed."
        not_installed+="Gnome Extension -- system-monitor-next\n"
    }
    fi

    gnome_extension="drive-menu@gnome-shell-extensions.gcampax.github.com"
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/${gnome_extension}" ]]
    then
    {
        echo "Installing Gnome Extension -- Removable Drive Menu https://extensions.gnome.org/extension/7/removable-drive-menu/"
        install_extension "${gnome_extension}"
        installed+="Gnome Extension -- Removable Drive Menu\n"
    }
    else
    {
        echo "Skipping Removable Drive Menu -- already installed."
        not_installed+="Gnome Extension -- Removable Drive Menu\n"
    }
    fi

    gnome_extension="burn-my-windows@schneegans.github.com"
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/${gnome_extension}" ]]
    then
    {
        echo "Installing Gnome Extension -- Burn My Windows https://extensions.gnome.org/extension/7/removable-drive-menu/"
        install_extension "${gnome_extension}"
        mkdir -p "$HOME/.config/burn-my-windows/profiles"
        echo "[burn-my-windows-profile]" > "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        echo "fire-enable-effect=false" >> "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        echo "glitch-enable-effect=true" >> "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        echo "glitch-animation-time=400" >> "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        echo "tv-enable-effect=true" >> "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        echo "tv-glitch-enable-effect=true" >> "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        echo "tv-glitch-animation-time=400" >> "$HOME/.config/burn-my-windows/profiles/1758807011312850.conf"
        installed+="Gnome Extension -- Burn My Windows\n"
    }
    else
    {
        echo "Skipping Burn My Windows -- already installed."
        not_installed+="Gnome Extension -- Burn My Windows\n"
    }
    fi

    gnome_extension="arcmenu@arcmenu.com"
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/${gnome_extension}" ]]
    then
    {
        echo "Installing Gnome Extension -- ArcMenu https://extensions.gnome.org/extension/7/removable-drive-menu/"
        install_extension "${gnome_extension}"
        installed+="Gnome Extension -- ArcMenu\n"
    }
    else
    {
        echo "Skipping ArcMenu -- already installed."
        not_installed+="Gnome Extension -- ArcMenu\n"
    }
    fi
}

install_tilix()
{
    sudo apt-get -y -q install tilix
    wget --no-cache -O- "https://raw.githubusercontent.com/manuelgustavo/ubuntu-setup/main/tilix_rosipov-grey-ld.conf" | dconf load /com/gexperts/Tilix/
    # dconf dump /com/gexperts/Tilix/ >[filename.conf]
    # Install Powerline Droid Sans Mono Dotted.
    mkdir -p "$HOME/.local/share/fonts"
    wget --no-cache -O "$HOME/.local/share/fonts/Droid Sans Mono Dotted for Powerline.ttf" "https://raw.githubusercontent.com/powerline/fonts/master/DroidSansMonoDotted/Droid%20Sans%20Mono%20Dotted%20for%20Powerline.ttf"
    fc-cache -f
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper
    
    sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh || true
    
    { 
        echo
        echo 'if [ $TILIX_ID ] || [ $VTE_VERSION ]; then'
        echo '    source /etc/profile.d/vte.sh'
        echo 'fi'
    } >> "$HOME/.zshrc"
    installed+="Tilix\n"
}

install_vscode()
{
    echo "Installing VSCode"
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code # or code-insiders
    echo "Installing VSCode extensions..."
    sh -c "$(wget --no-cache -O- https://raw.githubusercontent.com/manuelgustavo/vscode-extensions/main/vscode-extensions.sh)"
    installed+="VScode + extensions\n"
}

main()
{
    sudo apt-get update -q 
    sudo apt-get install -y -q git wget

    install_gnome_extensions
    install_brave
    set_dark_theme
    install_oh_my_zsh
    install_tilix
    install_vscode

    echo .
    echo .
    echo .
    echo "SCRIPT SUCCESS!"
    echo .
    echo "-------------------- Summary --------------------"
    if [[ -n "${installed}" ]]
    then
    {
        echo "Installed:"
        printf "${installed}"
    }
    fi
    echo "-------------------------------------------------"
    if [[ -n "${not_installed}" ]]
    then
    {
        echo "Skipped:"
        printf "${not_installed}"
    }
    fi
    echo "-------------------------------------------------"
    echo .
    echo .
    echo "It's recommended to log-off and log-on again!"
}

main "$@"