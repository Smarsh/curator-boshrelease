FROM python:alpine

RUN apk add git curl jq bash gcc musl-dev

ENV BOSH_VERSION=6.4.1
RUN curl -sL https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 | \
    install /dev/stdin /usr/local/bin/bosh

RUN pip install yq

COPY semver.py /semver.py

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
