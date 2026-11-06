# Cinemapedia logo

- `cinemapedia.png`: logo used by the Flutter app.
- `cinemapedia.svg`: editable vector reference.
- `../../tool/generate_brand_assets.py`: source for the generated PNGs.

To customize colors or geometry, edit the generator and run:

```powershell
python tool/generate_brand_assets.py
flutter build apk --debug
```

The generator requires Pillow (`python -m pip install pillow`).
It updates the Flutter logo, Android launcher icons and splash images together.
Changes to the SVG reference alone do not regenerate the PNGs.
Android launcher and splash changes require rebuilding and installing the app.
