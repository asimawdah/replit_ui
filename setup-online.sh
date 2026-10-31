#!/usr/bin/env bash
# setup-online.sh — bring both sites online end-to-end.
#
#   personal site:     asimawdah.com        -> docker :8080
#   replit_ui docs:    replit.asimawdah.com -> docker :8082 -> host nginx (443/80)
#
# Run:  chmod +x setup-online.sh && ./setup-online.sh
#       (sudo is needed for the host-nginx vhost; the Docker parts need the
#        `docker` group — this user is already in it.)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# This script lives in packages.../replit_ui, alongside its docker-compose.yaml.
ROOT_DIR="$SCRIPT_DIR"
PERSONAL_DIR="$ROOT_DIR/../AsimAwdah.com"

NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
NGINX_VHOST="replit.asimawdah.com.conf"

log() { printf '[setup-online] %s\n' "$*"; }
need_sudo() { if [ -w /etc/nginx ]; then return 1; else return 0; fi; }

log "Step 1: ensure nginx is installed and running"
NGINX_BIN="$(command -v nginx 2>/dev/null || echo /usr/sbin/nginx)"
if [ ! -x "$NGINX_BIN" ]; then
    log "ERROR: nginx not found on this host."
    exit 1
fi
if ! systemctl is-active --quiet nginx 2>/dev/null && ! service nginx status >/dev/null 2>&1; then
    log "Starting nginx..."
    sudo systemctl start nginx 2>/dev/null || sudo service nginx start 2>/dev/null || true
fi
systemctl is-active --quiet nginx 2>/dev/null && log "nginx is active" || log "nginx may not be active (continuing)"

log "Step 2: start the personal site (asimawdah.com) on port 8080"
(cd "$PERSONAL_DIR" && docker compose down --remove-orphans 2>/dev/null || true)
(cd "$PERSONAL_DIR" && docker compose up -d --build)
for i in $(seq 1 30); do
    if curl -sf http://127.0.0.1:8080/ >/dev/null 2>&1; then
        log "personal site ready on http://127.0.0.1:8080/"
        break
    fi
    sleep 1
done
if ! curl -sf http://127.0.0.1:8080/ >/dev/null 2>&1; then
    log "WARNING: personal site did not become ready on :8080"
fi

log "Step 3: start the replit_ui docs site (replit.asimawdah.com) on port 8082"
cd "$ROOT_DIR"
docker compose down --remove-orphans 2>/dev/null || true
docker compose up -d --build
for i in $(seq 1 30); do
    if curl -sf http://127.0.0.1:8082/ >/dev/null 2>&1; then
        log "replit_ui docs ready on http://127.0.0.1:8082/"
        break
    fi
    sleep 1
done
if ! curl -sf http://127.0.0.1:8082/ >/dev/null 2>&1; then
    log "WARNING: replit_ui docs did not become ready on :8082"
fi

log "Step 4: create host-nginx vhost for replit.asimawdah.com -> 127.0.0.1:8082"
if [ -f "$NGINX_AVAILABLE/$NGINX_VHOST" ]; then
    log "$NGINX_VHOST already exists; skipping write (edit manually if needed)"
else
    cat > /tmp/$NGINX_VHOST <<'EOF'
# Host nginx vhost: replit.asimawdah.com -> replit_ui docs container on 127.0.0.1:8082.
#
# replit_ui Docker stack serves http://127.0.0.1:8082 (see replit_ui/docker-compose.yaml).
# DNS for replit.asimawdah.com is on Cloudflare; Cloudflare Flexible SSL terminates HTTPS and
# talks to this origin over HTTP on port 80. For Full/Full Strict mode, obtain a LE cert:
#   sudo certbot --nginx -d replit.asimawdah.com
# then add a 443 server block below.

server {
    listen 80;
    listen [::]:80;
    server_name replit.asimawdah.com;

    server_tokens off;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    gzip on;
    gzip_types text/plain text/css application/javascript application/json image/svg+xml;

    client_max_body_size 64m;

    # Certbot http-01 webroot.
    location ^~ /.well-known/acme-challenge/ {
        root /var/www/html;
        try_files $uri =404;
    }

    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;

        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_connect_timeout 30s;
        proxy_read_timeout 120s;
    }
}
EOF
    log "vhost written to /tmp/$NGINX_VHOST"
    if need_sudo; then
        log "Installing $NGINX_VHOST into /etc/nginx (needs sudo password)..."
        if sudo -n true 2>/dev/null; then
            sudo cp /tmp/$NGINX_VHOST "$NGINX_AVAILABLE/$NGINX_VHOST"
            sudo ln -sf "$NGINX_AVAILABLE/$NGINX_VHOST" "$NGINX_ENABLED/$NGINX_VHOST"
            log "vhost installed"
        else
            log "sudo requires a password (no tty). Run these two commands manually:"
            log "  sudo cp /tmp/$NGINX_VHOST $NGINX_AVAILABLE/$NGINX_VHOST"
            log "  sudo ln -sf $NGINX_AVAILABLE/$NGINX_VHOST $NGINX_ENABLED/$NGINX_VHOST"
            log "  sudo $NGINX_BIN -t && sudo systemctl reload nginx"
        fi
    else
        cp /tmp/$NGINX_VHOST "$NGINX_AVAILABLE/$NGINX_VHOST"
        ln -sf "$NGINX_AVAILABLE/$NGINX_VHOST" "$NGINX_ENABLED/$NGINX_VHOST"
        log "vhost installed"
    fi
fi

log "Step 5: test and reload nginx"
if need_sudo; then
    if sudo -n true 2>/dev/null; then
        sudo "$NGINX_BIN" -t
        sudo systemctl reload nginx 2>/dev/null || sudo service nginx reload 2>/dev/null || true
        log "nginx reloaded"
    else
        log "sudo needs a password. After installing the vhost manually, run:"
        log "  sudo $NGINX_BIN -t && sudo systemctl reload nginx"
    fi
else
    "$NGINX_BIN" -t
    systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
    log "nginx reloaded"
fi

log "Step 6: verify both sites"
log "  personal site  : http://127.0.0.1:8080/  -> $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/ 2>/dev/null || echo 'n/a')"
log "  replit_ui docs : http://127.0.0.1:8082/  -> $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8082/ 2>/dev/null || echo 'n/a')"
log "  replit domain  : http://replit.asimawdah.com/ -> $(curl -s -o /dev/null -w '%{http_code}' http://replit.asimawdah.com/ 2>/dev/null || echo 'n/a (DNS/nginx not yet routing)')"

cat <<EOF

============================================================
Setup complete. Summary:

  * Personal site  : asimawdah.com          -> :8080  (container: asimawdah.com)
  * replit_ui docs : replit.asimawdah.com   -> :8082  (container: replit.asimawdah.com)
                     host nginx (443/80) -> 127.0.0.1:8082 via $NGINX_VHOST

  * DNS for replit.asimawdah.com already points at Cloudflare; Cloudflare Flexible SSL
    (HTTPS -> HTTP origin on port 80) will serve the domain once the nginx vhost is live.

  * For origin TLS (Full/Full Strict), run:
      sudo certbot --nginx -d replit.asimawdah.com
    then add a 443 server block to $NGINX_AVAILABLE/$NGINX_VHOST.

Commands to re-deploy later:
  cd "$PERSONAL_DIR"   && docker compose up -d --build   # personal site (:8080)
  cd "$ROOT_DIR"       && docker compose up -d --build   # replit_ui docs (:8082)
============================================================
