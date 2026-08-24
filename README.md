# S.N.E.K.
**Sequence Next Enqueued Key**

Record key sequences and replay them with custom delays to help you beat Simon-Says style challenges.

## Features

- **Sequence Recorder** – Start and stop recording with a dedicated toggle key. Only records while the recorder is active.
- **Up to 10 Custom Keys** – Bind any keys you want (Key 1–Key 10). Each key can have its own custom text label. Empty labels are ignored.
- **Configurable Delays** – Set an initial delay after finalizing a sequence, plus a separate delay between each step.
- **Sequence Limit** – Default limit of 7 steps (fully configurable). Choose whether reaching the limit simply stops recording or automatically starts playback.
- **Enable / Disable** – The addon starts disabled by default. Toggle it on only when you need it.
- **Minimap Button** – Optional minimap icon for quick access to the options panel.
- **In-game Options Panel** – Configure everything without leaving the game.

## How to Use

1. Open the options panel (`/snek options` or the minimap button).
2. Enable the addon.
3. Bind your preferred keys:
   - **Toggle Recorder** – starts/stops recording
   - **Reset / Abort** – clears the current sequence
   - **Key 1–Key 10** – the keys that can be recorded
4. Assign a text label to each key you want to use.
5. Press the Toggle Recorder key, enter your sequence, then stop the recorder (or reach the sequence limit).
6. Finalize the sequence to begin playback with the configured delays.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/snek options` | Opens the options panel |
| `/snek minimap` | Toggles the minimap icon |
| `/snek on` | Enables the addon |
| `/snek off` | Disables the addon and clears any active sequence |
| `/snek reset` | Clears the current sequence without disabling the addon |
| `/snek help` | Shows available commands |
| `/snek version` | Prints the current version |

## Notes

- The addon is **disabled by default**. Enable it only when you intend to use it.
- Keybindings can also be set through the normal WoW Key Bindings menu under the **SNEK** category.
- Changes in the options panel are saved automatically.

---
