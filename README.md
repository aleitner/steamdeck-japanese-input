# Steam Deck Japanese Input Setup

This script automates the installation and configuration of Japanese language input (fcitx5-mozc) on Steam Deck. It ensures that Japanese input works properly even after system updates by checking and installing necessary components during system startup.

## Features

- Automatically installs required Japanese input packages if missing
- Configures environment variables for proper input method integration
- Sets up fcitx5 to start automatically when you boot your Steam Deck
- Creates a systemd service to maintain Japanese support after SteamOS updates
- Logs all actions for easy troubleshooting

## Installation

1. Download the `japanese_setup.sh` script to your Steam Deck.

2. Open a terminal (either in Desktop Mode or by connecting via SSH) and make the script executable:
   ```bash
   chmod +x ~/japanese_setup.sh
   ```

3. Run the script manually the first time:
   ```bash
   ~/japanese_setup.sh
   ```

4. Restart your Steam Deck after the initial setup.

## How It Works

The script:

1. Disables read-only mode on the filesystem (required for installing packages)
2. Initializes pacman keys if needed
3. Installs necessary packages:
   - fcitx5-mozc (Japanese input method)
   - fcitx5-configtool (Configuration tool)
   - fcitx5-gtk and fcitx5-qt (Framework integration)
   - Japanese fonts (adobe-source-han-serif-jp-fonts and adobe-source-han-sans-jp-fonts)
4. Sets up required environment variables in ~/.bash_profile
5. Configures fcitx5 to autostart
6. Creates a systemd service to ensure everything is checked on boot

## Usage

After installation:

1. In Desktop Mode, you can switch between input methods using Super+Space or by clicking the keyboard icon in the system tray
2. Select "Mozc" for Japanese input
3. Toggle between hiragana, katakana, and direct input modes using the standard Mozc shortcuts

## Troubleshooting

- Check the log file at `~/japanese_setup_log.txt` to see what the script did and if there were any errors
- If Japanese input isn't working after a system update, try running the script manually again
- For configuration issues, run `fcitx5-configtool` in Desktop Mode

## Common Issues

- **Input method not appearing**: Make sure you've restarted after installation
- **Can't type Japanese in certain applications**: Some applications might require additional configuration
- **Environment variables not taking effect**: Try logging out and back in

## Notes for Steam Gaming Mode

While this script sets up Japanese input for Desktop Mode, the Steam Deck's Gaming Mode uses its own input methods. You can use the Steam keyboard in Gaming Mode, which includes Japanese input options in its settings.

## Compatibility

This script is designed for SteamOS 3.x. Future versions of SteamOS might require modifications to the script.

## License

This script is provided as-is under the MIT License. Use at your own risk.

---

If you find this helpful, consider sharing it with other Steam Deck users who might need Japanese language support!