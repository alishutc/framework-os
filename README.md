# Framework OS &nbsp; [![bluebuild build badge](https://github.com/alishutc/framework-os/actions/workflows/build.yml/badge.svg)](https://github.com/alishutc/framework-os/actions/workflows/build.yml)

A custom, declarative, and atomic Fedora Silverblue operating system image tailored specifically for the **Framework Laptop 13 (AMD Edition)**. Built with [BlueBuild](https://blue-build.org/) and published to the GitHub Container Registry (`ghcr.io/alishutc/framework-os:latest`).

---

## 🚀 Highlights & Features

### 💻 Framework 13 Hardware Optimizations
- **Display & Scaling:** Experimental Mutter framebuffer scaling enabled out of the box for crisp 125% and 150% fractional scaling on the 2256x1504 3:2 display.
- **Power Tuning:**
  - Idle autosuspend for HDMI (`32ac:0002`) and DisplayPort (`32ac:0003`) expansion cards via `/etc/udev/rules.d/99-framework-expansion-power.rules`.
  - Headphone audio popping prevention via `snd_hda_intel` power-save disabling and WirePlumber configuration.
  - `powertop` pre-installed for battery auditing.
- **Speaker DSP Calibration:** Pre-configured EasyEffects service with a custom 4-band resonance EQ preset for Framework 13 speakers.
- **Hardware Integration:** Goodix fingerprint reader stack (`fprintd`, `fprintd-pam`, `libfprint`) and AMD RDNA hardware video acceleration (`mesa-va-drivers-freeworld`).
- **Secondary Storage Automounting:** Automated systemd-mount udev rules and udisks2 mount configurations for Framework Storage Expansion Cards (250GB/1TB USB-C), external SSDs, and SD cards (Btrfs, Ext4, exFAT, NTFS) with execution permissions enabled for Steam game libraries.

### 🎨 Desktop & User Experience
- **Framework Branding:** Official Framework gear monochrome logo pinned to the top panel via the Logo Menu extension.
- **GNOME Extensions:** Pinned and pre-configured extensions:
  - **Logo Menu** (Framework gear launcher with quick settings and terminal shortcuts)
  - **AppIndicator** (system tray icons for Steam, Tailscale, etc.)
  - **Dash to Dock** (custom dock with pinned essentials)
  - **Blur my Shell** (refined transparent shell effects)
  - **Spotlight** (quick search launcher)
- **Dynamic Wallpapers:** Bundled Framework 13 light and dark dynamic wallpapers registered with GNOME Appearance.
- **Sensible Defaults:** Tap-to-click enabled, battery percentage in top panel, centered windows, and folder-first file sorting.

### 🎮 Gaming Ready
- **Steam (Native RPM):** Official Steam client layered directly into the base OS.
- **Controller Rules:** Full `steam-devices` package included for plug-and-play Xbox, PlayStation DualSense, Switch Pro, and 8BitDo controller support.
- **MangoHud:** In-game performance, frame rate, and telemetry overlay pre-installed.

### 🛠️ Developer Tooling & Virtualization
- **Terminal Utilities:** Modern CLI stack (`starship` prompt, `fastfetch` with `neofetch` alias, `ripgrep`, `fzf`) pre-integrated for Bash and Fish.
- **Homebrew:** Linuxbrew pre-staged via BlueBuild's `brew` module.
- **Rootless Docker / Dev Containers:** Native `podman-docker` CLI, `podman-compose`, `podman.socket`, and `DOCKER_HOST` pre-configured for out-of-the-box VS Code Dev Containers.
- **Visual Studio Code:** Native RPM from Microsoft's repository with Wayland fractional scaling flags enabled.
- **Local Virtualization (KVM/QEMU):** Full hypervisor stack (`virt-manager`, `virt-install`, `libvirt-daemon-kvm`, `libvirt-client`, `edk2-ovmf`, `swtpm`) with modular socket activation and passwordless Polkit rules for `wheel` and `libvirt` users.
- **Android Subsystem (Waydroid):** Built-in Waydroid container runtime with SELinux policy and automated firewall integration.
- **Tailscale VPN:** Official repository, background daemon (`tailscaled.service`), and system tray autostart.

---

## ⚡ System Justfile Commands (`ujust` / `just`)

Framework OS includes BlueBuild's `justfiles` module (`blujust`), aliased to `ujust`. You can run these commands from anywhere in the terminal:

| Command | Description |
| :--- | :--- |
| `just update` | Updates rpm-ostree base OS, Flatpaks, and Homebrew packages |
| `just clean` | Prunes unused Flatpaks, cleans Podman images, and cleans ostree cache |
| `just battery` | Shows battery health, capacity, discharge rate, and active power profile |
| `just bios` | Reboots directly into UEFI BIOS setup |
| `just firmware` | Checks for Framework laptop and component firmware updates via LVFS |
| `just firmware-update` | Applies pending LVFS firmware updates |
| `just dev-status` | Verifies rootless Podman socket and Docker CLI connectivity |
| `just vscode-devcontainers` | Installs the Dev Containers extension in VS Code |
| `just tailscale-up` | Authenticates and connects Tailscale with local user operator permissions |
| `just tailscale-status` | Displays Tailscale network peers and status |
| `just virt-status` | Verifies KVM hardware acceleration, libvirt sockets, and virtual machines |
| `just virt-setup` | Adds user to `libvirt` group and verifies default network bridge |
| `just waydroid-status` | Displays Waydroid container and session status |
| `just waydroid-init` | Initializes Waydroid with Google Play Services (`GAPPS`) or vanilla |
| `just waydroid-show` | Launches the full Android UI window |
| `just waydroid-stop` | Stops Waydroid session and container |
| `just drives` | Lists connected storage devices, filesystems, and mountpoints |

---

## 📦 Installation & Rebasing

To rebase an existing Fedora Atomic (Silverblue) installation to **Framework OS**:

### 1. Initial Rebase (Unsigned)
First rebase to the unverified registry to pull down the container image and establish the Cosign signing policies and keys:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/alishutc/framework-os:latest
systemctl reboot
```

### 2. Switch to Cryptographically Signed Image
Once booted into Framework OS, switch to the verified signed image:
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/alishutc/framework-os:latest
systemctl reboot
```

The `latest` tag automatically tracks the Fedora 44 release stream.

---

## 💿 Offline Installation ISO

If you want to perform a clean installation onto bare metal from USB (rather than rebasing an existing Fedora Atomic installation), you can generate a bootable offline installation ISO:

- Refer to the [BlueBuild ISO Generation Guide](https://blue-build.org/how-to/generate-iso/#_top) for detailed instructions.
- Due to file size limits, ISOs are not hosted directly on GitHub Releases, but you can generate one locally using Podman:
  ```bash
  sudo podman run --rm --privileged \
    -v $(pwd)/output:/output \
    ghcr.io/blue-build/cli:latest generate-iso \
    --image-ref ostree-unverified-registry:ghcr.io/alishutc/framework-os:latest \
    --output /output/framework-os.iso
  ```

---

## 🔐 Cryptographic Verification

All images published to GitHub Container Registry are cryptographically signed with [Sigstore Cosign](https://github.com/sigstore/cosign). You can verify an image before running or rebasing:

```bash
cosign verify --key cosign.pub ghcr.io/alishutc/framework-os
```
