# Minimal, offline GLSL compatibility patch for The Chronicles of Riddick: Assault on Dark Athena.
# Works on the caller's own game shader file; does not distribute game assets.
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ShaderPath
)

$ErrorActionPreference = 'Stop'
try {
    $file = (Resolve-Path -LiteralPath $ShaderPath -ErrorAction Stop).ProviderPath
    if ((Get-Item -LiteralPath $file).PSIsContainer) {
        throw 'Pass the full path to HLInclude_GLSL.xrg, not a folder.'
    }
    if ([IO.Path]::GetFileName($file) -ine 'HLInclude_GLSL.xrg') {
        throw 'Only HLInclude_GLSL.xrg is supported. No file was changed.'
    }

    $old2d = 'float4 tex2DBias(sampler2D _tex, float2 _st, float _bias) { return texture2D(_tex, _st, _bias); }'
    $oldCube = 'float4 texCubeBias(samplerCube _tex, float3 _str, float _bias) { return textureCube(_tex, _str, _bias); }'
    $new2d = '#define tex2DBias(_tex, _st, _bias) texture2D((_tex), (_st), (_bias))'
    $newCube = '#define texCubeBias(_tex, _str, _bias) textureCube((_tex), (_str), (_bias))'

    $contents = [IO.File]::ReadAllText($file, [Text.Encoding]::ASCII)
    if ($contents.Contains($new2d) -and $contents.Contains($newCube)) {
        Write-Host 'Bias-preserving macros are already installed. No changes made.'
        exit 0
    }
    if (-not $contents.Contains($old2d) -or -not $contents.Contains($oldCube)) {
        throw 'Expected original shader lines were not found. Different version or already modified. No file was changed.'
    }

    $backup = "$file.bak"
    if (Test-Path -LiteralPath $backup) {
        throw "Backup already exists: $backup. Keep it safe and resolve before retrying; no file was changed."
    }
    Copy-Item -LiteralPath $file -Destination $backup -ErrorAction Stop
    $modified = $contents.Replace($old2d, $new2d).Replace($oldCube, $newCube)
    [IO.File]::WriteAllText($file, $modified, [Text.Encoding]::ASCII)
    Write-Host "Patched: $file"
    Write-Host "Original backed up to: $backup"
    Write-Host 'Texture bias arguments were preserved. Test in-game rendering.'
} catch {
    Write-Error $_.Exception.Message
    exit 1
}