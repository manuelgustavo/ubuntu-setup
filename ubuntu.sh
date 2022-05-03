#!/bin/bash
#set -x
set -euo pipefail

install_chrome() 
{
    echo Installing CHROME
    wget --no-cache -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
    sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt-get update -q 
    sudo apt-get install -y -q google-chrome-stable
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
    else
        echo "Cannot setup theme for Ubuntu ${release}!"
    fi
}

install_oh_my_zsh()
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
    
    # Change the default shell
    sudo sed -i -E "s/($USER.*)(bash)/\1zsh/" /etc/passwd
    sudo update-passwd

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

    echo "Installing Gnome Extension -- Dash to Panel https://extensions.gnome.org/extension/1160/dash-to-panel/"
    gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "dash-to-panel@jderose9.github.com" 2>/dev/null || true

    # TODO: The below needs to be re-enabled when made available!
    # echo "Installing Gnome Extension -- system-monitor https://extensions.gnome.org/extension/120/system-monitor/"
    # gdbus call --session \
    #            --dest org.gnome.Shell.Extensions \
    #            --object-path /org/gnome/Shell/Extensions \
    #            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
    #            "system-monitor@paradoxxx.zero.gmail.com" 2>/dev/null

    echo "Installing Gnome Extension -- system-monitor-next https://extensions.gnome.org/extension/3010/system-monitor-next/"
    gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "system-monitor-next@paradoxxx.zero.gmail.com" 2>/dev/null || true

    echo "Installing Gnome Extension -- Removable Drive Menu https://extensions.gnome.org/extension/7/removable-drive-menu/"
    gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "drive-menu@gnome-shell-extensions.gcampax.github.com" 2>/dev/null || true
}

install_tilix()
{
    sudo apt-get -y -q install tilix
    wget --no-cache -O- "https://raw.githubusercontent.com/manuelgustavo/ubuntu-setup/main/tilix.conf" | dconf load /com/gexperts/Tilix/
    # dconf dump /com/gexperts/Tilix/
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
}

install_vscode()
{
    echo "Installing VSCode"
    declare temp="$(mktemp -d)"
    cd "${temp}"
    sudo apt-get install gpg
    wget --no-cache -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    cd -
    rm -fr "${temp}"
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code
    echo "Installing VSCode extensions..."
    sh -c "$(wget --no-cache -O- https://raw.githubusercontent.com/manuelgustavo/vscode-extensions/main/vscode-extensions.sh)"
}

main()
{
    sudo apt update -q 
    sudo apt install -y -q git wget

    install_gnome_extensions
    install_chrome
    set_dark_theme
    install_oh_my_zsh
    install_tilix
    install_vscode

    echo .
    echo .
    echo .
    echo "INSTALLATION SUCCESSFUL!"
    echo "It's recommended to log-off and log-on again!"
}

main "$@"