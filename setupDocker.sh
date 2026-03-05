#!/bin/bash

# Docker CE + Docker Compose installation with secure defaults
# Run as root on a hardened Ubuntu/Debian system

set -euo pipefail

DOCKER_USER="${1:-}"

usage() {
  echo "Usage: $0 <username>"
  echo ""
  echo "  username - Non-root user to add to the docker group"
  echo ""
  echo "Example: $0 admin"
  exit 1
}

if [[ -z "$DOCKER_USER" ]]; then
  usage
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
  echo "User '$DOCKER_USER' does not exist."
  exit 1
fi

if [ -f /etc/os-release ]; then
  # shellcheck disable=1091
  . /etc/os-release
  DISTRO="$ID"
else
  echo "/etc/os-release not found."
  exit 1
fi

if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
  echo "Ubuntu or Debian required."
  exit 1
fi

# ============================================================
# 1. Install Docker CE from official repository
# ============================================================

echo "[1] Installing Docker CE"

apt-get -qq update
apt-get -qq install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg

install -m 0755 -d /etc/apt/keyrings

DOCKER_GPG="/etc/apt/keyrings/docker.asc"
if [[ ! -f "$DOCKER_GPG" ]]; then
  curl -fsSL "https://download.docker.com/linux/${DISTRO}/gpg" -o "$DOCKER_GPG"
  chmod a+r "$DOCKER_GPG"
fi

if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_GPG}] https://download.docker.com/linux/${DISTRO} ${VERSION_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list
fi

apt-get -qq update
apt-get -qq install -y --no-install-recommends \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# ============================================================
# 2. Add user to docker group
# ============================================================

echo "[2] Adding $DOCKER_USER to docker group"

usermod -aG docker "$DOCKER_USER"

# ============================================================
# 3. Secure Docker daemon configuration
# ============================================================

echo "[3] Applying secure Docker daemon settings"

mkdir -p /etc/docker

cat > /etc/docker/daemon.json << 'DAEMON_EOF'
{
  "icc": false,
  "userns-remap": "default",
  "no-new-privileges": true,
  "userland-proxy": false,
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    },
    "nproc": {
      "Name": "nproc",
      "Hard": 4096,
      "Soft": 4096
    }
  },
  "storage-driver": "overlay2"
}
DAEMON_EOF

chmod 0644 /etc/docker/daemon.json

# ============================================================
# 4. Restrict Docker socket permissions
# ============================================================

echo "[4] Restricting Docker socket permissions"

mkdir -p /etc/systemd/system/docker.socket.d

cat > /etc/systemd/system/docker.socket.d/override.conf << 'SOCKET_EOF'
[Socket]
SocketMode=0660
SOCKET_EOF

chmod 0644 /etc/systemd/system/docker.socket.d/override.conf

# ============================================================
# 5. Enable and start Docker
# ============================================================

echo "[5] Enabling Docker service"

systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker.service

echo ""
echo "============================================================"
echo "  Setup complete"
echo "============================================================"
echo ""
echo "  Docker $(docker --version | awk '{print $3}') installed"
echo "  Docker Compose $(docker compose version --short) installed"
echo ""
echo "  Daemon security settings:"
echo "    - Inter-container communication disabled (icc: false)"
echo "    - User namespace remapping enabled (userns-remap: default)"
echo "    - No new privileges for containers (no-new-privileges: true)"
echo "    - Userland proxy disabled"
echo "    - Log rotation: 10MB x 3 files per container"
echo "    - Socket restricted to docker group (0660)"
echo ""
echo "  Log in as $DOCKER_USER (or re-login) to use docker without sudo."
echo ""
