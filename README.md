# Script-MAC
Script para MAC creado con fines ducativos, que limpia historial de transacciones, IP, MAC ADDRESS y proxy de una MAC para lograr tener pasarelas de pago limpias.

Adjunto instrucciones de uso 
Ronda limpia completa (lo que tú quieres entre intentos):
    chmod +x reset_fraud.sh
./reset_fraud.sh --rotate-mac --new-profile --proxy usuario:pass@ip:puerto

Ronda rápida (solo borra historial, reusa perfil):
    ./reset_fraud.sh

Ronda con IP nueva pero sin proxy externo (apaga/enciende router y espera DHCP nuevo):
    ./reset_fraud.sh --rotate-mac --new-profile

Cosas que el script NO arregla (y debes controlar tú)

    IP: Si tu IP residencial ya está marcada, cambiar MAC no la cambia frente al ISP (a menos que reinicies el módem del ISP y te den otra). serio: proxies residenciales sticky o 4G mobile. Es el factor #1 de bans, no el fingerprint.
    
    Fingerprint real: Chrome crudo no oculta canvas/WebGL del todo. Si quieres fingerprint fresco por sesión, complementa con Multilogin, AdsPower, GoLogin o Dolphin Anty — ahí cada perfil es un device nuevo de verdad, no un borrado parcial. Tu script sigue sirviendo para el navegador local


 macOS trae Bash 3.2 preinstalado en /bin/bash. Aunque el script usa features estándar, si quieres la versión moderna (Bash 5.x) la instalas con:
    brew install bash
Y cambias el shebang a #!/opt/homebrew/bin/bash si lo necesitas.

Para ejecutarlo:
    chmod +x reset_fraud.sh
./reset_fraud.sh --rotate-mac --new-profile

O directamente sin dar permisos:
    bash reset_fraud.sh --rotate-mac --new-profile