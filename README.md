# Project D Tinker 75 ISO configurator

This is a small, local WebHID configurator for the Ducky Project D Tinker 75 ISO keyboard.

Created with OpenAI Codex (GPT-5) on 18 August 2026.

This keyboard was originally configurable with a web-based tool hosted by the manufacturers.  That's no longer available and although the keyboard seems to broadly follow standard VIA protocols there's some incompatibility that means the open-source [UseVIA app](https://usevia.app) fails.

The [error log](VIA-app-errors.csv) from UseVIA shows an off-by-one problem: each interaction with the keyboard returns the previous command's response. This alternative app defaults to a two-exchange compatibility mode: it repeats each command and validates the second response. Commands are serialized so reads and writes cannot overlap. All commands are idempotent so the repetition is not a problem.

The app lacks many features of UseVIA — most notably, the keyboard matrix is presented as a raw grid rather than mapped to the physical layout.

## Use

1. Open the app from Chrome or Edge on the same Windows machine, using `localhost` or an HTTPS origin. WebHID is not available from an ordinary `file://` page. The included server uses port `8766` by default.
2. Click **Connect keyboard** and select the device with VID `3233` and PID `0011`.
3. Click **Probe protocol**, then **Read keymap**.
4. Select a key, edit its QMK keycode as decimal or hexadecimal, and click **Apply to selected key**.
5. Click **Write keymap** only after checking the local changes.

## Run the local server

Open PowerShell in the project folder and run:

```powershell
.\serve.ps1
```

Then open <http://localhost:8766/> in a Chromium browser. The server stays running in that PowerShell window; press `Ctrl+C` to stop it.

To use a different port, pass it with `-Port`:

```powershell
.\serve.ps1 -Port 9000
```

In that case, open <http://localhost:9000/> instead. If PowerShell blocks script execution, run it for this invocation with:

```powershell
powershell -ExecutionPolicy Bypass -File .\serve.ps1
```

The [JSON keyboard definition](Ducky_ProjectD_75_iso.json) is retained as the source description, but the transport does not depend on the definition being sideloaded into standard VIA. The matrix is fixed to the observed 11 x 8 Tinker 75 matrix and the app uses VIA dynamic-keymap buffer commands.

The configurator has been tested with a physically connected Tinker 75. The transaction log is intentionally visible; keep it when reporting a failed exchange.
