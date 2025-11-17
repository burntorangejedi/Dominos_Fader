# Changelog

All notable changes to Dominos_Fader will be documented in this file.

## [1.0.7] - 2025-11-16

### Added
- Slash commands `/dominosfader` or `/df` to manually refresh settings
- `Refresh()` method for all bar modules to reload settings without UI restart
- Full support for all MAS status events (Combat, Target, Focus, Mount, Moving, NPC, Dragonriding, Casting, Edit Mode, Grid)

### Changed
- Status events now dynamically reload from database on module enable
- Combat trigger now enabled by default for all bars
- Module naming uses underscore prefix (Dominos_ActionBar1 instead of DominosActionBar1)

### Fixed
- Status events not updating when changing tweak settings in MAS
- Print error on addon initialization

## [1.0.0] - 2025-11-16

### Added
- Initial release
- MouseOverActionSettings integration for Dominos bars
- Support for Action Bars (1-10)
- Support for Pet Bar
- Support for Stance/Class Bar
- Support for Bag Bar
- Support for Menu Bar (Micro Menu)
- Support for Extra Ability Bar
- Automatic bar detection and registration
- Full MAS feature support (alpha levels, animation speeds, delays, event triggers)
