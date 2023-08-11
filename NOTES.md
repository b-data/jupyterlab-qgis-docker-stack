# Notes

This docker stack uses modified startup scripts from
[jupyter/docker-stacks](https://github.com/jupyter/docker-stacks).  
:information_source: Nevertheless, all [Docker Options](https://github.com/jupyter/docker-stacks/blob/main/docs/using/common.md#docker-options)
and [Permission-specific configurations](https://github.com/jupyter/docker-stacks/blob/main/docs/using/common.md#permission-specific-configurations)
can be used for the images of this docker stack.

## Tweaks

In comparison to
[pangeo-data/jupyter-earth](https://github.com/pangeo-data/jupyter-earth), these
images are tweaked as follows:

### Jupyter startup scripts

Shell script [/usr/local/bin/start.sh](base/scripts/usr/local/bin/start.sh) is
modified to

* allow *bind mounting* of a home directory.

### Jupyter startup hooks

The following startup hooks are put in place:

* [/usr/local/bin/start-notebook.d/populate.sh](base/scripts/usr/local/bin/start-notebook.d/populate.sh)
  to populate a *bind mounted* home directory `/home/jovyan`.
* [/usr/local/bin/before-notebook.d/init.sh](base/scripts/usr/local/bin/before-notebook.d/init.sh) to
  * update timezone according to environment variable `TZ`.
  * add locales according to environment variable `LANGS`.
  * set locale according to environment variable `LANG`.
  * use custom xinitrc (Xfce).
  * set font to MesloLGS NF (Xfce Terminal).
  * put inital settings in place (QGIS Desktop).
  * copy plugin 'Processing Saga NextGen Provider' (QGIS Desktop).

### Custom scripts

[/usr/local/bin/busy](base/scripts/usr/local/bin/busy) is executed during
`screen`/`tmux` sessions to update the last-activity timestamps on JupyterHub.  
:information_source: This prevents the [JupyterHub Idle Culler Service](https://github.com/jupyterhub/jupyterhub-idle-culler)
from shutting down idle or long-running Jupyter Notebook servers, allowing for
unattended computations.

### Environment variables

**Versions**

* `QGIS_VERSION`
* `JUPYTERHUB_VERSION`
* `JUPYTERLAB_VERSION`
* `PYTHON_VERSION`
* `GIT_VERSION`
* `OTB_VERSION`
* `TURBOVNC_VERSION`

**GRASS GIS**

* `GRASS_PYTHON`: Set to `/usr/bin/python3`

Otherwise, `grass` would use `/user/local/bin/python3`.  
:information_source: `grass` was built against Python and packages from the
distro's package repository.

**Orfeo Toolbox**

* `GDAL_DRIVER_PATH`: Set to `disable` (amd64 only)
* `OTB_APPLICATION_PATH`: Set to `/usr/local/lib/otb/applications` (amd64 only)
* `PYTHONPATH`: Set to `/usr/local/lib/otb/python` (amd64 only)

A subset of the environment variables used in [`otbenv.profile`](https://github.com/orfeotoolbox/OTB/blob/develop/Packaging/Files/otbenv.profile).

**Miscellaneous**

* `BASE_IMAGE`: Its very base, a [Docker Official Image](https://hub.docker.com/search?q=&type=image&image_filter=official).
* `PARENT_IMAGE`: The image it was derived from.
* `BUILD_DATE`: The date it was built (ISO 8601 format).

### Shell

The default shell is Zsh, further enhanced with

* Framework: [Oh My Zsh](https://ohmyz.sh/)
* Theme: [Powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh)
* Font: [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts)

## Settings

### Default

* [IPython](base/conf/ipython/usr/local/etc/ipython/ipython_config.py):
  * Only enable figure formats `svg` and `pdf` for IPython.
* [IPython kernel](base/conf/ipython/usr/local/etc/ipython/ipython_kernel_config.py):
  * Only enable figure formats `svg` and `pdf` for IPython Kernel (Jupyter
    Notebooks).
* [JupyterLab](base/conf/jupyterlab/usr/local/share/jupyter/lab/settings/overrides.json):
  * Theme > Selected Theme: JupyterLab Dark
  * Terminal > Font family: MesloLGS NF
  * Python LSP Server: Example settings according to [jupyter-lsp/jupyterlab-lsp > Installation > Configuring the servers](https://github.com/jupyter-lsp/jupyterlab-lsp#configuring-the-servers)
* [Xfce xinitrc](base/conf/user/var/backups/skel/.config/xfce4/xinitrc):
  * Allow users to set `LANG` in `~/.i18n` to change the system language.
* [Xfce Panel](base/conf/xfce/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml):
  * Hide 'Lock Screen' and 'Log Out...' because those kill the session.  
    (Removed: 'Log Out' from Applications)  
    (Disabled: Ctrl+Alt+Del to trigger session logout)
* [Xfce Terminal](base/conf/user/var/backups/skel/.config/xfce4/terminal/terminalrc):
  * Set `FontName=MesloLGS NF 12` and `Encoding=UTF-8`.
* [QGIS Desktop](base/conf/user/var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini):
  * Append `/usr/lib/python3/dist-packages` to `PYTHONPATH`.  
    :information_source: One distro refused to find the Python bindings to QGIS
    (at `/usr/lib/python3/dist-packages/qgis`)...
* Zsh
  * Oh My Zsh: `~/.zshrc`
    * Set PATH so it includes user's private bin if it exists
    * Update last-activity timestamps while in screen/tmux session
  * [Powerlevel10k](base/conf/user/var/backups/skel/.p10k.zsh): `p10k configure`
    * Does this look like a diamond (rotated square)?: (y)  Yes.
    * Does this look like a lock?: (y)  Yes.
    * Does this look like a Debian logo (swirl/spiral)?: (y)  Yes.
    * Do all these icons fit between the crosses?: (y)  Yes.
    * Prompt Style: (3)  Rainbow.
    * Character Set: (1)  Unicode.
    * Show current time?: (2)  24-hour format.
    * Prompt Separators: (1)  Angled.
    * Prompt Heads: (1)  Sharp.
    * Prompt Tails: (1)  Flat.
    * Prompt Height: (2)  Two lines.
    * Prompt Connection: (2)  Dotted.
    * Prompt Frame: (2)  Left.
    * Connection & Frame Color: (2)  Light.
    * Prompt Spacing: (2)  Sparse.
    * Icons: (2)  Many icons.
    * Prompt Flow: (1)  Concise.
    * Enable Transient Prompt?: (n)  No.
    * Instant Prompt Mode: (3)  Off.

### Customise

* Terminal IPython: Create file `~/.ipython/profile_default/ipython_config.py`
  * Valid figure formats: `png`, `retina`, `jpeg`, `svg`, `pdf`.
* IPython: Create file `~/.ipython/profile_default/ipython_config.py`
  * Valid figure formats: `png`, `retina`, `jpeg`, `svg`, `pdf`.
* JupyterLab: Settings > Advanced Settings Editor
* Zsh
  * Oh My Zsh: Edit `~/.zshrc`.
  * Powerlevel10k: Run `p10k configure` or edit `~/.p10k.zsh`.
    * Update command:
      `git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull`

## Python

The Python version is selected as follows:

* The latest [Python version numba is compatible with](https://numba.readthedocs.io/en/stable/user/installing.html#numba-support-info).

This Python version is installed at `/usr/local/bin`.
