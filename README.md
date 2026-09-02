# Sweet2NfcFIX — PN557 NFC fix for sweet / sweet2 (lottery auto)

Magisk / KernelSU module. Fixes NFC `turning on` freeze on Redmi Note 12 Pro 4G (sweet2, NXP PN557 seen as PN817) on custom ROMs (Lineage 23.2 etc.).

## Problem (simple)
HAL sends `CORE_SET_CONFIG` with `NXP_CORE_CONF` containing `0x85,01,01`. Chip replies `Invalid Param tag 0x85`, then `RF Settings BLK 1 failed`, then tries firmware download (`ese_gpio invalid`) and never finishes. UI slider stuck, watchdog kills `com.android.nfc`. Chips are a lottery — some tolerate `0x85`, some don't (FW `11.1.13` vs `11.1.22`, RF EEPROM calibration).

## Fix
- Stop overwriting factory RF: `NXP_CORE_CONF` without `0x85`, `NXP_SET_CONFIG_ALWAYS=0x00`, `NXP_RF_UPDATE_REQ=0x00`
- Ship `libnfc-nxp_RF.conf` for HAL fallback (`/vendor/libnfc-nxp_RF.conf` + `/system/vendor/libnfc-nxp_RF.conf`)
- Early symlink `/dev/nq-nci → /dev/nxp-nci` + `chcon nfc_device` + wait-loop, then `ctl.restart vendor.nfc_hal_service`
- Lottery auto: `getprop ro.product.name/hw/device` chooses `libnfc-nxp.conf.sweet2-fix` (0x85 removed) vs `...-stock` (0x85 in). Override: `setprop persist.nfc.sweet2.conf fix|stock`

## Install
Flash `nfc_sweet2_fix_v3-lottery.zip` via Magisk / KernelSU / OrangeFox. Reboot.

## Verify
```
adb shell ls -l /dev/nxp-nci /vendor/etc/libnfc-nxp.conf
adb shell cat /data/local/tmp/nfc_fix.log
adb logcat -s NfcService | grep -v "RF Settings BLK 1 failed"
# NFC Settings → scan tag → mState=on
```

## Credits
See `CREDITS.md` — dp, cynosureforalleyes.
