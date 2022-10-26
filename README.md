# x11-docker

[![version)](https://img.shields.io/docker/v/crashvb/x11/latest)](https://hub.docker.com/repository/docker/crashvb/x11)
[![image size](https://img.shields.io/docker/image-size/crashvb/x11/latest)](https://hub.docker.com/repository/docker/crashvb/x11)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/x11-docker.svg)](https://github.com/crashvb/x11-docker/blob/master/LICENSE.md)

## Overview

This docker image contains:

* [fluxbox](http://fluxbox.org/) (optional)
* [novnc](https://novnc.com/) (optinal)
* [x11vnc](https://github.com/LibVNC/x11vnc)
* [xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)

It is intended to be base image for derivations, or to be used directly.

## Overriding embedded defaults

The image can be rebuilt using the following arguments:

 | Argument | Default Value | Description |
 | -------- | ------------- | ----------- |
 | display\_height | 1024 | The height of the X server display.
 | display\_width | 1280 | The width of the X server display.
 | number\_display | 27 | The display number used by the X server.
 | number\_screen | 0 | The screen number used by the X server.

The following environment variables can be defined for containers:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | DISPLAY | _&lt;number\_display&gt;_._&lt;number\_screen&gt;_ | The X11 display to which client applications will connect.
 | DISPLAY\_GEOMETRY | _&lt;display\_width&gt;_x_&lt;display\_height&gt;_ | The geometry of the X server.
 | NUMBER\_DISPLAY | _&lt;number\_display&gt;_ | The display number used by the X server.
 | NUMBER\_SCREEN | _&lt;number\_screen&gt;_ | The screen number used by the X server.
 | X11\_GNAME | root | The group under which the X server is running.
 | X11\_UNAME | root | The user under which the X server is running.

## Forwarding a window(s) to the embedded X server

These steps assume that we are forwarding `xclock` from the docker host to the embedded X server, in a container named `x11-SNAPSHOT`, using display `25.0` externally, and display `27.0` inside of the container.

1. Determine the port number to expose and port number as which to publish it. X11 ports start at `6000` (e.g. DISPLAY=27.0 --> port 6027), so for this example we would run the container with the `--publish=6025:6027/tcp` argument.
2. Retrieve the magic cookie from the container:
```bash
$ magic_cookie=$(docker exec -it x11-SNAPSHOT bash -c "xauth list | grep \$(hostname)" | awk '{print $3}')
```
3. On the host forwarding the window, assign the display and magic cookie:
```bash
$ export DISPLAY=localhost:25.0
$ xauth add ${DISPLAY} . ${magic_cookie}
```
4. Launch the desired application.
5. When finished, remove the magic cookie:
```bash
xauth remove ${DISPLAY}
```
6. `xauth list` can be used to verify magic cookies at any point.

## Entrypoint Scripts

### fluxbox

The embedded entrypoint script is located at `/etc/entrypoint.d/fluxbox` and performs the following actions:

1. The configuration is modified from the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | ENABLE\_FLUXBOX | _undefined_ | If undefined, fluxbox will not be instantiated.

### websockify

The embedded entrypoint script is located at `/etc/entrypoint.d/websockify` and performs the following actions:

1. The configuration is modified from the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | ENABLE\_NOVNC | _undefined_ | If undefined, noVNC / websockify will not be instantiated.

### x11

The embedded entrypoint script is located at `/etc/entrypoint.d/x11` and performs the following actions:

1. The .Xauthority file is generated from the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | NUMBER\_DISPLAY | 27 | The display number used by the X server.

### x11vnc

The embedded entrypoint script is located at `/etc/entrypoint.d/x11vnc` and performs the following actions:

1. The PKI certificates are generated or imported.
2. A new x11vnc configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | X11VNC\_CERT\_DAYS | 30 | Validity period of any generated PKI certificates. |
 | X11VNC\_KEY\_SIZE | 4096 | Key size of any generated PKI keys. |

## Healthcheck Scripts

### fluxbox

The embedded healthcheck script is located at `/etc/healthcheck.d/fluxbox` and performs the following actions:

1. Verifies that the fluxbox window manager is operational, if enabled.

### websockify

The embedded healthcheck script is located at `/etc/healthcheck.d/websockify` and performs the following actions:

1. Verifies that the websockify server is operational, if enabled.

### x11vnc

The embedded healthcheck script is located at `/etc/healthcheck.d/x11vnc` and performs the following actions:

1. Verifies that the x11vnc server is operational.

### xvfb

The embedded healthcheck script is located at `/etc/healthcheck.d/xvfb` and performs the following actions:

1. Verifies that the X11 virtual frame buffer server is operational.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ entrypoint.d/
│  │  ├─ x11
│  │  └─ x11vnc
│  ├─ healthcheck.d/
│  │  ├─ fluxbox
│  │  ├─ websockify
│  │  ├─ x11vnc
│  │  └─ xvfb
│  └─ supervisor/
│     └─ config.d/
│        ├─ 20xvfb.conf
│        ├─ 30fluxbox.conf
│        ├─ 40x11vnc.conf
│        └─ 50websockify.conf
├─ _~<X11_UNAME>_/
│  └─ .Xauthority
├─ run/
│  └─ secrets/
│     ├─ x11vnc.crt
│     ├─ x11vnc.key
│     └─ x11vncca.crt
├─ tmp/
│  └─ .X11-unix/
└─ usr/
   └─ share/
      └─ novnc/
```

### Exposed Ports

* `5800/tcp` - noVNC listening port.
* `5900/tcp` - VNC listening port.

### Volumes

None.

## Development

[Source Control](https://github.com/crashvb/x11-docker)

