# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## Unreleased
### Added
- Battle Now mode

### Changed
- Re-enabled animations

### Fixed
- Debug mode assigns a team to the player at the start Battle Now

### Known Issues
- Wrong sprites for player's Pokémon
- Wrong palette for sprite on battle end screen
- Game crashes after battle end screen
- Sometimes wrong moves are loaded for opposing Pokémon
- For some reason I'm showing the opponent's selected roster before the battle?


## [0.0.1](https://gitlab.lily.rip/lily/pkmn-arena/-/compare/0.0.0...0.0.1) - 2022-10-17
### Changed
- Refactored the main menu to a generic script
- Options
  - Text speed: Fast
  - Animation: Off
  - Battle Style: Set

### Known Issues
- Debug mode does not assign a team to the player at the start of the game


## [0.0.0](https://gitlab.lily.rip/lily/pkmn-arena/-/commits/0.0.0) - 2022-10-17
### Added
- Docker-based build helper
- Gitlab CI

### Changed
- Renamed output from `pokeyellow` to `pkmnarena`
