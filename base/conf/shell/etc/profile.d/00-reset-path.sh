# Reset default PATH settings
if [ "$(id -u)" -eq 0 ]; then
  PATH="/opt/TurboVNC/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else
  PATH="/opt/TurboVNC/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
fi
export PATH
