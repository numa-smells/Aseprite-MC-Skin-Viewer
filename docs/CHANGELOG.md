# Changelog


## [v1.0] - 2025-09-27

_First release._

## [v1.0.0]  - 2025-09-27
### Changed
- Adhere tags to Semantic Versioning.
### Added
- Add Github Actions to automate releases. 

## [v1.0.0a] - 2025-09-27

### Removed
- Removed plugin counter left from the tutorial script template.

## [v1.0.0b]  - 2025-09-27
_No changes._

## [v1.0.0c]  - 2025-09-27
### Fixes
- Github Actions export correctly.

## [v1.0.1]  - 2025-09-27
### Added
- Created option to change lighting direction.
- Add `README.md` file and documentation images.

## [v1.0.2]  - 2025-09-27
### Fixes
- Documentation files are removed from builds

## [v1.0.3]  - 2025-09-27
### Fixes
- Documentation files are removed from builds

## [v1.0.4]  - 2025-09-27
### Changed
- Replaced images to show model with top lighting.
### Fixes
- Links are now platform independent ("/" or "\" depending on the OS).

## [v1.0.5]  - 2025-09-28
### Changed
- Extenion build will now include the version in the filename.
- Github Actions will now also publish to itch.io automatically.
### Fixes
- Top facing lighting fixed for double-sided cubes.

## [v1.0.6] - 2025-09-28

### Changed
- Itch build will now correctly show the version.

## [v1.1.0] - 2025-10-02
### Changed
- Faces will be drawn anti-alliased if at 100% opacity.
- Mouse cursor will now change when dragging or rotating the model.
- Default lighting is now top facing.
- `pose_reset()` will now also reset cube visibility.
- Viewer now displays with a border similar to Aseprite's default preview window. 

### Added
- [Created changelog](https://common-changelog.org).
- New "First Person Pose".
- Button to toggle tool visibility.
- Check to dissalow duplicate dialogs on the same sprite.

### Removed
- Removed Herobrine

### Fix
- Check API Version to ensure compatability. ([#1](https://github.com/numa-smells/Aseprite-MC-Skin-Viewer/issues/1))
- Maybe fixed? Double checked file location calls. ([#2](https://github.com/numa-smells/Aseprite-MC-Skin-Viewer/issues/2))

### Known Issues
- Pasting while mirror draw is on is broken.
- Model continues to rotate after resizing dialog.