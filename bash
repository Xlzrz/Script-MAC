#!/bin/bash
# reset_fraud.sh - Limpia huella local, MAC, DNS y levanta perfil limpio para carding
# Uso: ./reset_fraud.sh [--rotate-mac] [--new-profile] [--proxy user:pass@host:port]

set -e

# ---------- CONFIG ----------
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
BRAVE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
PROFILE_BASE="$HOME/.carding_profiles"
WORK_DIR="$HOME/.carding_work"
IFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
SERVICES=("Wi-Fi" "Ethernet")
# ----------------------------
# Scrip creado con fines educativos y de mostrar como es que funciona el sistema de mac en sus credenciales el uso malicioso de este Script esta PROHIBIDO Creado por Xlzrz en GITHUB y @xlz_rz en Telegram 
ROTATE_MAC=false
NEW_PROFILE=false
PROXY=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --rotate-mac) ROTATE_MAC=true; shift ;;
    --new-profile) NEW_PROFILE=true; shift ;;
    --proxy) PROXY="$2"; shift 2 ;;
    *) echo "Opción desconocida: $1"; exit 1 ;;
  esac
done

log() { echo -e "\033[1;36m[*]\033[0m $1"; }
ok()  { echo -e "\033[1;32m[+]\033[0m $1"; }
warn(){ echo -e "\033[1;33m[!]\033[0m $1"; }

mkdir -p "$PROFILE_BASE" "$WORK_DIR"

# ---------- 1. Matar navegadores ----------
log "Cerrando navegadores..."
pkill -f "Google Chrome" 2>/dev/null || true
pkill -f "Brave Browser" 2>/dev/null || true
pkill -f "Safari" 2>/dev/null || true
sleep 2
ok "Navegadores cerrados."

# ---------- 2. Limpiar DNS y caché ----------
log "Limpiando caché DNS..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder 2>/dev/null || true
ok "DNS limpio."

# ---------- 3. Rotar MAC ----------
if $ROTATE_MAC; then
  log "Rotando MAC en interfaz $IFACE..."
  sudo ifconfig "$IFACE" ether $(openssl rand -hex 6 | sed 's/$$..$$/\1:/g; s/:$//')
  for svc in "${SERVICES[@]}"; do
    sudo networksetup -setairportpower "$svc" off 2>/dev/null || true
    sleep 1
    sudo networksetup -setairportpower "$svc" on 2>/dev/null || true
  done
  sleep 3
  ok "MAC nueva: $(ifconfig "$IFACE" | awk '/ether/{print $2}')"
fi

# ---------- 4. Borrar historial/cookies si no es perfil nuevo ----------
if $NEW_PROFILE; then
  TS=$(date +%Y%m%d_%H%M%S)
  NEWDIR="$PROFILE_BASE/carding_$TS"
  mkdir -p "$NEWDIR"
  ok "Perfil nuevo: $NEWDIR"
  PROFILE_DIR="$NEWDIR"
else
  log "Borrando datos de perfil existente..."
  # Chrome
  for p in "$HOME/Library/Application Support/Google/Chrome"/Default; do
    [ -d "$p" ] && rm -rf "$p/Cookies" "$p/History" "$p"/*" Session"* "$p/Local Storage" "$p/Session Storage" "$p/IndexedDB" 2>/dev/null || true
  done
  # Brave
  for p in "$HOME/Library/Application Support/BraveSoftware/Brave-Browser"/Default; do
    [ -d "$p" ] && rm -rf "$p/Cookies" "$p/History" "$p"/*" Session"* "$p/Local Storage" "$p/Session Storage" "$p/IndexedDB" 2>/dev/null || true
  done
  ok "Cookies, historial y storage borrados."
fi

# ---------- 5. Flags anti-detección ----------
FLAGS=(
  "--user-data-dir=${PROFILE_DIR:-$PROFILE_BASE/current}"
  "--no-first-run"
  "--no-default-browser-check"
  "--disable-features=CalculateNativeWinOcclusion,InterestFeedContentSuggestions"
  "--disable-background-networking"
  "--disable-sync"
  "--disable-blink-features=AutomationControlled"
  "--disable-webrtc-hw-encoding"
  "--enforce-webrtc-ip-handling-policy=default_public_interface_only"
  "--lang=en-US"
)

if [ -n "$PROXY" ]; then
  log "Usando proxy: $PROXY"
  FLAGS+=("--proxy-server=http://$PROXY")
fi

# ---------- 6. Lanzar navegador limpio ----------
log "Abriendo navegador con perfil limpio..."
if [ -x "$CHROME" ]; then
  "$CHROME" "${FLAGS[@]}" "https://www.nike.com/" &
elif [ -x "$BRAVE" ]; then
  "$BRAVE" "${FLAGS[@]}" "https://www.nike.com/" &
else
  warn "Ni Chrome ni Brave encontrados en /Applications."
  exit 1
fi

ok "Listo. Cardea, cierra el navegador y vuelve a correr este script para la siguiente ronda."
