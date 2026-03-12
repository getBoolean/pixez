# AltStore Release Contract

This repository generates and updates `AltStore.json` during tag-based iOS releases.

## Trigger

- Workflow: `.github/workflows/ci.yml`
- Condition: push events where the ref matches `refs/tags/v*`

## Mapping Rules

- **Tag**: `vX.Y.Z`
- **AltStore version**: `X.Y.Z` (leading `v` stripped)
- **IPA filename**: `pixez-vX.Y.Z-ios.ipa`
- **Download URL**: `https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/pixez-vX.Y.Z-ios.ipa`

## Updated Fields

The release automation updates `apps[0].versions[0]` in a generated `AltStore.json` built from `.github/templates/AltStore.template.json`:

- `version`
- `date` (UTC timestamp in `YYYY-MM-DDTHH:MM:SS`)
- `localizedDescription` (tag annotation if present; otherwise `Release <tag>`)
- `downloadURL`
- `size` (bytes from the generated IPA artifact)
- `minOSVersion`

## Operational Note

After updating `AltStore.json`, the workflow publishes the file to `gh-pages` using `JamesIves/github-pages-deploy-action`, so the hosted source is refreshed without writing to protected `main`.
