FROM crashvb/supervisord:202201080446@sha256:8fe6a411bea68df4b4c6c611db63c22f32c4a455254fa322f381d72340ea7226
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:8fe6a411bea68df4b4c6c611db63c22f32c4a455254fa322f381d72340ea7226" \
	org.opencontainers.image.base.name="crashvb/supervisord:202201080446" \
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
	NUMBER_SCREEN="${number_screen}"

# Configure: novnc
RUN ln --symbolic /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html

# Configure: supervisor
ADD supervisord.fluxbox.conf /etc/supervisor/conf.d/30fluxbox.conf
ADD supervisord.x11vnc.conf /etc/supervisor/conf.d/40x11vnc.conf
ADD supervisord.xvfb.conf /etc/supervisor/conf.d/20xvfb.conf
ADD supervisord.websockify.conf /etc/supervisor/conf.d/50websockify.conf

# Configure: entrypoint
ADD entrypoint.fluxbox /etc/entrypoint.d/fluxbox
ADD entrypoint.websockify /etc/entrypoint.d/websockify
ADD entrypoint.x11 /etc/entrypoint.d/x11
ADD entrypoint.x11vnc /etc/entrypoint.d/x11vnc

# Configure: healthcheck
ADD healthcheck.fluxbox /etc/healthcheck.d/fluxbox
ADD healthcheck.x11vnc /etc/healthcheck.d/x11vnc
ADD healthcheck.xvfb /etc/healthcheck.d/xvfb
ADD healthcheck.websockify /etc/healthcheck.d/websockify

EXPOSE 5800/tcp 5900/tcp
