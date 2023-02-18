FROM crashvb/supervisord:202302172130@sha256:c3ca0e25621af7c6bc594a0469d1ed763b4868f8fc5ceabaac384bd4c2496834
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:c3ca0e25621af7c6bc594a0469d1ed763b4868f8fc5ceabaac384bd4c2496834" \
	org.opencontainers.image.base.name="crashvb/supervisord:202302172130" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing fluxbox, novnc, x11vnc, and xvfb." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/x11-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/x11" \
	org.opencontainers.image.url="https://github.com/crashvb/x11-docker"

# Install packages, download files ...
RUN docker-apt fluxbox net-tools novnc ssl-cert x11vnc xvfb

# Configure: (display)
ARG display_height=1024
ARG display_width=1280
ARG number_display=27
ARG number_screen=0
ENV \
	DISPLAY=":${number_display}.${number_screen}" \
	DISPLAY_GEOMETRY="${display_width}x${display_height}" \
	NUMBER_DISPLAY="${number_display}" \
	NUMBER_SCREEN="${number_screen}" \
	X11_GNAME=root \
	X11_UNAME=root

# Configure: novnc
RUN ln --symbolic /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Configure: supervisor
COPY run-as-x11-user /usr/local/bin/
COPY supervisord.fluxbox.conf /etc/supervisor/conf.d/30fluxbox.conf
COPY supervisord.x11vnc.conf /etc/supervisor/conf.d/40x11vnc.conf
COPY supervisord.xvfb.conf /etc/supervisor/conf.d/20xvfb.conf
COPY supervisord.websockify.conf /etc/supervisor/conf.d/50websockify.conf

# Configure: entrypoint
COPY entrypoint.fluxbox /etc/entrypoint.d/fluxbox
COPY entrypoint.websockify /etc/entrypoint.d/websockify
COPY entrypoint.x11 /etc/entrypoint.d/x11
COPY entrypoint.x11vnc /etc/entrypoint.d/x11vnc

# Configure: healthcheck
COPY healthcheck.fluxbox /etc/healthcheck.d/fluxbox
COPY healthcheck.x11vnc /etc/healthcheck.d/x11vnc
COPY healthcheck.xvfb /etc/healthcheck.d/xvfb
COPY healthcheck.websockify /etc/healthcheck.d/websockify

EXPOSE 5800/tcp 5900/tcp
