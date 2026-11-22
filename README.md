# The Chronicles of Riddick: Assault on Dark Athena — GLSL compatibility fix

A small OpenGL shader compatibility fix for *The Chronicles of Riddick: Assault on Dark Athena* (2009). Unlike the older workaround that removes texture-bias arguments, this version keeps them.

Tested in-game on an NVIDIA GeForce RTX 4070 SUPER in November 2026. Other hardware and driver combinations have not yet been verified.

## Install — replace one file

Download **[HLInclude_GLSL.xrg](./HLInclude_GLSL.xrg)** from this repository (open the file, then select **Download raw file**).

The file belongs in the `System\GL` folder inside your installed game directory.

**Standalone installation**

Find the game's installation folder on your system drive or whichever drive you selected during setup. The path inside it is:

```text
The Chronicles of Riddick - Assault on Dark Athena\System\GL\HLInclude_GLSL.xrg
```

**Steam installation**

Open Steam, right-click the game, and choose **Manage → Browse local files**. The path relative to your Steam library commonly looks like:

```text
Steam\steamapps\common\The Chronicles of Riddick - Assault on Dark Athena\System\GL\HLInclude_GLSL.xrg
```

Folder names and library locations may vary.

1. **Back up** the existing `HLInclude_GLSL.xrg` somewhere safe.
2. Copy the downloaded `HLInclude_GLSL.xrg` into the game's `System\GL` folder.
3. Choose **Replace** when Windows asks.
4. Launch the game.

To undo the fix, restore your backed-up original file. No NVIDIA Profile Inspector changes were needed on the tested setup.

## What was actually changed?

The game's GLSL 1.20 include file originally defines these two helpers as functions:

```glsl
float4 tex2DBias(sampler2D _tex, float2 _st, float _bias) { return texture2D(_tex, _st, _bias); }
float4 texCubeBias(samplerCube _tex, float3 _str, float _bias) { return textureCube(_tex, _str, _bias); }
```

This fix replaces them with preprocessor macros:

```glsl
#define tex2DBias(_tex, _st, _bias) texture2D((_tex), (_st), (_bias))
#define texCubeBias(_tex, _str, _bias) textureCube((_tex), (_str), (_bias))
```

The patched file was compared with the original: **only these two functional definitions changed**, along with two explanatory comments. The texture-bias arguments are still passed to the original GLSL texture functions; they have **not** been disabled. No other graphics settings or rendering features were intentionally changed.

The working theory is that replacing unconditional helper functions with macros avoids compiling bias-using function bodies in shader stages that cannot use that operation. **The in-game launch/render test succeeded; the precise driver-compiler cause is not independently confirmed.**

This is a compatibility change, not a graphics enhancement.

## Alternative: patch your own original file

If you prefer not to download a complete replacement shader file, [`Apply-Fix.ps1`](./Apply-Fix.ps1) makes the same two functional changes to an **unmodified** local shader file. It requires the exact original function lines and creates a `.bak` backup.

Run in Windows PowerShell, adjusting the file path to your own installation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Apply-Fix.ps1 "C:\Path\To\Your\Game\System\GL\HLInclude_GLSL.xrg"
```

This script is optional. You do **not** need it if you installed the replacement `.xrg` above. The PowerShell script itself has not yet been tested on Windows.

## Compatibility and feedback

- **Tested:** NVIDIA GeForce RTX 4070 SUPER, game starts and renders with the modified shader.
- **Not yet verified:** other GPUs, driver versions, game builds, or every graphics effect.
- If the game still fails to start, report the GPU, graphics driver version, game edition, Windows version, and error message.
- If you notice visual corruption, restore the backup and describe where it occurs.

## Attribution and licensing

This is an unofficial community compatibility fix, not affiliated with the game's developers or publishers. The original shader file includes game-owned code, which remains subject to its original rights; the repository's MIT license does **not** grant rights over that underlying game code. The MIT license covers this project's original patching script and documentation.

The earlier workaround that removes texture bias predates this project. This repository provides a bias-preserving alternative.
