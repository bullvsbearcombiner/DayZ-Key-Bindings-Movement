# DayZ Advanced Combat & Movement Automation

## Overview

This AutoHotkey v2 script provides an advanced automation system for **DayZ**, combining movement control, sprint management, combat stance automation, mouse aiming compensation, and smooth mouse movement.

The script is designed to improve input consistency and simplify repetitive keyboard actions while playing DayZ.

All hotkeys and automation routines are restricted to the DayZ game window to prevent unintended interactions with other applications.

## Features

### 1. Automatic Sprint System
- Maintains forward movement (`W`) while sprint automation is enabled.
- Automatically holds `Left Shift` to maintain sprinting.
- Uses a timer-based loop to continuously enforce movement inputs.
- Allows sprint automation to be paused without interrupting forward movement.
- Automatically stops when the reset or stop commands are triggered.

### 2. Combat Stance Automation
The script provides automated left and right combat leaning.

| Key | Action |
|---|---|
| `A` | Automatically activates left leaning (`Q`). |
| `D` | Automatically activates right leaning (`E`). |
| `Q` | Manually activates or toggles left leaning. |
| `E` | Manually activates or toggles right leaning. |
| `Shift` | Cancels fixed manual combat mode. |

The system automatically releases the opposite leaning key before activating a new direction, preventing conflicting inputs.

### 3. Mouse Aim Compensation

The script includes configurable mouse compensation when changing combat leaning direction.

It supports independent horizontal and vertical adjustments for both sides.

**Horizontal compensation:**
- Left leaning (`Q`): Moves the mouse to the right.
- Right leaning (`E`): Moves the mouse to the left.

**Vertical compensation:**
- Positive values move the mouse downward.
- Negative values move the mouse upward.

Mouse compensation is only triggered when the combat direction actually changes, preventing repeated corrections while maintaining the same stance.

### 4. Smooth Mouse Movement

Mouse movements are divided into multiple smaller steps to create smoother transitions.

The movement system uses:
- Configurable movement steps.
- Adjustable delay between steps.
- Accumulated floating-point calculations.
- Rounded mouse movement increments to preserve the requested total displacement.

This helps avoid sudden mouse movements caused by applying the entire correction at once.

### 5. Inventory Integration (TAB)

The script includes special handling for the DayZ inventory interface.

When `TAB` is pressed:
1. Releases Left Shift.
2. Saves the current combat leaning direction.
3. Releases both `Q` and `E` to prevent the character from remaining locked in a leaning position.

When `TAB` is released:
1. Waits briefly for interface synchronization.
2. Restores the previously active leaning direction.
3. Clears the temporary direction state.

The mouse compensation is not triggered again during restoration.

### 6. Automatic Combat Mode Timeout

The combat mode includes a five-minute inactivity timeout.

After 300,000 milliseconds:
- Combat mode is disabled.
- Manual fixed mode is reset.
- Both leaning keys are released.
- Internal combat direction variables are cleared.

### 7. Global Reset and Safety System

The script includes several mechanisms to prevent stuck keys.

The reset system releases:
- Left Shift
- Right Shift
- W
- Q
- E
- A
- D

It also clears internal states and stops active timers.

A global exit handler ensures that keys are released when the script is closed, reloaded, or terminated.

## Key Bindings

| Key | Function |
|---|---|
| `Numpad +` / `+` | Enables sprint automation. |
| `Numpad -` / `-` | Resets and disables all automation. |
| `S` | Stops sprint automation. |
| `W` | Prevents the original input from interfering with the sprint automation system. |
| `A` | Activates automatic left combat leaning. |
| `D` | Activates automatic right combat leaning. |
| `Q` | Activates or toggles manual left leaning. |
| `E` | Activates or toggles manual right leaning. |
| `Left Shift` / `Right Shift` | Cancels fixed manual combat mode. |
| `TAB` | Temporarily releases and restores the previous leaning direction. |
| `ESC` | Resets all automation states. |
| `Left Windows` / `Right Windows` | Resets all automation states. |
| `Pause` | Resets the script and toggles its paused state. |
| `Ctrl + Alt + S` | Resets the script and toggles suspension. |

## Configuration

The main configuration variables are located at the beginning of the script.

### Mouse Compensation

```autohotkey
global intensidadeCorrecaoEsquerda := 23
global intensidadeCorrecaoDireita  := 23

global intensidadeCorrecaoAlturaEsquerda := +7
global intensidadeCorrecaoAlturaDireita  := -7
```

| Variable | Description |
|---|---|
| `intensidadeCorrecaoEsquerda` | Horizontal compensation for left leaning. |
| `intensidadeCorrecaoDireita` | Horizontal compensation for right leaning. |
| `intensidadeCorrecaoAlturaEsquerda` | Vertical compensation for left leaning. |
| `intensidadeCorrecaoAlturaDireita` | Vertical compensation for right leaning. |

### Mouse Smoothing

```autohotkey
global passosSuavizacao := 5
global atrasoPassos := 5
```

| Variable | Description |
|---|---|
| `passosSuavizacao` | Number of micro-steps used for mouse movement. |
| `atrasoPassos` | Delay between each movement step, in milliseconds. |

Increasing the number of steps produces smaller movement increments and generally smoother transitions.

### Combat Timeout

```autohotkey
SetTimer(DesativarModoCombatePorInatividade, -300000)
```

The default timeout is five minutes (300,000 milliseconds).

## Internal Architecture

The script is organized into independent functions responsible for different automation tasks.

| Function | Responsibility |
|---|---|
| `MoverMouseSuave()` | Performs smooth mouse movement and aim compensation. |
| `SoltarTodasAsTeclas()` | Releases all controlled keys. |
| `AtivarModoCombate()` | Activates and manages combat leaning. |
| `DesativarModoCombatePorInatividade()` | Disables combat mode after inactivity. |
| `ManterCorridaForçada()` | Maintains continuous forward movement and sprint inputs. |
| `ResetarEstadoCompleto()` | Resets all automation variables and timers. |
| `PararCorrida()` | Stops sprint automation. |

## Technical Requirements

- **Operating System:** Windows
- **Automation Language:** AutoHotkey v2.0
- **Target Game:** DayZ
- **Game Executable:** `DayZ_x64.exe`

## Installation

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/).
2. Download or clone this repository.
3. Locate the `.ahk` script.
4. Double-click the script to execute it.
5. Launch DayZ and ensure the game window is active.

## Compatibility and Execution

The script uses `#HotIf WinActive("ahk_exe DayZ_x64.exe")` to restrict its hotkeys to DayZ.

Automation routines also verify that DayZ is active before maintaining sprint inputs.

## Important Notes

- This project is developed specifically for AutoHotkey v2.0.
- The mouse compensation values may require individual adjustment depending on in-game sensitivity and configuration.
- The script relies on simulated keyboard and mouse inputs.
- Some game environments or anti-cheat configurations may restrict automated inputs.
- Use responsibly and check the game's rules regarding automation.

## License

Specify your preferred license before distributing this project publicly.

---

**Project:** DayZ Advanced Combat & Movement Automation  
**Language:** AutoHotkey v2.0  
**Platform:** Windows  
**Purpose:** Movement automation, combat leaning control, and mouse aim compensation.
