# DayZ Movement Key Bindings

## Description

An AutoHotkey v2 script that automates movement, sprinting, and leaning commands in DayZ.

## Requirements

- Windows.
- AutoHotkey v2.
- DayZ must be running and in focus.

## Features

- **Auto-sprint:** Keeps your character sprinting when the macro is activated.
- **Shift control:** Allows you to toggle or pause the Shift key while sprinting.
- **Leaning (Q and E):** Control leaning manually or via horizontal mouse movement.
- **Combat mode:** Activates leaning by double-pressing 'A' or 'D' (within 400ms) while holding the right mouse button.
- **Automatic deactivation:** Combat mode ends after 5 seconds of inactivity.
- **Quick stop:** Stops sprinting and releases all keys controlled by the macro.

## Controls

| Key | Function |
| --- | --- |
| `Numpad +` or `+` | Activates auto-sprint |
| `Numpad -`, `-`, or `Tab` | Deactivates the macro and stops sprinting |
| `S` | Quick stop |
| `W` | Normal forward movement |
| `Q` | Lean left |
| `E` | Lean right |
| Double-press `A` + Right-click | Activates combat mode (lean left) |
| Double-press `D` + Right-click | Activates combat mode (lean right) |

## How to Run

1. Install AutoHotkey v2.
2. Save the script as `DayZ key bindings movement.ahk`.
3. Run the `.ahk` file.
4. Open DayZ and ensure the game window is in focus.
5. Use the keys described in the table above. ## Notes

- The macro starts in a disabled state.
- The automated shortcuts only function when DayZ is the active window (in focus).
- Mouse monitoring controls leaning based on the horizontal position of the cursor.
- Behavior may vary depending on your key binding settings and the version of the game.

## Main file

`DayZ key bindings movement..ahk`

Note: The script uses `#HotIf WinActive("ahk_exe DayZ_x64.exe")` to restrict the shortcuts to the game; however, the mouse-monitoring timer may continue to run even when the game is not in focus.
