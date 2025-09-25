# ubuntu-setup v1.1

> Tested against Ubuntu 20.04 and 22.04.

The **bash** script `ubuntu.sh` is designed to offer minimal user interaction and install the following on Ubuntu.

Running it in 1 line:

``` bash
sudo apt-get update && sudo apt-get install -y -q wget && /bin/bash -c "$(wget --no-cache -O- https://raw.githubusercontent.com/manuelgustavo/ubuntu-setup/main/ubuntu.sh)"
```

## Visual changes

### Dark Theme

Yaru-dark is set as default.

### Gnome Extensions

- Dash to Panel
- system-monitor-next
- Removable Drive Menu

> During installation, gnome extensions need user confirmation.

### Tilix

Install and configure Tilix as the default terminal.

It will also configure the default font to Powerline's Android Sans Mono Dotted and specific coloring.

> **Crlt+`** is configured as the default shortcut to open a new "auto" tab.

## Applications
### oh-my-zsh

It will setup **zsh** and configure **oh-my-zsh** as the default shell with **Agnoster**  and the following plugins configured:

- z
- bundler
- dotenv
- zsh-autosuggestions
- command-not-found
- zsh-syntax-highlighting

### VSCode (C++, bash)

Setup and install **VSCode**.

Several extensions are installed on it with the aim of **c++**, and **bash** development.

> For a complete list, see <https://raw.githubusercontent.com/manuelgustavo/vscode-extensions/main/vscode-extensions.sh>.
