# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0.0] - 2021-04-11

Creation.

### Added
### Changed
### Fixed

## [1.1.0.0] - 2021-05-13

### Added
* Warning dialog for tour names during export.
* After export, the Komoot photo annotation page will be opened.
### Changed
In case the export subfolder is determined by tour names, the logic has changed when not all photos 
have the same tour name:
* If no tour names are set at all, the subfolder "LR2Komoot" will be taken.
* If at least one tour name is set, empty tour names are ignored.
* If different tour names are found, the export subfolder is set to "LR2Komoot"

The display name for two metadata fields were renamed:
* Komoot URL was renamed to Tour URL
* Komoot Tour was renamed to Tour Name

### Fixed

## [1.1.1.0] - 2021-09-18

### Added
* Supports Tour URL which points to previewMap.
### Changed
### Fixed

