# Framework OS System Justfile

# Update rpm-ostree, Flatpaks, and Homebrew packages
update:
    #!/usr/bin/bash
    set -euo pipefail
    echo ":: Updating system image (rpm-ostree)..."
    rpm-ostree upgrade || true
    echo ":: Updating Flatpaks..."
    flatpak update -y || true
    if command -v brew >/dev/null 2>&1; then
        echo ":: Updating Homebrew..."
        brew update && brew upgrade || true
    fi
    echo ":: System update complete!"

# Remove unused Flatpak runtimes, dangling Podman images, and clean ostree cache
clean:
    #!/usr/bin/bash
    set -euo pipefail
    echo ":: Pruning unused Flatpaks..."
    flatpak uninstall --unused -y || true
    if command -v podman >/dev/null 2>&1; then
        echo ":: Pruning unused Podman containers and images..."
        podman system prune -f || true
    fi
    echo ":: Cleaning ostree metadata..."
    rpm-ostree cleanup -m || true
    echo ":: Clean complete!"

# Reboot directly into UEFI BIOS setup
bios:
    #!/usr/bin/bash
    echo "Rebooting into UEFI BIOS setup..."
    systemctl reboot --firmware-setup

# Check for Framework laptop and component firmware updates via LVFS
firmware:
    #!/usr/bin/bash
    set -euo pipefail
    echo ":: Refreshing firmware device metadata..."
    fwupdmgr refresh
    echo ":: Checking for available firmware updates..."
    fwupdmgr get-updates || true

# Apply pending Framework laptop and component firmware updates
firmware-update:
    #!/usr/bin/bash
    set -euo pipefail
    echo ":: Installing firmware updates..."
    fwupdmgr update

# View Framework battery health, charge rate, and power profile
battery:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Battery Status ==="
    if command -v upower >/dev/null 2>&1; then
        BAT_PATH=$(upower -e | grep "BAT" | head -n 1)
        if [ -n "$BAT_PATH" ]; then
            upower -i "$BAT_PATH" | grep -E "state|to\ full|percentage|capacity|energy-rate|voltage|temperature" || true
        fi
    fi
    if command -v powerprofilesctl >/dev/null 2>&1; then
        echo "=== Active Power Profile ==="
        powerprofilesctl get
    fi

# Check status of rootless Docker / Podman socket and Dev Containers
dev-status:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Rootless Podman Socket Status ==="
    systemctl --user status podman.socket --no-pager || true
    echo "=== Docker Host Environment ==="
    echo "DOCKER_HOST: ${DOCKER_HOST:-<unset>}"
    if command -v docker >/dev/null 2>&1; then
        echo "=== Docker CLI Connectivity ==="
        docker version || true
    fi

# View system and kernel error logs from current boot
logs:
    #!/usr/bin/bash
    journalctl -b -p 3 --no-pager
