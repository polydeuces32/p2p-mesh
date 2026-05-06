# P2P Mesh v5.3b QR Scanner Safety Plan

## Goal

Add camera-based QR scanning for pairing import without breaking the stable v5.3a paste-import flow.

## Safety Rules

- Keep paste-based import working.
- Treat camera scanning as progressive enhancement only.
- Do not make scanner required for pairing.
- Do not store or transmit private keys.
- Do not connect automatically unless a valid pairing payload is imported.
- Show a clear fallback when the browser does not support QR detection.

## Browser Compatibility

The first implementation should use the browser `BarcodeDetector` API when available.

If unsupported, the UI should display:

```text
Camera QR scanner is not supported in this browser. Use paste import instead.
```

This avoids adding a large third-party scanner dependency too early.

## v5.3b Implementation Scope

- Add camera preview element.
- Add `Start Scanner` button.
- Add `Stop Scanner` button.
- Request camera permission only after user clicks start.
- Scan QR frames using `BarcodeDetector`.
- Parse QR text as pairing JSON.
- Reuse existing `validatePairing()` and import logic.
- Auto-select the imported peer.
- Optionally call `connectImportedPeer()` after import.

## Rollback Plan

If scanner causes browser issues, remove only the scanner UI and functions. The v5.3a paste import path remains unchanged.
