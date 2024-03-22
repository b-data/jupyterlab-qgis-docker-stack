#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ "$(id -u)" == 0 ] ; then
  # Set DPI
  run_user_group mkdir -p "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart/DPI setting.desktop" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      "/var/backups/skel/.config/autostart/DPI setting.desktop" \
      "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/autostart/DPI setting.desktop"
  fi
  # Use custom xinitrc
  run_user_group mkdir -p "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xinitrc" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      /var/backups/skel/.config/xfce4/xinitrc \
      "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xinitrc"
  fi
  # Terminal: Font MesloLGS NF, Size 10, Encoding UTF-8
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal/terminalrc" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      /var/backups/skel/.config/xfce4/terminal/terminalrc \
      "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/terminal/terminalrc"
  fi
  # Appearance: Set style to Adwaita-dark
  run_user_group mkdir -p "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
      "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
  fi
  # Desktop: Set background to black
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
      "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
  fi
else
  # Set DPI
  mkdir -p "$HOME/.config/autostart"
  if [[ ! -f "$HOME/.config/autostart/DPI setting.desktop" ]]; then
    cp -a "/var/backups/skel/.config/autostart/DPI setting.desktop" \
      "$HOME/.config/autostart/DPI setting.desktop"
  fi
  # Use custom xinitrc
  mkdir -p "$HOME/.config/xfce4/terminal"
  if [[ ! -f "$HOME/.config/xfce4/xinitrc" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xinitrc \
      "$HOME/.config/xfce4/xinitrc"
  fi
  # Terminal: Font MesloLGS NF, Size 10, Encoding UTF-8
  if [[ ! -f "$HOME/.config/xfce4/terminal/terminalrc" ]]; then
    cp -a /var/backups/skel/.config/xfce4/terminal/terminalrc \
      "$HOME/.config/xfce4/terminal/terminalrc"
  fi
  # Appearance: Set style to Adwaita-dark
  mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
  if [[ ! -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
      "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
  fi
  # Desktop: Set background to black
  if [[ ! -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ]]; then
    cp -a /var/backups/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
      "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
  fi
fi
