# PARDON ME — Internal playtest

## Required editor

Use **Godot 4.7 stable (standard edition)** to match the development build. The verified local version is `4.7.stable.official.5b4e0cb0f`. .NET is not required for this GDScript project.

[Download Godot 4.7 for your operating system](https://godotengine.org/download/archive/4.7-stable/).

“Godot 4.x” alone is not a sufficient compatibility guarantee. This project uses typed dictionaries, introduced in Godot 4.4, and is tested with 4.7. Older releases are not supported by this playtest setup.

## Open the GitHub copy

1. Clone the repository or download and fully extract its ZIP.
2. Launch the Godot 4.7 executable explicitly, rather than relying on a file association that may open an older editor.
3. Import the `project.godot` in this folder into the Project Manager.
4. Let Godot finish importing assets, then press **F5**.

The default scene is `scenes/district.tscn`. The original movement toy remains at `scenes/game.tscn`.

The `.godot` directory is generated locally and is intentionally ignored by Git. All runtime source folders (`scripts`, `scenes`, `data`, `Art`, and `Music/Imported`) must be present. The local `.tools` audio conversion utility is not needed to play. This repository is a source project, not a standalone exported game.

## Known launch error: “Only arrays can specify collection element types”

If the editor highlights `Dictionary[StringName, AudioStreamWAV]` in `scripts/systems/feedback.gd`, it is rejecting typed-dictionary syntax. That syntax requires Godot 4.4 or newer; launch with the specified 4.7 build. The project also uses it in `scripts/district/navigation.gd`, so editing only the highlighted line is not the recommended fix.

[Godot 4.4 release notes: typed dictionaries](https://godotengine.org/releases/4.4/).

If an error remains in Godot 4.7, report the exact editor version and the first error in the Output/Debugger panel. The supplied photo identifies the syntax incompatibility but does not establish the tester's exact version or rule out additional issues.

## Controls and playtest notes

See [the complete district playtest guide](docs/GOAL_B_PLAYTEST.md) for controls, limitations, verification evidence and suggested scenarios. Start with E to pick up a weapon or answer a nearby payphone; M enlarges the map, R restarts, and Esc pauses.
