# Point DOCKER_HOST to rootless user podman socket
if not set -q DOCKER_HOST; and set -q XDG_RUNTIME_DIR
    set -gx DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
end
