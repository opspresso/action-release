# GitHub Release

[![GitHub Actions status](https://github.com/opspresso/action-release/workflows/Build-Push/badge.svg)](https://github.com/opspresso/action-release/actions)
[![GitHub Releases](https://img.shields.io/github/release/opspresso/action-release.svg)](https://github.com/opspresso/action-release/releases)

## Usage

```yaml
name: GitHub Release

on: push

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v1
        with:
          fetch-depth: 1

      - name: Release to GitHub
        uses: opspresso/action-release@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          TAG_NAME: "v0.0.1"
```

## env

Name | Description | Default | Required
---- | ----------- | ------- | --------
GITHUB_TOKEN | Your GitHub Token. | | **Yes**
TAG_NAME | The name of the tag. | $(cat ./target/TAG_NAME) | No
TARGET_COMMITISH | Specifies the commitish value that determines where the Git tag is created from. | master | No
NAME | The name of the release. | | No
BODY | Text describing the contents of the tag. | | No
DRAFT | `true` to create a draft (unpublished) release, `false` to create a published one. | false | No
PRERELEASE | `true` to identify the release as a prerelease. `false` to identify the release as a full release. | false | No
ASSET_PATH | The path where the release asset files. | | No
