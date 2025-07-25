ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=12
ARG CUDA_IMAGE
ARG CUDA_IMAGE_SUBTAG
ARG CUDA_VERSION=12.9.1
ARG QGIS_VERSION=3.42.3

ARG SAGA_VERSION
ARG OTB_VERSION
## OTB_VERSION=9.1.1

ARG PROC_SAGA_NG_VERSION

ARG NB_USER=jovyan
ARG NB_UID=1000
ARG JUPYTERHUB_VERSION=5.3.0
ARG JUPYTERLAB_VERSION=4.4.3
ARG PYTHON_VERSION=3.12.11
ARG GIT_VERSION=2.50.0
ARG TURBOVNC_VERSION=3.2
ARG VIRTUALGL_VERSION=${CUDA_IMAGE:+3.1.3}

FROM ${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG} AS files

ARG OTB_VERSION

ARG NB_UID
ENV NB_GID=100

RUN mkdir /files

COPY assets /files
COPY conf/ipython /files
COPY conf/jupyter /files
COPY conf/jupyterlab /files
COPY conf/shell /files
COPY conf${CUDA_IMAGE:+/cuda}/shell /files
COPY conf/user /files
COPY conf/xfce /files
COPY scripts /files

RUN if [ "$(uname -m)" = "x86_64" ]; then \
    ## QGIS: Set OTB application folder and OTB folder
    qgis3Ini="/files/var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"; \
    echo "\n[Processing]" >> ${qgis3Ini}; \
    if [ -z "${OTB_VERSION}" ]; then \
      echo "Configuration\OTB_APP_FOLDER=/usr/lib/otb/applications" >> \
        ${qgis3Ini}; \
      echo "Configuration\OTB_FOLDER=/usr\n" >> ${qgis3Ini}; \
    else \
      echo "Configuration\OTB_APP_FOLDER=/usr/local/lib/otb/applications" >> \
        ${qgis3Ini}; \
      echo "Configuration\OTB_FOLDER=/usr/local\n" >> ${qgis3Ini}; \
    fi \
  fi \
  ## Copy content of skel directory to backup
  && cp -a /files/etc/skel/. /files/var/backups/skel \
  && chown -R ${NB_UID}:${NB_GID} /files/var/backups/skel \
  && if [ -n "${CUDA_VERSION}" ]; then \
    ## Use entrypoint of CUDA image
    apt-get update; \
    apt-get -y install --no-install-recommends git; \
    git clone https://gitlab.com/nvidia/container-images/cuda.git \
      /opt/nvidia; \
    mv /opt/nvidia/entrypoint.d /opt/nvidia/nvidia_entrypoint.sh \
      /files/usr/local/bin; \
    mv /files/usr/local/bin/start.sh \
      /files/usr/local/bin/entrypoint.d/99-start.sh; \
    mv /files/usr/local/bin/nvidia_entrypoint.sh \
      /files/usr/local/bin/start.sh; \
  fi \
  ## Ensure file modes are correct when using CI
  ## Otherwise set to 777 in the target image
  && find /files -type d -exec chmod 755 {} \; \
  && find /files -type f -exec chmod 644 {} \; \
  && find /files/usr/local/bin -type f -exec chmod 755 {} \; \
  && find /files/etc/profile.d -type f -exec chmod 755 {} \; \
  && chmod 755 /files/var/backups/skel/.config/xfce4/xinitrc

FROM glcr.b-data.ch/qgis/qgissi/${QGIS_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} AS qgissi
FROM glcr.b-data.ch/saga-gis/saga-gissi${SAGA_VERSION:+/}${SAGA_VERSION:-:none}${SAGA_VERSION:+/$BASE_IMAGE}${SAGA_VERSION:+:$BASE_IMAGE_TAG} AS saga-gissi
FROM glcr.b-data.ch/python/psi${PYTHON_VERSION:+/}${PYTHON_VERSION:-:none}${PYTHON_VERSION:+/$BASE_IMAGE}${PYTHON_VERSION:+:$BASE_IMAGE_TAG} AS psi
FROM glcr.b-data.ch/git/gsi${GIT_VERSION:+/}${GIT_VERSION:-:none}${GIT_VERSION:+/$BASE_IMAGE}${GIT_VERSION:+:$BASE_IMAGE_TAG} AS gsi
FROM glcr.b-data.ch/orfeotoolbox/otbsi${OTB_VERSION:+/}${OTB_VERSION:-:none}${OTB_VERSION:+/$BASE_IMAGE}${OTB_VERSION:+:$BASE_IMAGE_TAG} AS otbsi

FROM ${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG} AS base-cuda

## For use with the NVIDIA Container Runtime
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_PRODUCT_NAME=CUDA

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS base

FROM base${CUDA_IMAGE:+-cuda}

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG CUDA_IMAGE
ARG CUDA_IMAGE_SUBTAG
ARG CUDA_VERSION
ARG QGIS_VERSION
ARG SAGA_VERSION
ARG OTB_VERSION
ARG PROC_SAGA_NG_VERSION
ARG NB_USER
ARG NB_UID
ARG JUPYTERHUB_VERSION
ARG JUPYTERLAB_VERSION
ARG PYTHON_VERSION
ARG GIT_VERSION
ARG TURBOVNC_VERSION
ARG VIRTUALGL_VERSION
ARG BUILD_START

ARG CUDA_IMAGE_LICENSE=${CUDA_VERSION:+"NVIDIA Deep Learning Container License"}
ARG IMAGE_LICENSE=${CUDA_IMAGE_LICENSE:-"MIT"}
ARG IMAGE_SOURCE=https://gitlab.b-data.ch/jupyterlab/qgis
ARG IMAGE_VENDOR="b-data GmbH"
ARG IMAGE_AUTHORS="Olivier Benz <olivier.benz@b-data.ch>"

LABEL org.opencontainers.image.licenses="$IMAGE_LICENSE" \
      org.opencontainers.image.source="$IMAGE_SOURCE" \
      org.opencontainers.image.vendor="$IMAGE_VENDOR" \
      org.opencontainers.image.authors="$IMAGE_AUTHORS"

ENV BASE_IMAGE=${BASE_IMAGE}:${BASE_IMAGE_TAG} \
    CUDA_IMAGE=${CUDA_IMAGE}${CUDA_IMAGE:+:}${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG} \
    PARENT_IMAGE=${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG} \
    NVIDIA_DRIVER_CAPABILITIES=${CUDA_IMAGE:+utility,graphics,video,display} \
    QGIS_VERSION=${QGIS_VERSION} \
    SAGA_VERSION=${SAGA_VERSION} \
    OTB_VERSION=${OTB_VERSION} \
    NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    JUPYTERHUB_VERSION=${JUPYTERHUB_VERSION} \
    JUPYTERLAB_VERSION=${JUPYTERLAB_VERSION} \
    PYTHON_VERSION=${PYTHON_VERSION} \
    GIT_VERSION=${GIT_VERSION} \
    TURBOVNC_VERSION=${TURBOVNC_VERSION} \
    VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
    BUILD_DATE=${BUILD_START}

ENV NB_GID=100 \
    ## GRASS GIS: Make sure the distro's python is used
    GRASS_PYTHON=/usr/bin/python3 \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

## Install QGIS
COPY --from=qgissi /usr /usr
## Install Git
COPY --from=gsi /usr/local /usr/local
## Install Python
COPY --from=psi /usr/local /usr/local
## Install SAGA GIS
COPY --from=saga-gissi /usr /usr
## Install Orfeo Toolbox
COPY --from=otbsi /usr/local /usr/local
ENV GDAL_DRIVER_PATH=${OTB_VERSION:+disable} \
    OTB_APPLICATION_PATH=${OTB_VERSION:+/usr/local/lib/otb/applications} \
    OTB_INSTALL_DIR=${OTB_VERSION:+/usr/local}
ENV OTB_APPLICATION_PATH=${OTB_APPLICATION_PATH:-/usr/lib/otb/applications} \
    OTB_INSTALL_DIR=${OTB_INSTALL_DIR:-/usr}

USER root

RUN dpkgArch="$(dpkg --print-architecture)" \
  ## Unminimise if the system has been minimised
  && if [ $(command -v unminimize) ]; then \
    yes | unminimize; \
  fi \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    ## Language ver-tagged images
    ca-certificates \
    locales \
    netbase \
    tzdata \
    unzip \
    zip \
    ## JupyterLab base-tagged images
    bash-completion \
    build-essential \
    curl \
    file \
    fontconfig \
    g++ \
    gcc \
    gfortran \
    $(test -z "${GIT_VERSION}" && echo "git") \
    gnupg \
    htop \
    info \
    jq \
    libclang-dev \
    man-db \
    nano \
    ncdu \
    procps \
    psmisc \
    screen \
    sudo \
    swig \
    tmux \
    vim-tiny \
    wget \
    zsh \
    ## JupyterLab R verse image
    ghostscript \
    imagemagick \
    librsvg2-bin \
    ## JupyterLab R geospatial image
    nco \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    ## Multimedia files trancoding
    ffmpeg \
    ## Git: Additional runtime dependencies
    libcurl3-gnutls \
    liberror-perl \
    ## Git: Additional runtime recommendations
    less \
    ssh-client \
  ## Additional python-dev dependencies
  && if [ -z "$PYTHON_VERSION" ]; then \
    apt-get -y install --no-install-recommends \
      python3-dev \
      ## Install Python package installer
      ## (dep: python3-distutils, python3-setuptools and python3-wheel)
      python3-pip \
      ## Install venv module for python3
      python3-venv; \
    ## make some useful symlinks that are expected to exist
    ## ("/usr/bin/python" and friends)
    for src in pydoc3 python3 python3-config; do \
      dst="$(echo "$src" | tr -d 3)"; \
      if [ -s "/usr/bin/$src" ] && [ ! -e "/usr/bin/$dst" ]; then \
        ln -svT "$src" "/usr/bin/$dst"; \
      fi \
    done; \
  else \
    ## Force update pip, setuptools and wheel
    pip install --upgrade --force-reinstall \
      pip \
      setuptools \
      wheel; \
  fi \
  ## Install font MesloLGS NF
  && mkdir -p /usr/share/fonts/truetype/meslo \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Regular.ttf" \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Bold.ttf" \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Italic.ttf" \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Bold Italic.ttf" \
  && fc-cache -fv \
  ## Git: Set default branch name to main
  && git config --system init.defaultBranch main \
  ## Git: Store passwords for one hour in memory
  && git config --system credential.helper "cache --timeout=3600" \
  ## Git: Merge the default branch from the default remote when "git pull" is run
  && git config --system pull.rebase false \
  ## Delete potential user with UID 1000
  && if grep -q 1000 /etc/passwd; then \
    userdel --remove $(id -un 1000); \
  fi \
  ## Add user
  && useradd -l -m -s $(which zsh) -N -u ${NB_UID} ${NB_USER} \
  ## Mark home directory as populated
  && touch /home/${NB_USER}/.populated \
  && chown ${NB_UID}:${NB_GID} /home/${NB_USER}/.populated \
  && chmod go+w /home/${NB_USER}/.populated \
  ## Create backup directory for home directory
  && mkdir -p /var/backups/skel \
  && chown ${NB_UID}:${NB_GID} /var/backups/skel \
  ## Install Tini
  && curl -sL https://github.com/krallin/tini/releases/download/v0.19.0/tini-${dpkgArch} -o /usr/local/bin/tini \
  && chmod +x /usr/local/bin/tini \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache

RUN export $(cat /etc/os-release | grep "^ID=debian" | xargs) \
    > /dev/null \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    ## QGIS: Additional runtime dependencies
    '^libexiv2-[0-9]+$' \
    '^libgdal[0-9]+$' \
    libgeos-c1v5 \
    '^libgsl[0-9]+$' \
    libjs-jquery \
    libjs-leaflet \
    '^libprotobuf-lite[0-9]+$' \
    libqca-qt5-2-plugins \
    '^libqscintilla2-qt5-[0-9]+$' \
    libqt5core5a \
    libqt5gui5 \
    libqt5keychain1 \
    libqt5multimediawidgets5 \
    libqt5network5 \
    libqt5quickwidgets5 \
    libqt5serialport5 \
    libqt5sql5 \
    libqt5webkit5 \
    libqt5widgets5 \
    libqt5xml5 \
    libqwt-qt5-6 \
    '^libspatialindex[0-9]+$' \
    '^libzip[0-9]+$' \
    ocl-icd-libopencl1 \
    qt3d-assimpsceneimport-plugin \
    qt3d-defaultgeometryloader-plugin \
    qt3d-gltfsceneio-plugin \
    qt3d-scene2d-plugin \
    qt5-image-formats-plugins \
    ## QGIS: Python 3 Support
    gdal-bin \
    libfcgi0ldbl \
    libsqlite3-mod-spatialite \
    python3-gdal \
    python3-jinja2 \
    python3-lxml \
    python3-matplotlib \
    python3-owslib \
    python3-plotly \
    python3-psycopg2 \
    python3-pygments \
    python3-pyproj \
    python3-pyqt5 \
    python3-pyqt5.qsci \
    python3-pyqt5.qtmultimedia \
    python3-pyqt5.qtpositioning \
    python3-pyqt5.qtserialport \
    python3-pyqt5.qtsql \
    python3-pyqt5.qtsvg \
    python3-pyqt5.qtwebkit \
    python3-sip \
    python3-yaml \
    qttools5-dev-tools \
    ## QGIS: Additional runtime recommendations
    grass \
    ## QGIS: Additional runtime suggestions
    gpsbabel \
    ## Xfce Lightweight Desktop Environment
    adwaita-icon-theme* \
    firefox${ID:+-esr} \
    gnome-themes-extra \
    mousepad \
    ristretto \
    websockify \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xfce4-taskmanager \
    xfce4-terminal \
    xorg \
    ## xfdesktop4 recommends
    dbus-x11 \
    librsvg2-common \
    tumbler \
    xdg-user-dirs \
    ## Thunar recommends
    gvfs \
    libglib2.0-bin \
    ## Thunar suggests
    thunar-archive-plugin \
    xarchiver \
    ## SAGA GIS: Supplementary runtime dependencies [^1]
    libdxflib3 \
    libhpdf-2.3.0 \
    libsvm3 \
    libwxgtk3.*-dev \
    $(test -z "${SAGA_VERSION}" && echo "saga") \
  ## Orfeo Toolbox: Supplementary runtime dependencies
  && if [ "$(uname -m)" = "x86_64" ]; then \
    apt-get -y install --no-install-recommends \
      '^libboost-filesystem[0-9].[0-9]+.[0-9]$' \
      '^libboost-serialization[0-9].[0-9]+.[0-9]$' \
      libglew2.* \
      '^libinsighttoolkit4.[0-9]+$' \
      libmuparser2v5 \
      libmuparserx4.* \
      '^libopencv-core[0-9][0-9.][0-9][a-z]?$' \
      '^libopencv-ml[0-9][0-9.][0-9][a-z]?$' \
      libtinyxml-dev \
      $(test -z "${OTB_VERSION}" && echo "otb-* monteverdi"); \
    if [ ! -z "${OTB_VERSION}" ]; then \
      if [ "$(echo ${OTB_VERSION} | cut -c 1)" -lt "8" ]; then \
        apt-get -y install --no-install-recommends \
          '^libopenthreads[0-9]+$' \
          libossim1; \
      fi; \
      ## Orfeo Toolbox: Clean up installation
      bash -c 'rm -rf /usr/local/{otbenv.profile,recompile_bindings.sh,tools}'; \
      if [ -f /usr/local/README ]; then \
        mv /usr/local/README /usr/local/share/doc/otb; \
      fi; \
      if [ -f /usr/local/LICENSE ]; then \
        mv /usr/local/LICENSE /usr/local/share/doc/otb; \
      fi \
    else \
      mkdir -p /usr/lib/otb; \
      ln -rs /usr/lib/$(uname -m)-linux-gnu/otb/applications \
        /usr/lib/otb/applications; \
    fi \
  fi \
  ## Ubuntu: Install Firefox from PPA as snap installation does not work
  && if [ $(command -v snap) ]; then \
    apt-get -y purge firefox; \
    apt-get update; \
    apt-get -y install --no-install-recommends software-properties-common; \
    add-apt-repository ppa:mozillateam/ppa; \
    echo "Package: firefox*" >> /etc/apt/preferences.d/mozilla-firefox; \
    echo "Pin: release o=LP-PPA-mozillateam" >> /etc/apt/preferences.d/mozilla-firefox; \
    echo "Pin-Priority: 501" >> /etc/apt/preferences.d/mozilla-firefox; \
    apt-get update; \
    apt-get -y install --no-install-recommends firefox; \
    apt-get -y purge software-properties-common; \
    apt-get -y autoremove; \
  fi \
  ## Older distros: rebind.so might be named differently...
  && if [ ! -f "/usr/lib/websockify/rebind.so" ]; then \
    ln -rs /usr/lib/websockify/rebind*.so /usr/lib/websockify/rebind.so; \
  fi \
  ## GRASS GIS: Configure dynamic linker run time bindings
  && echo "$(grass --config path)/lib" | tee /etc/ld.so.conf.d/libgrass.conf \
  && ldconfig \
  ## Xfce: Remove 'Log Out' from Applications
  && rm -f /usr/share/applications/xfce4-session-logout.desktop \
  ## Xfce: Disable Ctrl+Alt+Del to trigger session logout
  && sed -i "/xfce4-session-logout/d" \
    /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml \
  ## Xfce Panel: Set dark mode to false by default
  && sed -i 's/name="dark-mode" type="bool" value="true"/name="dark-mode" type="bool" value="false"/g' \
    /etc/xdg/xfce4/panel/default.xml \
  ## SAGA GIS: Add en_GB.UTF-8 and update locale
  && sed -i "s/# $LANG/$LANG/g" /etc/locale.gen \
  && sed -i "s/# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=$LANG \
  ## [^1]: SAGA GIS: libvigraimpex11 is not available for jammy
  && if $(! grep -q "jammy" /etc/os-release); then \
    apt-get -y install --no-install-recommends '^libvigraimpex[0-9]+$'; \
  fi \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.grass* \
    ${HOME}/.launchpadlib

## Install JupyterLab
RUN export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && pip install --force \
    git+https://github.com/b-data/jupyter-remote-desktop-proxy.git@QGIS \
    jupyterhub==${JUPYTERHUB_VERSION} \
    jupyterlab==${JUPYTERLAB_VERSION} \
    jupyterlab-git \
    jupyterlab-lsp \
    notebook \
    nbclassic \
    nbconvert \
    python-lsp-server[all] \
  ## Jupyter Server Proxy: Set maximum allowed HTTP body size to 10 GiB
  && sed -i 's/AsyncHTTPClient(/AsyncHTTPClient(max_body_size=10737418240, /g' \
    /usr/local/lib/python*/*-packages/jupyter_server_proxy/handlers.py \
  ## Jupyter Server Proxy: Set maximum allowed websocket message size to 1 GiB
  && sed -i 's/"_default_max_message_size",.*$/"_default_max_message_size", 1024 \* 1024 \* 1024/g' \
    /usr/local/lib/python*/*-packages/jupyter_server_proxy/websocket.py \
  && sed -i 's/_default_max_message_size =.*$/_default_max_message_size = 1024 \* 1024 \* 1024/g' \
    /usr/local/lib/python*/*-packages/tornado/websocket.py \
  ## Copy custom fonts
  && mkdir -p /usr/local/share/jupyter/lab/static/assets/fonts \
  && cp -a /usr/share/fonts/truetype/meslo/*.ttf /usr/local/share/jupyter/lab/static/assets/fonts \
  ## Include custom fonts
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Regular.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Italic.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Bold.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Bold Italic.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="stylesheet" type="text/css" href="{{page_config.fullStaticUrl}}/assets/css/fonts.css"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  ## Clean up
  && rm -rf /tmp/* \
    ${HOME}/.cache

## Install QGIS related stuff
RUN apt-get update \
  ## Install QGIS-Plugin-Manager
  && apt-get -y install --no-install-recommends python3-pip \
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && /usr/bin/pip install qgis-plugin-manager \
  ## Clean up
  && if [ ! -z "$PYTHON_VERSION" ]; then \
    apt-get -y purge python3-pip; \
    apt-get -y autoremove; \
  fi \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.config \
    ${HOME}/.local

ENV PATH=/opt/TurboVNC/bin:$PATH

## Install TurboVNC
RUN dpkgArch="$(dpkg --print-architecture)" \
  && curl -fsSL "https://github.com/TurboVNC/turbovnc/releases/download/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_${dpkgArch}.deb" -o turbovnc.deb \
  && apt-get install -y ./turbovnc.deb \
  && if [ -n "$CUDA_IMAGE" ]; then \
    ## Install VirtualGL
    curl -fsSL "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_${dpkgArch}.deb" -o virtualgl.deb; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      mesa-utils \
      ./virtualgl.deb; \
    ## Install misc Vulkan utilities
    apt-get install -y --no-install-recommends \
      mesa-vulkan-drivers \
      vulkan-tools; \
    ## Make libraries available for preload
    chmod u+s /usr/lib/libvglfaker.so; \
    chmod u+s /usr/lib/libdlfaker.so; \
    ## Configure EGL manually (fallback)
    mkdir -p /usr/share/glvnd/egl_vendor.d/; \
    echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\" : {\n\
        \"library_path\" : \"libEGL_nvidia.so.0\"\n\
    }\n\
}" > /usr/share/glvnd/egl_vendor.d/10_nvidia.json; \
    ## Configure Vulkan manually (fallback)
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)'); \
    mkdir -p /etc/vulkan/icd.d/; \
    echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libGLX_nvidia.so.0\",\n\
        \"api_version\" : \"${VULKAN_API_VERSION}\"\n\
    }\n\
}" > /etc/vulkan/icd.d/nvidia_icd.json; \
  fi \
  ## Clean up
  && rm -rf /var/lib/apt/lists/* \
    turbovnc.deb \
    virtualgl.deb

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER} \
    SHELL=/usr/bin/zsh \
    TERM=xterm-256color

WORKDIR ${HOME}

## Install Oh My Zsh with Powerlevel10k theme
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k \
  && ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install -f \
  && sed -i 's/ZSH="\/home\/jovyan\/.oh-my-zsh"/ZSH="${HOME}\/.oh-my-zsh"/g' ${HOME}/.zshrc \
  && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ${HOME}/.zshrc \
  && echo "\n# set PATH so it includes user's private bin if it exists\nif [ -d \"\$HOME/bin\" ] && [[ \"\$PATH\" != *\"\$HOME/bin\"* ]] ; then\n    PATH=\"\$HOME/bin:\$PATH\"\nfi" | tee -a ${HOME}/.bashrc ${HOME}/.zshrc \
  && echo "\n# set PATH so it includes user's private bin if it exists\nif [ -d \"\$HOME/.local/bin\" ] && [[ \"\$PATH\" != *\"\$HOME/.local/bin\"* ]] ; then\n    PATH=\"\$HOME/.local/bin:\$PATH\"\nfi" | tee -a ${HOME}/.bashrc ${HOME}/.zshrc \
  && echo "\n# Update last-activity timestamps while in screen/tmux session\nif [ ! -z \"\$TMUX\" -o ! -z \"\$STY\" ] ; then\n    busy &\nfi" >> ${HOME}/.bashrc \
  && echo "\n# Update last-activity timestamps while in screen/tmux session\nif [ ! -z \"\$TMUX\" -o ! -z \"\$STY\" ] ; then\n    setopt nocheckjobs\n    busy &\nfi" >> ${HOME}/.zshrc \
  && echo "\n# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> ${HOME}/.zshrc \
  && echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> ${HOME}/.zshrc \
  ## Create user's private bin
  && mkdir -p ${HOME}/.local/bin

## Copy files as late as possible to avoid cache busting
COPY --from=files /files /
COPY --from=files /files/var/backups/skel ${HOME}

  ## QGIS: Install plugin 'Processing Saga NextGen Provider'
RUN export QT_QPA_PLATFORM=offscreen \
  && mkdir -p ${HOME}/.local/share/QGIS/QGIS3/profiles/default/python/plugins \
  && cd ${HOME}/.local/share/QGIS/QGIS3/profiles/default/python/plugins \
  && qgis-plugin-manager init \
  && qgis-plugin-manager update \
  && qgis-plugin-manager install 'Processing Saga NextGen Provider'=="${PROC_SAGA_NG_VERSION:-0.0.7}" \
  ## QGIS: Enable plugins
  && qgis_process plugins enable processing_saga_nextgen \
  && qgis_process plugins enable grassprovider \
  && if [ "$(uname -m)" = "x86_64" ]; then \
    ## QGIS: Install and enable OTB plugin
    qgis-plugin-manager install 'OrfeoToolbox Provider'; \
    qgis_process plugins enable orfeoToolbox_provider; \
  fi \
  && rm -rf .cache_qgis_plugin_manager \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf \
    ${HOME}/.cache/QGIS \
    ${HOME}/.cache/qgis_process* \
    ${HOME}/.config \
    ${HOME}/.grass* \
  ## Record population timestamp
  && date -uIseconds > ${HOME}/.populated \
  ## Create backup of home directory
  && cp -a ${HOME}/. /var/backups/skel

ENV PYTHONPATH=${PYTHONPATH:+$PYTHONPATH:}${OTB_VERSION:+/usr/local/lib/otb/python}

ARG JUPYTER_PORT=8888
ENV JUPYTER_PORT=${JUPYTER_PORT}

EXPOSE $JUPYTER_PORT

## Configure container startup
ENTRYPOINT ["tini", "-g", "--", "start.sh"]
CMD ["start-notebook.sh"]
