#!/bin/bash

# Log file location
LOG_FILE="/home/deck/japanese_setup_log.txt"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if a package is installed
is_package_installed() {
    pacman -Q "$1" &> /dev/null
    return $?
}

# Function to disable read-only mode if needed
disable_readonly_if_needed() {
    if mount | grep "/ " | grep -q "ro,"; then
        log_message "System is in read-only mode. Attempting to disable..."
        sudo steamos-readonly disable
        if [ $? -ne 0 ]; then
            log_message "Failed to disable read-only mode. Exiting."
            return 1
        fi
        log_message "Successfully disabled read-only mode."
    else
        log_message "System is already in read-write mode."
    fi
    return 0
}

# Function to initialize pacman keys if needed
initialize_pacman_keys() {
    if [ ! -d "/etc/pacman.d/gnupg" ] || [ -z "$(ls -A /etc/pacman.d/gnupg/)" ]; then
        log_message "Initializing pacman keys..."
        sudo pacman-key --init
        if [ $? -ne 0 ]; then
            log_message "Failed to initialize pacman keys. Exiting."
            return 1
        fi
        
        log_message "Populating pacman keys..."
        sudo pacman-key --populate archlinux holo
        if [ $? -ne 0 ]; then
            log_message "Failed to populate pacman keys. Exiting."
            return 1
        fi
    else
        log_message "Pacman keys already initialized."
    fi
    return 0
}

# Function to install required packages
install_required_packages() {
    local packages_to_install=()
    local required_packages=(
        "fcitx5-mozc"
        "fcitx5-configtool"
        "fcitx5-gtk"
        "fcitx5-qt"
        "adobe-source-han-serif-jp-fonts"
        "adobe-source-han-sans-jp-fonts"
    )

    # Check which packages need to be installed
    for package in "${required_packages[@]}"; do
        if ! is_package_installed "$package"; then
            log_message "Package $package is not installed."
            packages_to_install+=("$package")
        else
            log_message "Package $package is already installed."
        fi
    done

    # Install missing packages if any
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        log_message "Installing missing packages: ${packages_to_install[*]}"
        sudo pacman -S --noconfirm "${packages_to_install[@]}"
        if [ $? -ne 0 ]; then
            log_message "Failed to install packages. Exiting."
            return 1
        fi
        log_message "Successfully installed all required packages."
    else
        log_message "All required packages are already installed."
    fi
    return 0
}

# Function to set up environment variables
setup_environment_variables() {
    local bash_profile="/home/deck/.bash_profile"
    
    # Check if environment variables are already set with exact syntax
    if ! grep -q 'export GTK_IM_MODULE="fcitx"' "$bash_profile"; then
        log_message "Adding GTK_IM_MODULE to bash_profile..."
        echo 'export GTK_IM_MODULE="fcitx"' >> "$bash_profile"
    else
        log_message "GTK_IM_MODULE already set in bash_profile."
    fi

    if ! grep -q 'export QT_IM_MODULE="fcitx"' "$bash_profile"; then
        log_message "Adding QT_IM_MODULE to bash_profile..."
        echo 'export QT_IM_MODULE="fcitx"' >> "$bash_profile"
    else
        log_message "QT_IM_MODULE already set in bash_profile."
    fi

    if ! grep -q 'export XMODIFIERS="@im=fcitx"' "$bash_profile"; then
        log_message "Adding XMODIFIERS to bash_profile..."
        echo 'export XMODIFIERS="@im=fcitx"' >> "$bash_profile"
    else
        log_message "XMODIFIERS already set in bash_profile."
    fi

    # Apply variables to current session
    export GTK_IM_MODULE="fcitx"
    export QT_IM_MODULE="fcitx"
    export XMODIFIERS="@im=fcitx"
    
    log_message "Environment variables check completed."
    return 0
}

# Function to configure autostart
setup_autostart() {
    local autostart_dir="/home/deck/.config/autostart"
    local desktop_file="$autostart_dir/org.fcitx.Fcitx5.desktop"
    
    # Create autostart directory if it doesn't exist
    if [ ! -d "$autostart_dir" ]; then
        log_message "Creating autostart directory..."
        mkdir -p "$autostart_dir"
    fi
    
    # Copy desktop file if it doesn't exist or has changed
    if [ ! -f "$desktop_file" ] || ! cmp -s "/usr/share/applications/org.fcitx.Fcitx5.desktop" "$desktop_file"; then
        log_message "Setting up fcitx5 autostart..."
        cp "/usr/share/applications/org.fcitx.Fcitx5.desktop" "$desktop_file"
        log_message "Fcitx5 has been set to start automatically."
    else
        log_message "Fcitx5 autostart is already configured."
    fi
    
    # Try to start fcitx5 if it's not already running
    if ! pgrep -x "fcitx5" > /dev/null; then
        log_message "Starting fcitx5..."
        fcitx5 -d
    else
        log_message "Fcitx5 is already running."
    fi
    return 0
}

# Configure this script to run at startup
setup_script_autostart() {
    local systemd_dir="/home/deck/.config/systemd/user"
    local service_file="$systemd_dir/japanese-setup.service"
    
    # Create systemd user directory if it doesn't exist
    if [ ! -d "$systemd_dir" ]; then
        log_message "Creating systemd user directory..."
        mkdir -p "$systemd_dir"
    fi
    
    # Create service file if it doesn't exist
    if [ ! -f "$service_file" ]; then
        log_message "Creating systemd service for Japanese setup..."
        cat > "$service_file" << EOF
[Unit]
Description=Japanese Language Support Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /home/deck/japanese_setup.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
        log_message "Enabling systemd service..."
        systemctl --user enable japanese-setup.service
        log_message "Japanese setup service has been enabled."
    else
        log_message "Japanese setup service already exists."
    fi
    return 0
}

# Main function
main() {
    log_message "Starting Japanese language support setup..."
    
    # Run all setup functions
    disable_readonly_if_needed || return 1
    initialize_pacman_keys || return 1
    install_required_packages || return 1
    setup_environment_variables || return 1
    setup_autostart || return 1
    setup_script_autostart || return 1
    
    log_message "Japanese language support setup completed successfully."
    return 0
}

# Run the main function
main
exit $?