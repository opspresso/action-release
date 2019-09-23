FROM opspresso/builder:v0.6.4

LABEL "com.github.actions.name"="Release to GitHub"
LABEL "com.github.actions.description"="GitHub Release"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="blue"

LABEL version=v0.1.1
LABEL repository="https://github.com/opspresso/action-release"
LABEL maintainer="Jungyoul Yu <me@nalbam.com>"
LABEL homepage="https://opspresso.com/"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
