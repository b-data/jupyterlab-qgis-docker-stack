# CUDA Version Matrix

## Latest

Topmost entry = Tag `latest`

| QGIS    | SAGA  | CUDA   | cuBLAS    | cuDNN    | NCCL   | Linux distro |
|:--------|:------|:-------|:----------|:---------|:-------|:-------------|
| 3.36.3  | 7.3.0 | 12.5.0 | 12.5.2.13 | n/a      | 2.21.5 | Ubuntu 22.04 |
| 3.36.2  | 7.3.0 | 12.4.1 | 12.4.5.8  | n/a      | 2.21.5 | Ubuntu 22.04 |
| 3.36.1  | 7.3.0 | 11.8.0 | 11.11.3.6 | n/a      | 2.15.5 | Ubuntu 22.04 |
| 3.36.0  | 7.3.0 | 11.8.0 | 11.11.3.6 | 8.9.6.50 | 2.15.5 | Ubuntu 22.04 |
| 3.34.3  | 7.3.0 | 11.8.0 | 11.11.3.6 | 8.9.6.50 | 2.15.5 | Ubuntu 22.04 |
| 3.34.2  | 7.3.0 | 11.8.0 | 11.11.3.6 | 8.9.6.50 | 2.15.5 | Ubuntu 22.04 |
| 3.34.1  | 7.3.0 | 11.8.0 | 11.11.3.6 | 8.9.6.50 | 2.15.5 | Ubuntu 22.04 |
| 3.34.0  | 7.3.0 | 11.8.0 | 11.11.3.6 | 8.9.6.50 | 2.15.5 | Ubuntu 22.04 |

## LTR

Topmost entry = Tag `ltr`

| QGIS    | SAGA  | CUDA   | cuBLAS    | cuDNN    | NCCL   | Linux distro |
|:--------|:------|:-------|:----------|:---------|:-------|:-------------|
| 3.34.7  | 7.3.0 | 11.8.0 | 11.11.3.6 | n/a      | 2.15.5 | Ubuntu 22.04 |
| 3.34.6  | 7.3.0 | 11.8.0 | 11.11.3.6 | n/a      | 2.15.5 | Ubuntu 22.04 |
| 3.34.5  | 7.3.0 | 11.8.0 | 11.11.3.6 | n/a      | 2.15.5 | Ubuntu 22.04 |
| 3.34.4  | 7.3.0 | 11.8.0 | 11.11.3.6 | 8.9.6.50 | 2.15.5 | Ubuntu 22.04 |

## Recommended NVIDIA driver

| CUDA   | NVIDIA Linux driver | NVIDIA Windows driver[^1] |
|:-------|:--------------------|:--------------------------|
| 12.5.0 | ≥ 555.42.02         | ≥ 555.85                  |
| 12.4.1 | ≥ 550.54.15         | ≥ 551.78                  |
| 11.8.0 | ≥ 520.61.05         | ≥ 520.06                  |

[^1]: [GPU support in Docker Desktop | Docker Docs](https://docs.docker.com/desktop/gpu/),
[Nvidia GPU Support for Windows · Issue #19005 · containers/podman](https://github.com/containers/podman/issues/19005)
