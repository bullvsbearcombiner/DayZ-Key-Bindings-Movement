# DayZ AutoHotkey Macro — Technical Documentation

**Version:** AutoHotkey v1.7  
**Target Application:** DayZ (`DayZ_x64.exe`)  
**Purpose:** Automated sprint control, Shift management, combat direction control, manual Q/E toggling, and automatic key-state cleanup.

## 1. Overview

This script provides a set of keyboard automation features designed specifically for DayZ. It manages sprinting, directional combat inputs, manual directional locking, and macro activation or deactivation.

The script includes the following features:

- Forced sprinting using the `W` and `Left Shift` keys.
- Independent control of the sprint macro and Shift input.
- Automatic combat direction selection using `A` and `D`.
- Manual combat direction selection using `Q` and `E`.
- Manual directional locking that prevents `A` and `D` from overriding the selected direction.
- Automatic release of simulated keys when resetting, suspending, or exiting the script.
- Automatic combat mode timeout after five minutes.
- Hotkey restrictions that limit script execution to the active DayZ window.

## 2. System Requirements

- Windows operating system.
- AutoHotkey v2.0 or later compatible with the v2 syntax.
- DayZ installed and running.
- The DayZ process must be named `DayZ_x64.exe`.

The script uses AutoHotkey functions such as `SendInput`, `SendEvent`, `SetTimer`, `WinActive`, and `OnExit`.

## 3. Global Variables

| Variable | Description |
|---|---|
| `teclaAtiva` | Tracks the currently active key managed by the script. |
| `correndo` | Indicates whether forced sprinting is active. |
| `shiftPausado` | Determines whether the macro should temporarily release Left Shift while sprinting. |
| `macroDesativado` | Determines whether the sprint macro is disabled. The initial value is `true`. |
| `modoCombate` | Indicates whether combat direction mode is active. |
| `direcaoCombate` | Stores the selected combat direction: `q`, `e`, `centro`, or an empty string. |
| `modoManualFixo` | Indicates whether manual combat direction locking is enabled. |

### Initial State

When the script starts, the sprint macro is disabled. The script does not automatically activate sprinting or force the Shift key to remain pressed.

The combat mode is also initialized as inactive.

## 4. DayZ Window Restriction

The `#HotIf WinActive("ahk_exe DayZ_x64.exe")` directive restricts the hotkeys defined within its scope to situations where the DayZ window is active.

This prevents the script's scoped keyboard shortcuts from being triggered while another application is in focus.

The sprint timer also checks whether DayZ is active before continuing its repeated input operations.

## 5. Sprint Control System

### 5.1 Activate Forced Sprint

**Hotkey:** `Numpad Add` or `+`

Activates the sprint macro by setting the following variables:

- `macroDesativado := false`
- `correndo := true`
- `shiftPausado := false`

The script then starts the `ManterCorridaForçada` timer with a 50-millisecond interval.

### 5.2 Forced Sprint Function

The `ManterCorridaForçada()` function repeatedly checks whether the macro is enabled and whether DayZ is active.

While sprinting is enabled, it performs the following actions:

1. Holds the `W` key.
2. Holds `Left Shift` when Shift is not paused.
3. Releases `Left Shift` when Shift is paused.

If the macro is disabled or DayZ is no longer the active window, the function stops its timer.

**Important:** The timer interval is 50 milliseconds. This is the requested repetition interval, not a guarantee of exact execution timing.

### 5.3 Stop Sprinting

**Hotkey:** `S`

Calls `PararCorrida()` to:

- Disable forced sprinting.
- Reset the Shift pause state.
- Disable the sprint macro.
- Stop the sprint timer.
- Release `Left Shift` and `W`.

This stops the forced sprint behavior without resetting every combat-related variable.

## 6. Combat Direction System

The script supports two combat control methods: automatic direction selection and manual direction locking.

### 6.1 Automatic Combat Direction

| Hotkey | Action |
|---|---|
| `A` | Activates the Q direction. |
| `D` | Activates the E direction. |

When manual direction locking is disabled, pressing `A` calls `AtivarModoCombate("q", false)`, while pressing `D` calls `AtivarModoCombate("e", false)`.

The function releases the previously tracked active key, releases the opposite direction key, and presses the selected direction.

This prevents the script from intentionally holding both Q and E simultaneously.

### 6.2 Manual Direction Locking

**Hotkeys:** `Q` and `E`

Pressing Q or E when manual locking is inactive activates manual combat mode and locks the selected direction.

While manual locking is active, the automatic A/D controls do not change the selected direction.

#### Q key behavior

| Current Direction | Action |
|---|---|
| Q | Releases Q and switches to center. |
| E | Releases E and activates Q. |
| Center | Activates Q. |
| Manual mode inactive | Activates manual Q mode. |

#### E key behavior

| Current Direction | Action |
|---|---|
| E | Releases E and switches to center. |
| Q | Releases Q and activates E. |
| Center | Activates E. |
| Manual mode inactive | Activates manual E mode. |

The center state releases both Q and E while keeping manual direction locking enabled.

The manual Q/E controls use the virtual-key codes `vk51` and `vk45`, respectively.

### 6.3 Combat Activation Function

The `AtivarModoCombate(lado := "", manual := false)` function manages combat direction activation.

Its parameters are:

- `lado`: The requested direction (`q`, `e`, or `centro`).
- `manual`: Determines whether manual direction locking should be enabled.

When manual mode is requested, `modoManualFixo` becomes `true`.

The function also schedules a five-minute inactivity timeout.

### 6.4 Combat Timeout

The `DesativarModoCombatePorInatividade()` function clears the combat mode, removes manual locking, resets the stored direction, and releases Q and E.

The timeout is scheduled using:

`SetTimer(DesativarModoCombatePorInatividade, -300000)`

The negative timer interval requests a one-time execution after approximately 300,000 milliseconds, or five minutes.

**Note:** The timeout is scheduled when combat mode is activated or when manual direction is changed. The script does not explicitly cancel and restart an existing timeout each time it schedules a new one. Therefore, the five-minute timeout should not be interpreted as a guaranteed five minutes from the most recent manual input.

## 7. Shift Key Behavior

**Hotkeys:** `Left Shift` and `Right Shift`

Pressing either Shift key checks whether manual combat direction locking is active.

If manual locking is active, the script calls `DesativarModoCombatePorInatividade()` and clears `teclaAtiva`.

This returns directional control to the automatic A/D system.

If manual locking is inactive, the Shift hotkey does not change the combat mode.

During forced sprinting, the timer manages the simulated Left Shift state according to the `shiftPausado` variable.

## 8. Reset and Emergency Key Release

### 8.1 Complete Reset

The `ResetarEstadoCompleto()` function restores the macro to its initial disabled state.

It performs the following operations:

- Stops forced sprinting.
- Clears the Shift pause state.
- Disables the sprint macro.
- Disables combat mode and manual locking.
- Clears the stored combat direction.
- Clears the tracked active key.
- Stops both the sprint and combat timeout timers.
- Releases Left Shift, Right Shift, W, Q, E, A, and D.

This function is used by the reset hotkeys and suspension controls.

### 8.2 Stop Sprint Function

`PararCorrida()` stops only the sprint system and releases W and Left Shift. It does not perform the complete combat reset.

### 8.3 Exit Cleanup

The `OnExit(SoltarTodasAsTeclas)` callback ensures that the script attempts to release its simulated keys when it exits.

The `SoltarTodasAsTeclas()` function clears the tracked active key, sends key-up events for the relevant keys, and waits briefly before the script finishes.

This helps reduce the risk of simulated keys remaining pressed after script termination.

## 9. Keyboard Shortcut Reference

| Shortcut | Function |
|---|---|
| `Numpad Add` or `+` | Activates forced sprinting. |
| `S` | Stops forced sprinting. |
| `A` | Selects Q direction when manual locking is inactive. |
| `D` | Selects E direction when manual locking is inactive. |
| `Q` | Activates or toggles manual Q direction. |
| `E` | Activates or toggles manual E direction. |
| `Left Shift` | Cancels manual direction locking when active. |
| `Right Shift` | Cancels manual direction locking when active. |
| `Tab` | Performs a complete macro reset. |
| `Numpad Sub` or `-` | Performs a complete macro reset. |
| `Pause` | Releases keys, resets the macro, and toggles AutoHotkey's pause state. |
| `Ctrl + Alt + S` | Releases keys, resets the macro, and toggles script suspension. |

The `W` hotkey contains an empty handler, allowing the original key to pass through without adding a separate macro action.

## 10. Pause and Suspension

### Pause key

Pressing `Pause` releases the relevant keys, resets the macro, and executes `Pause(-1)` to toggle the script's paused state.

### Ctrl + Alt + S

This combination releases the relevant keys, resets the macro, and executes `Suspend(-1)` to toggle hotkey suspension.

These are separate AutoHotkey mechanisms: pausing and suspending are not the same operation.

Depending on the resulting AutoHotkey state, the script may require the corresponding control to be toggled again before its hotkeys resume normal operation.

## 11. Implementation Notes and Limitations

1. **State tracking:** `teclaAtiva` is used to track an active Q/E key, but the current script does not consistently assign it when activating those directions. The actual key state is therefore primarily controlled through explicit key-down and key-up events.

2. **Timer behavior:** The combat timeout uses a one-shot timer without an explicit timer reset before every rescheduling operation. Repeated manual inputs may not always extend the timeout as intended.

3. **Shift pause control:** `shiftPausado` is initialized and reset to `false`, but the supplied script does not contain a dedicated hotkey that toggles it to `true`.

4. **Input simulation:** The script sends simulated keyboard inputs. Actual in-game behavior may depend on DayZ's input handling, the active window, and system permissions.

5. **No gameplay guarantees:** The script automates keyboard input only. It does not directly modify DayZ game files, game memory, or internal game mechanics.

6. **No logic changes:** This document describes the supplied script as written. It does not modify or correct its implementation.

## 12. Summary

The DayZ AutoHotkey Macro combines forced sprinting, automatic combat direction selection, manual Q/E direction locking, and comprehensive key-release routines.

Its design separates sprint control from combat direction management and includes reset, pause, suspension, and exit-cleanup mechanisms to help maintain predictable keyboard states during use.
