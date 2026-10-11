#!/bin/bash
# Builds a drag-to-install DMG for an exported (notarized) DesktopCountdowns.app
#
# usage: Distribution/make-dmg.sh <path/to/DesktopCountdowns.app> [output dir]
# optional: SIGN_IDENTITY="Developer ID Application: ..." to sign the dmg,
#           NOTARY_PROFILE=<notarytool keychain profile> to notarize + staple it
set -euo pipefail

APP="${1:?usage: $0 <path/to/App.app> [output dir]}"
APP="${APP%/}"
OUT_DIR="${2:-$(dirname "$APP")}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

APP_NAME="$(basename "$APP" .app)"
VERSION="$(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString)"
BUILD="$(defaults read "$APP/Contents/Info.plist" CFBundleVersion)"
VOL_NAME="$APP_NAME $VERSION"
DMG="$OUT_DIR/$APP_NAME-$VERSION-$BUILD.dmg"

# window geometry, keep in sync with make_dmg_background.py
WIN_W=640
WIN_H=400
ICON_SIZE=128
APP_X=170
APPS_X=470
ICON_Y=180
# Finder window bounds include the title bar
TITLE_BAR_H=28

WORK="$(mktemp -d)"
trap 'hdiutil detach "$MOUNT" -quiet 2>/dev/null || true; rm -rf "$WORK"' EXIT
MOUNT="$WORK/mount"

echo "› rendering background"
python3 "$SCRIPT_DIR/make_dmg_background.py" "$WORK"
tiffutil -cathidpicheck "$WORK/background.png" "$WORK/background@2x.png" -out "$WORK/background.tiff" >/dev/null

echo "› staging"
STAGE="$WORK/stage"
mkdir -p "$STAGE/.background"
ditto "$APP" "$STAGE/$APP_NAME.app"
ln -s /Applications "$STAGE/Applications"
cp "$WORK/background.tiff" "$STAGE/.background/background.tiff"

echo "› creating writable image"
hdiutil create -quiet -volname "$VOL_NAME" -srcfolder "$STAGE" -fs HFS+ -format UDRW -ov "$WORK/rw.dmg"
mkdir -p "$MOUNT"
hdiutil attach -quiet -readwrite -noverify -noautoopen -mountpoint "$MOUNT" "$WORK/rw.dmg"

echo "› laying out Finder window"
# Finder only knows volumes under /Volumes by name, so address the mounted disk via its POSIX path
osascript <<EOF
tell application "Finder"
  set dmgFolder to (POSIX file "$MOUNT" as alias)
  open dmgFolder
  set theWindow to container window of dmgFolder
  set current view of theWindow to icon view
  set toolbar visible of theWindow to false
  set statusbar visible of theWindow to false
  set the bounds of theWindow to {200, 120, 200 + $WIN_W, 120 + $WIN_H + $TITLE_BAR_H}
  set opts to the icon view options of theWindow
  set arrangement of opts to not arranged
  set icon size of opts to $ICON_SIZE
  set text size of opts to 13
  set background picture of opts to file ".background:background.tiff" of dmgFolder
  set position of item "$APP_NAME.app" of dmgFolder to {$APP_X, $ICON_Y}
  set position of item "Applications" of dmgFolder to {$APPS_X, $ICON_Y}
  update dmgFolder without registering applications
  delay 1
  close theWindow
end tell
EOF

# use the app icon as the volume icon
if ICON_FILE="$(defaults read "$APP/Contents/Info.plist" CFBundleIconFile 2>/dev/null)"; then
  ICON_FILE="${ICON_FILE%.icns}.icns"
  if [ -f "$APP/Contents/Resources/$ICON_FILE" ]; then
    cp "$APP/Contents/Resources/$ICON_FILE" "$MOUNT/.VolumeIcon.icns"
    SetFile -a C "$MOUNT" 2>/dev/null || true
  fi
fi

chmod -Rf go-w "$MOUNT" || true
sync
hdiutil detach -quiet "$MOUNT"

echo "› compressing"
mkdir -p "$OUT_DIR"
hdiutil convert -quiet "$WORK/rw.dmg" -format UDZO -imagekey zlib-level=9 -ov -o "$DMG"

if [ -n "${SIGN_IDENTITY:-}" ]; then
  echo "› signing"
  codesign --sign "$SIGN_IDENTITY" --timestamp "$DMG"
fi
if [ -n "${NOTARY_PROFILE:-}" ]; then
  echo "› notarizing"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
fi

echo "✓ $DMG"
