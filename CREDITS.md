# Credits — Sweet2NfcFIX

- **dp** — Original `nfc_sweet2_fix` (PN557 `NXP_CORE_CONF 0x85` discovery, `libnfc-nxp.conf` patched `11.1.13`, `libnfc-nxp_RF.conf`, `/dev/nq-nci → /dev/nxp-nci` symlink)
- **cynosureforalleyes** — Lottery investigation with Deepseek (PN557 `11.1.22` vs `11.1.13`, `RF BLK 1 failed`, `ese_gpio`, `0x85` + `NXP_SET_CONFIG_ALWAYS`/`NXP_RF_UPDATE_REQ` analysis, Dual-Config idea)
- **vandalsquad187 / Badazz** — Merge `v3-lottery` (`v1 RF + v2 boot`, `chcon nfc_device`, Wait-Loop, `getprop` auto `sweet/sweet2`, logging, `versionCode 13`)
