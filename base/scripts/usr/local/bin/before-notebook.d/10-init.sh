#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Set defaults for environment variables in case they are undefined
LANG=${LANG:=en_US.UTF-8}
TZ=${TZ:=Etc/UTC}

if [ "$(id -u)" == 0 ] ; then
  # Update timezone if needed
  if [ "$TZ" != "Etc/UTC" ]; then
    echo "Setting TZ to $TZ"
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
      && echo "$TZ" > /etc/timezone
  fi

  # Add/Update locale if needed
  if [ -n "$LANGS" ]; then
    for i in $LANGS; do
      sed -i "s/# $i/$i/g" /etc/locale.gen
    done
  fi
  if [ "$LANG" != "en_US.UTF-8" ]; then
    sed -i "s/# $LANG/$LANG/g" /etc/locale.gen
  fi
  if [[ "$LANG" != "en_US.UTF-8" || -n "$LANGS" ]]; then
    locale-gen
  fi
  if [ "$LANG" != "en_US.UTF-8" ]; then
    echo "Setting LANG to $LANG"
    update-locale --reset LANG="$LANG"
  fi

  ## Autostart: DPI setting
  su "$NB_USER" -c "mkdir -p /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart/DPI setting.desktop" ]]; then
    su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.config/autostart/DPI\ setting.desktop \
      /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart/DPI\ setting.desktop"
    chown :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart/DPI setting.desktop"
  fi
  ## Xfce: Use custom xinitrc
  su "$NB_USER" -c "mkdir -p /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xinitrc" ]]; then
    su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.config/xfce4/xinitrc \
      /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xinitrc"
    chown :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xinitrc"
  fi
  ## Xfce Terminal: Font MesloLGS NF, Size 10, Encoding UTF-8
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal/terminalrc" ]]; then
    su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.config/xfce4/terminal/terminalrc \
      /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal/terminalrc"
    chown :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal/terminalrc"
  fi
  ## Xfce Appearance: Set style to Adwaita-dark
  su "$NB_USER" -c "mkdir -p /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]]; then
    su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
      /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
    chown :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
  fi
  ## Xfce Desktop: Set background to black
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ]]; then
    su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
      /home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
    chown :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
  fi

  ## QGIS Desktop: Put inital settings in place
  su "$NB_USER" -c "mkdir -p /home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      /home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
    chown :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
  fi

  ## QGIS Desktop: Copy plugin 'Processing Saga NextGen Provider'
  su "$NB_USER" -c "mkdir -p /home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  su "$NB_USER" -c "rm -rf /home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen"
  su "$NB_USER" -c "cp ${CP_OPTS:--a} /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
    /home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  chown -R :"$NB_GID" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins"

  # Remove old .zcompdump files
  rm -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.zcompdump"*
else
  # Warn if the user wants to change the timezone but hasn't started the
  # container as root.
  if [ "$TZ" != "Etc/UTC" ]; then
    echo "WARNING: Setting TZ to $TZ but /etc/localtime and /etc/timezone remain unchanged!"
  fi

  # Warn if the user wants to change the locale but hasn't started the
  # container as root.
  if [[ -n "$LANGS" ]]; then
    echo "WARNING: Container must be started as root to add locale(s)!"
  fi
  if [[ "$LANG" != "en_US.UTF-8" ]]; then
    echo "WARNING: Container must be started as root to update locale!"
    echo "Resetting LANG to en_US.UTF-8"
    LANG=en_US.UTF-8
  fi

  ## Autostart: DPI setting
  mkdir -p "$HOME/.config/autostart"
  if [[ ! -f "$HOME/.config/autostart/DPI setting.desktop" ]]; then
    cp -a "/var/backups/skel/.config/autostart/DPI setting.desktop" \
      "$HOME/.config/autostart/DPI setting.desktop"
  fi
  ## Xfce: Use custom xinitrc
  mkdir -p "$HOME/.config/xfce4/terminal"
  if [[ ! -f "$HOME/.config/xfce4/xinitrc" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xinitrc \
      "$HOME/.config/xfce4/xinitrc"
  fi
  ## Xfce Terminal: Font MesloLGS NF, Size 10, Encoding UTF-8
  if [[ ! -f "$HOME/.config/xfce4/terminal/terminalrc" ]]; then
    cp -a /var/backups/skel/.config/xfce4/terminal/terminalrc \
      "$HOME/.config/xfce4/terminal/terminalrc"
  fi
  ## Xfce Appearance: Set style to Adwaita-dark
  mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
  if [[ ! -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
      "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
  fi
  ## Xfce Desktop: Set background to black
  if [[ ! -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
      "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
  fi

  ## QGIS Desktop: Put inital settings in place
  mkdir -p "$HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS"
  if [[ ! -f "$HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      "$HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
  fi

  ## QGIS Desktop: Copy plugin 'Processing Saga NextGen Provider'
  mkdir -p "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  rm -rf "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen"
  cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
    "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins"

  # Remove old .zcompdump files
  rm -f "$HOME/.zcompdump"*
fi
