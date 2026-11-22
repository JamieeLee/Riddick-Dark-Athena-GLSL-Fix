# The Chronicles of Riddick: Assault on Dark Athena — GLSL compatibility fix (texture bias preserved)

An experimental, minimal OpenGL shader-compatibility patch for *The Chronicles of Riddick: Assault on Dark Athena* (2009) on modern graphics drivers.

## What this changes

The common startup-crash workaround removes the third (`_bias`) argument from `texture2D` and `textureCube` calls. That can change the game's intended mipmap-level selection.

This alternative changes **only two definitions** in `System\GL\HLInclude_GLSL.xrg`: it replaces their GLSL 1.20 helper **functions** with preprocessor **macros**, while leaving the three-argument texture lookup intact. The intended behavior is to retain texture LOD bias when used by fragment shaders, while avoiding unconditional helper-function compilation in shader stages where bias arguments are unsupported.

This is not a graphics enhancement. It aims to retain original behavior while improving driver compatibility.

## Install — manual (recommended)

The shader file is located inside your game's installation folder. A typical path is:

```text
D:\The Chronicles of Riddick - Assault on Dark Athena\System\GL\HLInclude_GLSL.xrg
```

Replace `D:` with the drive and game installation location on your computer. This is the **game folder**, not the folder under AppData.

1. Find your game's `System\GL\HLInclude_GLSL.xrg` file.
2. **Back it up** before editing.
3. Open it in a text editor and locate these exact lines:

   ```glsl
   float4 tex2DBias(sampler2D _tex, float2 _st, float _bias) { return texture2D(_tex, _st, _bias); }
   float4 texCubeBias(samplerCube _tex, float3 _str, float _bias) { return textureCube(_tex, _str, _bias); }
   ```

4. Replace them with these **single-line** definitions:

   ```glsl
   #define tex2DBias(_tex, _st, _bias) texture2D((_tex), (_st), (_bias))
   #define texCubeBias(_tex, _str, _bias) textureCube((_tex), (_str), (_bias))
   ```

5. Save, start the game, and check that shaders render correctly.

Alternatively, inspect and run `Apply-Fix.ps1` as described below. Do not combine this patch with the common *remove `_bias`* replacement: begin with an unmodified shader file.

## Optional PowerShell patcher

In Windows PowerShell, from the folder containing this README and the script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Apply-Fix.ps1 "C:\Path\To\Game\System\GL\HLInclude_GLSL.xrg"
```

- The script refuses to change a file if it can't find **both exact, expected original lines**.
- It makes a `.bak` backup before writing.
- If the two macros are already present, it reports that the patch is already applied.
- The script does not download anything or modify other game files.

## If the OpenGL error changes to "Unhandled Exception" (NVIDIA only)

Some existing community instructions describe a **separate** NVIDIA driver-profile workaround if the initial OpenGL/GLSL startup error disappears but the game then fails with an "Unhandled Exception":

1. Open **NVIDIA Profile Inspector** (a third-party utility).
2. Select the profile for **The Chronicles of Riddick: Assault on Dark Athena**.
3. Under **Common**, find **Extension Limit (OGL)**.
4. Change the value from **Off** to `0x00004844`.
5. Click **Apply Changes**, then try launching the game again.

This is **optional troubleshooting**, not part of the shader patch or a required installation step. The value comes from earlier community repair instructions; it has **not been verified as necessary for this bias-preserving patch**. Change only the game's profile, note its previous value, and restore the previous setting if it does not help. Profile Inspector is **not bundled or installed** by this repository.

Source of this additional workaround: [Chronicles of Riddick Modern Drivers Fix (Nexus Mods)](https://www.nexusmods.com/chroniclesofriddickassaultondarkathena/mods/6).

## Tested / limitations

- **Confirmed by one player:** Game starts and renders on an **NVIDIA GeForce RTX 4070 SUPER** with this modification in place (November 2026). NVIDIA driver version and game distribution/build were not recorded.
- This is **not yet verified** across all GPUs, driver versions, versions of the game, or shader paths. Some shader configurations might still fail to compile. Please report reproducible results.
- The patch addresses the GLSL include only, not unrelated graphics, DRM, resolution, or performance problems.
- If a black screen, shader error, or visual corruption occurs, restore the `.bak` and report the game build, GPU, driver version, and error message.

## Why this package does not include `HLInclude_GLSL.xrg`

The original `.xrg` is a game asset. To avoid redistributing proprietary game code, this package contains **only instructions and a targeted patching script**. You must provide your own legitimately installed copy of the game.

## Suggested issue report

GPU, driver version, game build/store, Windows version, whether the game launches, graphics defects if any, relevant error text, and whether the original unmodified shader or the bias-stripping workaround behaves differently.

## Notes

This is an unofficial community compatibility patch and is not affiliated with Starbreeze Studios or the game’s publishers. The third-argument removal workaround predates this patch; this project offers a bias-preserving alternative.