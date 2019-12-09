#!/bin/bash

_error() {
  echo -e "$1"

  if [ "${LOOSE_ERROR}" == "true" ]; then
    exit 0
  else
    exit 1
  fi
}

_release_pre() {
  if [ -z "${GITHUB_TOKEN}" ]; then
    _error "GITHUB_TOKEN is not set."
  fi

  if [ -z "${TAG_NAME}" ]; then
    if [ -f ./target/TAG_NAME ]; then
      TAG_NAME=$(cat ./target/TAG_NAME | xargs)
    elif [ -f ./target/VERSION ]; then
      TAG_NAME=$(cat ./target/VERSION | xargs)
    elif [ -f ./VERSION ]; then
      TAG_NAME=$(cat ./VERSION | xargs)
    fi
    if [ -z "${TAG_NAME}" ]; then
      _error "TAG_NAME is not set."
    fi
  fi

  if [ ! -z "${TAG_POST}" ]; then
    TAG_NAME="${TAG_NAME}-${TAG_POST}"
  fi

  if [ -z "${TARGET_COMMITISH}" ]; then
    TARGET_COMMITISH="master"
  fi

  if [ "${DRAFT}" != "true" ]; then
    DRAFT="false"
  fi

  if [ "${PRERELEASE}" != "true" ]; then
    PRERELEASE="false"
  fi
}

_release_id() {
  URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"
  RELEASE_ID=$(curl -s ${URL} | TAG_NAME=${TAG_NAME} jq -r '.[] | select(.tag_name == env.TAG_NAME) | .id' | xargs)
  echo "RELEASE_ID: ${RELEASE_ID}"
}

_release_assets() {
  LIST=/tmp/release-list
  ls ${ASSET_PATH} | sort > ${LIST}

  while read FILENAME; do
    FILEPATH=${ASSET_PATH}/${FILENAME}
    FILETYPE=$(file -b --mime-type "${FILEPATH}")
    FILESIZE=$(stat -c%s "${FILEPATH}")

    CONTENT_TYPE_HEADER="Content-Type: ${FILETYPE}"
    CONTENT_LENGTH_HEADER="Content-Length: ${FILESIZE}"

    echo "github releases assets ${RELEASE_ID} ${FILENAME} ${FILETYPE} ${FILESIZE}"
    URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
    curl \
      -sSL \
      -X POST \
      -H "${AUTH_HEADER}" \
      -H "${CONTENT_TYPE_HEADER}" \
      -H "${CONTENT_LENGTH_HEADER}" \
      --data-binary @${FILEPATH} \
      ${URL}
  done < ${LIST}
}

_release() {
  _release_pre

  AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

  _release_id
  if [ ! -z "${RELEASE_ID}" ]; then
    echo "github releases delete ${RELEASE_ID}"
    URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}"
    curl \
      -sSL \
      -X DELETE \
      -H "${AUTH_HEADER}" \
      ${URL}
    sleep 1
  fi

  echo "github releases create ${TAG_NAME} ${DRAFT} ${PRERELEASE}"
  URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"
  curl \
    -sSL \
    -X POST \
    -H "${AUTH_HEADER}" \
    --data @- \
    ${URL} <<END
{
 "tag_name": "${TAG_NAME}",
 "target_commitish": "${TARGET_COMMITISH}",
 "name": "${NAME}",
 "body": "${BODY}",
 "draft": ${DRAFT},
 "prerelease": ${PRERELEASE}
}
END
  sleep 1

  _release_id
  if [ -z "${RELEASE_ID}" ]; then
    _error "RELEASE_ID is not set."
  fi

  if [ ! -z "${ASSET_PATH}" ] && [ -d "${ASSET_PATH}" ]; then
    _release_assets
  fi
}

_release
