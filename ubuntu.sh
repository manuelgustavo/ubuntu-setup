#!/bin/bash
#set -x
set -euo pipefail

installed=""
not_installed=""
install_chrome() 
{
    echo Installing CHROME
    wget --no-cache -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
    sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt-get update -q 
    sudo apt-get install -y -q google-chrome-stable
    installed+="Chrome\n"
}

set_dark_theme()
{
    echo "Setting up theme to Yaru-dark"
    declare release
    release="$(lsb_release -r | awk -F '\t' '{print $2}')"
    if [[ "${release}" = "20.04" ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    elif [[ "${release}" = "22.04" ]]
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
        git@github.com:manuelgustavo/ubuntu-setup.git
        
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
    #     wget --no-cache https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
    # sed -i.tmp 's:env zsh::g' install.sh
    # sed -i.tmp 's:chsh -s .*$::g' install.sh
    # sh install.sh
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
        gdbus call --session \
                --dest org.gnome.Shell.Extensions \
                --object-path /org/gnome/Shell/Extensions \
                --method org.gnome.Shell.Extensions.InstallRemoteExtension \
                "${gnome_extension}" 2>/dev/null || true
        installed+="Gnome Extension -- Dash to Panel\n"
    }
    else
    {
        echo "Skipping Dash to Panel -- already installed."
        not_installed+="Gnome Extension -- Dash to Panel\n"
    }
    fi

    # TODO: The below needs to be re-enabled when made available!
    # echo "Installing Gnome Extension -- system-monitor https://extensions.gnome.org/extension/120/system-monitor/"
    # gdbus call --session \
    #            --dest org.gnome.Shell.Extensions \
    #            --object-path /org/gnome/Shell/Extensions \
    #            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
    #            "system-monitor@paradoxxx.zero.gmail.com" 2>/dev/null

    gnome_extension="system-monitor-next@paradoxxx.zero.gmail.com"
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/${gnome_extension}" ]]
    then
    {
        echo "Installing Gnome Extension -- system-monitor-next https://extensions.gnome.org/extension/3010/system-monitor-next/"
        gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "${gnome_extension}" 2>/dev/null || true
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
        gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "${gnome_extension}" 2>/dev/null || true
        installed+="Gnome Extension -- Removable Drive\n"
    }
    else
    {
        echo "Skipping Removable Drive Menu -- already installed."
        not_installed+="Gnome Extension -- Removable Drive Menu\n"
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
    declare temp="$(mktemp -d)"
    cd "${temp}"
    sudo apt-get install -y gpg
    wget --no-cache -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    cd -
    rm -fr "${temp}"
    sudo apt-get install -y apt-transport-https
    sudo apt-get update
    sudo apt-get install code
    echo "Installing VSCode extensions..."
    sh -c "$(wget --no-cache -O- https://raw.githubusercontent.com/manuelgustavo/vscode-extensions/main/vscode-extensions.sh)"
    installed+="VScode + extensions\n"
}

main()
{
    sudo apt-get update -q 
    sudo apt-get install -y -q git wget

    install_gnome_extensions
    install_chrome
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