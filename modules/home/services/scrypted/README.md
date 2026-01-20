# Scrypted

A high performance home video integration platform.

## Configuration

To enable Scrypted in your configuration:

```nix
{
  killtw.services.scrypted.enable = true;
}
```

This module automatically:
1. Provisions Node.js 22 and Python 3.11 with required dependencies (OpenCV, etc.)
2. Creates a `scrypted-start` wrapper script
3. Sets up a LaunchAgent to run Scrypted in the background (macOS)

## Usage

After applying the configuration, Scrypted will start automatically.
You can check the status via:

```bash
launchctl list | grep scrypted
```

Access the web interface at: https://localhost:10443/

## Logs

Logs are written to:
- `~/.scrypted/scrypted.log`
- `~/.scrypted/scrypted.error.log`
