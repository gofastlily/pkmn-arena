# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## Unreleased
### Added
- Battle Now mode
- Enemy PP are now tracked
- Roster selection screen before battle
- Option to disable nicknaming by default

### Fixed
- Debug mode assigns a team to the player at the start Battle Now

### Known Issues
- Wrong sprites for player's Pokémon
- Wrong palette for sprite on battle end screen
- Trainer sprites are corrupt after viewing status screen during roster selection
- Post-battle health bars use the incorrect palette
- Post-battle enemy trainer sprite uses the incorrect palette
- Post-battle only six sprites of twelve are visible
- Post-battle the incorrect 'party' sprites are used


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
