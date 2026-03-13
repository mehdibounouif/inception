# ============================================================
# Portainer CE — Docker management dashboard
# ============================================================
# What Portainer is:
#   Portainer Community Edition is a lightweight web UI for Docker.
#   It lets you visually inspect containers, images, volumes,
#   networks, and logs through a browser — no CLI required.
#
# Why it is the best custom service choice for this defense:
#   During a 42 evaluation, the evaluator must verify:
#     - All containers are running
#     - The correct volumes exist
#     - The network topology is correct
#     - Logs can be inspected for debugging
#   Portainer lets you demonstrate all of these things visually
#   and instantly. It also makes a strong impression: it shows
#   you understand Docker at a management level, not just how
#   to write a Dockerfile.
#
# How it works:
#   Portainer connects to the Docker daemon via the Unix socket
#   /var/run/docker.sock (bind-mounted in docker-compose.yml).
#   This gives it full read/write access to the local Docker engine.
#   Its data (users, settings) is stored in a named volume.
#
# Security note for the defense:
#   Mounting docker.sock is a significant privilege — it effectively
#   gives root access to the host. This is acceptable for a local
#   development/evaluation environment but would not be done in
#   production. Be ready to explain this trade-off.
#
# Access:
#   Routed through the main nginx at https://mbounoui.42.fr/portainer/
#   Portainer's own HTTP server listens on port 9000 internally.
# ============================================================

FROM debian:bullseye

# curl        — to download the Portainer binary from GitHub
# ca-certificates — so curl can verify GitHub's HTTPS cert
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Portainer CE.
# We pin to a specific release (2.19.4) for reproducibility.
# The tarball contains a single directory "portainer/" with the
# binary and bundled frontend assets.
RUN curl -fsSL \
    https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz \
    | tar -xz -C /opt/
# Result: /opt/portainer/portainer (the binary)
#         /opt/portainer/public/   (the web UI assets)

# /data is where Portainer stores its database (users, endpoints,
# settings). We mount a named volume here in docker-compose.yml so
# that data survives container restarts.
RUN mkdir -p /data

# Port 9000 — Portainer's built-in HTTP server.
# Accessible only inside the inception network; the main nginx
# proxies /portainer/ here.
EXPOSE 9000

# --no-analytics disables Portainer's anonymous usage telemetry.
# --data /data   tells Portainer where to write its database.
# exec is not needed here because CMD is exec-form (JSON array),
# which already runs the binary directly as PID 1 without a shell.
CMD ["/opt/portainer/portainer", "--no-analytics", "--data", "/data"]