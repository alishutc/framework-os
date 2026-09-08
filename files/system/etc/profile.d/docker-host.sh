# Point DOCKER_HOST to rootless user podman socket
if [ -z "$DOCKER_HOST" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
    export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
fi
