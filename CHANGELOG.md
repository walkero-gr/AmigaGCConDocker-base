# Changelog
All notable changes to this project will be documented in this file.

## 1.2.0 - [2024-11-25]
### Changed
- Now the build is using Ubuntu 24.04 LTS
- texinfo 7.0 is compiled and installed manually, because of incompatibilites with latest version

## 1.1.1 - [2024-07-27]
### Added
- No changes with this release, but new base images for gcc 6 and 8 are created.

## 1.1.0 - [2024-07-10]
### Added
- Added the manifest for the latest image on the pipeline

### Changed
- Now gcc 11 is used to compile the cross-compiler

### Fixed
- Fixed the "GLIBC_2.38 not found" error

## 1.0.0 - [2024-06-04]
### Changed
- Splitted the base images repository from the [AmigaGCCOnDocker](https://github.com/walkero-gr/AmigaGCConDocker)
- Added version on every release



The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).