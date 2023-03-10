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
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
      && echo $TZ > /etc/timezone
  fi

  # Add/Update locale if needed
  if [ ! -z "$LANGS" ]; then
    for i in $LANGS; do
      sed -i "s/# $i/$i/g" /etc/locale.gen
    done
  fi
  if [ "$LANG" != "en_US.UTF-8" ]; then
    sed -i "s/# $LANG/$LANG/g" /etc/locale.gen
  fi
  if [[ "$LANG" != "en_US.UTF-8" || ! -z "$LANGS" ]]; then
    locale-gen
  fi
  if [ "$LANG" != "en_US.UTF-8" ]; then
    echo "Setting LANG to $LANG"
    update-locale --reset LANG=$LANG
  fi

  ## Xfce: Use custom xinitrc
  su $NB_USER -c "mkdir -p .config/xfce4/terminal"
  if [[ ! -f ".config/xfce4/xinitrc" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.config/xfce4/xinitrc \
      .config/xfce4/xinitrc"
  fi
  ## Xfce Terminal: Font MesloLGS NF, Size 12, Encoding UTF-8
  if [[ ! -f ".config/xfce4/terminal/terminalrc" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.config/xfce4/terminal/terminalrc \
      .config/xfce4/terminal/terminalrc"
  fi
  ## Xfce Appearance: Set style to Adwaita-dark
  su $NB_USER -c "mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml"
  if [[ ! -f ".config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
      .config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
  fi
  ## Xfce Desktop: Set background to black
  if [[ ! -f ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
      .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
  fi

  ## QGIS Desktop: Put inital settings in place
  su $NB_USER -c "mkdir -p .local/share/QGIS/QGIS3/profiles/default/QGIS"
  if [[ ! -f ".local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      .local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
  fi

  ## QGIS Desktop: Copy plugin 'Processing Saga NextGen Provider'
  su $NB_USER -c "mkdir -p .local/share/QGIS/QGIS3/profiles/default/python/plugins"
  if [[ ! -d ".local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
      .local/share/QGIS/QGIS3/profiles/default/python/plugins"
  fi
else
  # Warn if the user wants to change the timezone but hasn't started the
  # container as root.
  if [ "$TZ" != "Etc/UTC" ]; then
    echo "WARNING: Setting TZ to $TZ but /etc/localtime and /etc/timezone remain unchanged!"
  fi

  # Warn if the user wants to change the locale but hasn't started the
  # container as root.
  if [[ ! -z "$LANGS" ]]; then
    echo "WARNING: Container must be started as root to add locale(s)!"
  fi
  if [[ "$LANG" != "en_US.UTF-8" ]]; then
    echo "WARNING: Container must be started as root to update locale!"
    echo "Resetting LANG to en_US.UTF-8"
    LANG=en_US.UTF-8
  fi

  ## Xfce: Use custom xinitrc
  mkdir -p .config/xfce4/terminal
  if [[ ! -f ".config/xfce4/xinitrc" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xinitrc \
      .config/xfce4/xinitrc
  fi
  ## Xfce Terminal: Font MesloLGS NF, Size 12, Encoding UTF-8
  if [[ ! -f ".config/xfce4/terminal/terminalrc" ]]; then
    cp -a /var/backups/skel/.config/xfce4/terminal/terminalrc \
      .config/xfce4/terminal/terminalrc
  fi
  ## Xfce Appearance: Set style to Adwaita-dark
  mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml
  if [[ ! -f ".config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
      .config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
  fi
  ## Xfce Desktop: Set background to black
  if [[ ! -f ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
      .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
  fi

  ## QGIS Desktop: Put inital settings in place
  mkdir -p .local/share/QGIS/QGIS3/profiles/default/QGIS
  if [[ ! -f ".local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      .local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini
  fi

  ## QGIS Desktop: Copy plugin 'Processing Saga NextGen Provider'
  mkdir -p .local/share/QGIS/QGIS3/profiles/default/python/plugins
  if [[ ! -d ".local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen" ]]; then
    cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
      .local/share/QGIS/QGIS3/profiles/default/python/plugins
  fi
fi

# Remove old .zcompdump files
rm -f .zcompdump*
