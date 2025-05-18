# -*- mode: python ; coding: utf-8 -*-

import os
import sys
from PyInstaller.utils.hooks import collect_data_files

block_cipher = None

# Get Python DLL directory
python_dir = os.path.dirname(sys.executable)

# Get additional binaries
binaries = []
for dll_file in os.listdir(python_dir):
    if dll_file.lower().startswith('python') and dll_file.lower().endswith('.dll'):
        binaries.append((os.path.join(python_dir, dll_file), '.'))

# Add poppler binaries if they exist - check both potential locations
poppler_paths = [
    os.path.join(os.getcwd(), 'poppler-windows', 'Library', 'bin'),
    os.path.join(os.getcwd(), 'poppler-bin')
]

for poppler_bin in poppler_paths:
    if os.path.exists(poppler_bin):
        print(f"Found Poppler binaries at: {poppler_bin}")
        for file in os.listdir(poppler_bin):
            # Include all files from the poppler directory
            src_file = os.path.join(poppler_bin, file)
            if os.path.isfile(src_file):
                binaries.append((src_file, 'poppler-bin'))
        # Once we've found poppler, no need to check other locations
        break
else:
    print("WARNING: No Poppler binaries found. PDF conversion may not work.")

a = Analysis(
    ['splash.py'],
    pathex=[],
    binaries=binaries,
    datas=[('icon.ico', '.')],
    hiddenimports=['pkg_resources.py2_warn'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='PDF2PNG_Converter',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='icon.ico',
    version='file_version_info.txt',
)
