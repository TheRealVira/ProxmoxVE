#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: TheRealVira
# License: MIT
# Source: https://5e.tools/

# Import Functions und Setup
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  mc \
  sudo \
  git \
  apache2
msg_ok "Installed Dependencies"

# Setup App
msg_info "Setup 5etools"
rm -rf /var/www/html
git config --global http.postBuffer 1048576000
git config --global https.postBuffer 1048576000
git clone https://github.com/5etools-mirror-3/5etools-src /opt/5etools
cd /opt/5etools
git submodule add -f https://github.com/5etools-mirror-2/5etools-img "img"
git pull --recurse-submodules --jobs=10
cd ~
msg_ok "Set up 5etools"

msg_info "Creating Service"
cat <<EOF >> /etc/apache2/apache2.conf
<Location /server-status>
    SetHandler server-status
    Order deny,allow
    Allow from all
</Location>
EOF
ln -s "/opt/5etools" /var/www/html

chown -R www-data: "/opt/5etools"
chmod -R 755 "/opt/5etools"
apache2ctl start
msg_ok "Creating Service"
# Cleanup
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

motd_ssh
customize
