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

# Install Dev Containers extension for VS Code
vscode-devcontainers:
    #!/usr/bin/bash
    set -euo pipefail
    if command -v code >/dev/null 2>&1; then
        echo ":: Installing VS Code Dev Containers extension..."
        code --install-extension ms-vscode-remote.remote-containers --force
        echo ":: Extension installed!"
    else
        echo "Error: VS Code ('code') is not installed."
        exit 1
    fi

# Connect to Tailscale and grant local user operator control
tailscale-up:
    #!/usr/bin/bash
    echo ":: Authenticating and connecting Tailscale..."
    sudo tailscale up --operator=$USER

# View Tailscale network status and peers
tailscale-status:
    #!/usr/bin/bash
    tailscale status

# Check status of KVM hardware acceleration, libvirt sockets, and virtual machines
virt-status:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== KVM Hardware Acceleration ==="
    if [ -e /dev/kvm ]; then
        echo "✓ /dev/kvm is available and accessible"
    else
        echo "✗ /dev/kvm is missing (check UEFI virtualization settings: AMD SVM)"
    fi
    echo "=== Libvirt Socket Status ==="
    systemctl status virtqemud.socket virtnetworkd.socket --no-pager || true
    echo "=== User Group Membership ==="
    groups | grep -E "\b(libvirt|kvm)\b" || echo "User $USER is not in 'libvirt' group (run 'just virt-setup' to join)"
    echo "=== Virtual Machines ==="
    virsh list --all || true

# Add current user to libvirt group and ensure default virtual network is active
virt-setup:
    #!/usr/bin/bash
    set -euo pipefail
    echo ":: Adding user $USER to 'libvirt' group..."
    if ! grep -q "^libvirt:" /etc/group 2>/dev/null; then
        if grep -q "^libvirt:" /usr/lib/group; then
            grep "^libvirt:" /usr/lib/group | sudo tee -a /etc/group > /dev/null
        fi
    fi
    sudo usermod -aG libvirt "$USER"
    echo ":: User $USER added to 'libvirt' group (log out and back in for group to take effect)."
    echo ":: Ensuring default libvirt network is started..."
    sudo virsh net-autostart default || true
    sudo virsh net-start default || true
    echo ":: Virtualization setup complete!"

# Check Waydroid container status and session
waydroid-status:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Waydroid Container Service ==="
    systemctl status waydroid-container.service --no-pager || true
    echo "=== Waydroid Status ==="
    waydroid status || true

# Initialize Waydroid with Google Play Apps (GAPPS) or vanilla LineageOS
waydroid-init TYPE="GAPPS":
    #!/usr/bin/bash
    set -euo pipefail
    echo ":: Initializing Waydroid (type: {{ TYPE }})..."
    sudo waydroid init -s {{ TYPE }}
    echo ":: Waydroid initialized! Run 'just waydroid-show' or launch an Android app from the application menu."

# Launch the full Waydroid Android user interface window
waydroid-show:
    #!/usr/bin/bash
    waydroid show-full-ui &

# Stop Waydroid session and container
waydroid-stop:
    #!/usr/bin/bash
    echo ":: Stopping Waydroid session..."
    waydroid session stop || true
    echo ":: Stopping Waydroid container..."
    sudo systemctl stop waydroid-container.service || true
    echo ":: Waydroid stopped."

