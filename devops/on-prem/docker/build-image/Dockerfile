ARG ALPINE_VERSION=3.21.3
FROM alpine:${ALPINE_VERSION}

ARG OPEN_TOFU_VERSION
ARG TERRAGRUNT_VERSION

COPY ./scripts /tmp
RUN chmod +x /tmp/*.sh

RUN /tmp/01-install-1password-cli.sh
RUN /tmp/02-install-open-tofu.sh ${OPEN_TOFU_VERSION}
RUN /tmp/03-install-terragrunt.sh ${TERRAGRUNT_VERSION}
RUN /tmp/04-generate-formate-private-key.sh

RUN rm -f /tmp/*.sh