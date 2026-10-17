#!/usr/bin/env bash
# Pushes the GitHub Actions secrets used by the release-* workflows.
#
# Repo-level secrets (specific to this app) are read straight from local
# signing files under android/ — nothing needs to be retyped.
# "Shared" secrets (same values as alquranalkareem: Apple certs, ASC API key,
# AGC client) also go to THIS repo at repo level — the alheekmahlib account is
# personal, so GitHub org-level secrets are unavailable (the org API 404s).
# The Quran repo keeps its own copies and is never touched by this script.
#
# Values are piped straight into `gh secret set`; nothing is stored.
#
# Usage:
#   ./set-store-secrets.sh [options]
#
# Options:
#   --repo-only                 Skip the shared secrets
#   --shared-only               Only the shared secrets (alias: --org-only)
#   --ci-dir <dir>              Folder with the shared Apple certs
#                               (default: ~/Desktop/ci)
#   --play-service-account <f>  Play Console service-account JSON
#   --ios-profile <f>           App Store .mobileprovision for com.alheekmah.aqimApp
#   --ios-widget-profile <f>    App Store .mobileprovision for ...prayerWidget
#   --mas-profile <f>           macOS App Store .provisionprofile for the app
#   --mas-widget-profile <f>    macOS App Store .provisionprofile for the widget
#   --asc-key-id <id>           App Store Connect API key id
#   --asc-issuer-id <id>        App Store Connect issuer id
#   --asc-p8 <f>                App Store Connect AuthKey .p8 file
#   --agc-client-id <id>        Huawei AGC API client id
#   --agc-client-secret <s>     Huawei AGC API client secret
#   --maptiler-key <key>        MapTiler API key (auto-extracted from
#                               lib/core/utils/constants/api_keys.dart when
#                               that local file exists)
#
# Passwords for the .p12 certificates are prompted (hidden input) — they are
# the same passwords used when the alquranalkareem secrets were created.

set -euo pipefail

REPO="alheekmahlib/aqim"

REPO_ONLY=0
SHARED_ONLY=0
CI_DIR="$HOME/Desktop/ci"
PLAY_SA=""
IOS_PROFILE=""
IOS_WIDGET_PROFILE=""
MAS_PROFILE=""
MAS_WIDGET_PROFILE=""
ASC_KEY_ID=""
ASC_ISSUER_ID=""
ASC_P8=""
AGC_CLIENT_ID=""
AGC_CLIENT_SECRET=""
MAPTILER_KEY_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    --repo-only) REPO_ONLY=1 ;;
    --shared-only|--org-only) SHARED_ONLY=1 ;;
    --ci-dir) CI_DIR="$2"; shift ;;
    --play-service-account) PLAY_SA="$2"; shift ;;
    --ios-profile) IOS_PROFILE="$2"; shift ;;
    --ios-widget-profile) IOS_WIDGET_PROFILE="$2"; shift ;;
    --mas-profile) MAS_PROFILE="$2"; shift ;;
    --mas-widget-profile) MAS_WIDGET_PROFILE="$2"; shift ;;
    --asc-key-id) ASC_KEY_ID="$2"; shift ;;
    --asc-issuer-id) ASC_ISSUER_ID="$2"; shift ;;
    --asc-p8) ASC_P8="$2"; shift ;;
    --agc-client-id) AGC_CLIENT_ID="$2"; shift ;;
    --agc-client-secret) AGC_CLIENT_SECRET="$2"; shift ;;
    --maptiler-key) MAPTILER_KEY_ARG="$2"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1 (see --help)"; exit 1 ;;
  esac
  shift
done

fail() { echo "ERROR: $*" >&2; exit 1; }
need_file() { [ -f "$1" ] || fail "File not found: $1"; }

command -v gh >/dev/null 2>&1 || fail "gh CLI is required (brew install gh; gh auth login)"
gh auth status >/dev/null 2>&1 || fail "gh is not authenticated (gh auth login)"

# b64 <file> — single-line base64 (openssl -A works on macOS & Linux)
b64() { openssl base64 -A -in "$1"; }

# prop <file> <key> — reads a .properties value (strips CR)
prop() { sed -n "s/^$2=//p" "$1" | tr -d '\r' | head -1; }

set_repo_secret() { # name, value
  printf '%s' "$2" | gh secret set "$1" --repo "$REPO"
  echo "  repo  $1"
}
set_shared_secret() { # name, value — repo-level copy of a value shared with alquranalkareem
  printf '%s' "$2" | gh secret set "$1" --repo "$REPO"
  echo "  shared $1"
}
prompt_hidden() { # prompt text
  local v
  read -r -s -p "$1" v </dev/tty && echo >&2
  [ -n "$v" ] || fail "Empty value"
  printf '%s' "$v"
}

declare -a SET_LOG=()
declare -a MISSING_LOG=()

# ---------------------------------------------------------------- repo-level
if [ "$SHARED_ONLY" -eq 0 ]; then
  echo "== Repo-level secrets ($REPO) =="

  GP_PROP=android/google-play-key.properties
  HW_PROP=android/key.properties
  [ -f "$GP_PROP" ] || fail "Missing $GP_PROP (run from the repo root)"
  [ -f "$HW_PROP" ] || fail "Missing $HW_PROP (run from the repo root)"

  if [ -f android/google-play-keystore.jks ]; then
    set_repo_secret PLAY_KEYSTORE_BASE64 "$(b64 android/google-play-keystore.jks)"
    set_repo_secret PLAY_KEYSTORE_PASSWORD "$(prop "$GP_PROP" googlePlayStorePassword)"
    set_repo_secret PLAY_KEY_ALIAS "$(prop "$GP_PROP" googlePlayKeyAlias)"
    set_repo_secret PLAY_KEY_PASSWORD "$(prop "$GP_PROP" googlePlayKeyPassword)"
    SET_LOG+=("Play keystore + properties")
  else
    MISSING_LOG+=("PLAY_* — android/google-play-keystore.jks not found")
  fi

  if [ -f android/huawei-release-key.keystore ]; then
    set_repo_secret HUAWEI_KEYSTORE_BASE64 "$(b64 android/huawei-release-key.keystore)"
    set_repo_secret HUAWEI_KEYSTORE_PASSWORD "$(prop "$HW_PROP" storePassword)"
    set_repo_secret HUAWEI_KEY_ALIAS "$(prop "$HW_PROP" keyAlias)"
    set_repo_secret HUAWEI_KEY_PASSWORD "$(prop "$HW_PROP" keyPassword)"
    SET_LOG+=("Huawei keystore + properties")
  else
    MISSING_LOG+=("HUAWEI_* — android/huawei-release-key.keystore not found")
  fi

  if [ -n "$MAPTILER_KEY_ARG" ]; then
    set_repo_secret MAPTILER_KEY "$MAPTILER_KEY_ARG"
    SET_LOG+=("MapTiler key (from flag)")
  elif MT_EXTRACTED=$(sed -n "s/.*mapTilerKey = *'//;s/'.*//p" lib/core/utils/constants/api_keys.dart 2>/dev/null | head -1) && [ -n "$MT_EXTRACTED" ]; then
    set_repo_secret MAPTILER_KEY "$MT_EXTRACTED"
    SET_LOG+=("MapTiler key (from local api_keys.dart)")
  else
    MISSING_LOG+=("MAPTILER_KEY — pass --maptiler-key (no local lib/core/utils/constants/api_keys.dart to extract from)")
  fi

  [ -n "$PLAY_SA" ] && { need_file "$PLAY_SA"; set_repo_secret PLAY_SERVICE_ACCOUNT_JSON "$(cat "$PLAY_SA")"; SET_LOG+=("Play service account"); } \
    || MISSING_LOG+=("PLAY_SERVICE_ACCOUNT_JSON — pass --play-service-account <json>")
  [ -n "$IOS_PROFILE" ] && { need_file "$IOS_PROFILE"; set_repo_secret IOS_PROFILE_BASE64 "$(b64 "$IOS_PROFILE")"; SET_LOG+=("iOS app profile"); } \
    || MISSING_LOG+=("IOS_PROFILE_BASE64 — pass --ios-profile <mobileprovision>")
  [ -n "$IOS_WIDGET_PROFILE" ] && { need_file "$IOS_WIDGET_PROFILE"; set_repo_secret IOS_PROFILE_WIDGET_BASE64 "$(b64 "$IOS_WIDGET_PROFILE")"; SET_LOG+=("iOS widget profile"); } \
    || MISSING_LOG+=("IOS_PROFILE_WIDGET_BASE64 — pass --ios-widget-profile <mobileprovision>")
  [ -n "$MAS_PROFILE" ] && { need_file "$MAS_PROFILE"; set_repo_secret MAS_PROFILE_BASE64 "$(b64 "$MAS_PROFILE")"; SET_LOG+=("macOS app profile"); } \
    || MISSING_LOG+=("MAS_PROFILE_BASE64 — pass --mas-profile <provisionprofile>")
  [ -n "$MAS_WIDGET_PROFILE" ] && { need_file "$MAS_WIDGET_PROFILE"; set_repo_secret MAS_PROFILE_WIDGET_BASE64 "$(b64 "$MAS_WIDGET_PROFILE")"; SET_LOG+=("macOS widget profile"); } \
    || MISSING_LOG+=("MAS_PROFILE_WIDGET_BASE64 — pass --mas-widget-profile <provisionprofile>")
fi

# ------------------------------------------------------------- shared values
if [ "$REPO_ONLY" -eq 0 ]; then
  echo "== Shared secrets (repo-level in $REPO, values shared with alquranalkareem) =="

  DIST_P12="$CI_DIR/Apple Distribution/Certificates.p12"
  DEVID_P12="$CI_DIR/Certificates.p12"
  INSTALLER_P12="$CI_DIR/mas-installer.p12"

  if [ -f "$DIST_P12" ]; then
    IOS_P12_PW=$(prompt_hidden "Apple Distribution p12 password: ")
    set_shared_secret IOS_P12_BASE64 "$(b64 "$DIST_P12")"
    set_shared_secret IOS_P12_PASSWORD "$IOS_P12_PW"
    SET_LOG+=("Apple Distribution cert (shared)")
  else
    MISSING_LOG+=("IOS_P12_* — not found: $DIST_P12")
  fi

  if [ -f "$DEVID_P12" ]; then
    DEVID_PW=$(prompt_hidden "Developer ID Application p12 password: ")
    set_shared_secret MAC_DEV_ID_P12_BASE64 "$(b64 "$DEVID_P12")"
    set_shared_secret MAC_DEV_ID_P12_PASSWORD "$DEVID_PW"
    SET_LOG+=("Developer ID cert (shared)")
  else
    MISSING_LOG+=("MAC_DEV_ID_P12_* — not found: $DEVID_P12")
  fi

  if [ -f "$INSTALLER_P12" ]; then
    INSTALLER_PW=$(prompt_hidden "Mac Installer p12 password: ")
    set_shared_secret MAS_INSTALLER_P12_BASE64 "$(b64 "$INSTALLER_P12")"
    set_shared_secret MAS_INSTALLER_P12_PASSWORD "$INSTALLER_PW"
    SET_LOG+=("Mac Installer cert (shared)")
  else
    MISSING_LOG+=("MAS_INSTALLER_P12_* — not found: $INSTALLER_P12")
  fi

  if [ -n "$ASC_KEY_ID" ] && [ -n "$ASC_ISSUER_ID" ] && [ -n "$ASC_P8" ]; then
    need_file "$ASC_P8"
    set_shared_secret ASC_KEY_ID "$ASC_KEY_ID"
    set_shared_secret ASC_ISSUER_ID "$ASC_ISSUER_ID"
    set_shared_secret ASC_KEY_P8_BASE64 "$(b64 "$ASC_P8")"
    SET_LOG+=("App Store Connect API key (shared)")
  else
    MISSING_LOG+=("ASC_KEY_ID/ASC_ISSUER_ID/ASC_KEY_P8_BASE64 — pass --asc-key-id/--asc-issuer-id/--asc-p8 (the .p8 is NOT in $CI_DIR; create a new key in App Store Connect if the original is lost)")
  fi

  if [ -n "$AGC_CLIENT_ID" ] && [ -n "$AGC_CLIENT_SECRET" ]; then
    set_shared_secret AGC_CLIENT_ID "$AGC_CLIENT_ID"
    set_shared_secret AGC_CLIENT_SECRET "$AGC_CLIENT_SECRET"
    SET_LOG+=("Huawei AGC API client (shared)")
  else
    MISSING_LOG+=("AGC_CLIENT_ID/AGC_CLIENT_SECRET — pass --agc-client-id/--agc-client-secret (same AGC account as alquranalkareem)")
  fi
fi

# ------------------------------------------------------------------- summary
# note: ${ARR[@]+x} guards keep empty arrays safe under set -u on macOS bash 3.2
echo
echo "== Summary =="
if [ -n "${SET_LOG[@]+x}" ]; then
  printf '  set: %s\n' "${SET_LOG[@]}"
else
  echo "  set: (nothing)"
fi
if [ -n "${MISSING_LOG[@]+x}" ]; then
  echo "  still missing:"
  printf '    - %s\n' "${MISSING_LOG[@]}"
  exit 2
fi
echo "All secrets configured."
