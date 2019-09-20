FROM python:3.7-alpine

LABEL "com.github.actions.name"="GitHub Release"
LABEL "com.github.actions.description"="Release to GitHub"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="blue"

LABEL version=v0.0.1
LABEL repository="https://github.com/opspresso/action-release"
LABEL maintainer="Jungyoul Yu <me@nalbam.com>"
LABEL homepage="https://opspresso.com/"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
