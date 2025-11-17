# Dominos_Fader Packaging Setup

Your addon now has automated packaging configured! Here's how it works and what you need to do.

## How It Works

The packaging system uses **GitHub Actions** and the **BigWigsMods packager** to automatically:
1. Create a release package when you push a git tag
2. Generate a changelog from your CHANGELOG.md
3. Upload to CurseForge (optional)
4. Upload to Wago Addons (optional)
5. Create a GitHub release with downloadable ZIP

## Setup Steps

### 1. Initialize Git Repository (if not already done)

```bash
cd "c:\Program Files (x86)\World of Warcraft\_beta_\Interface\AddOns\Dominos_Fader"
git init
git add .
git commit -m "Initial commit"
```

### 2. Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository named `Dominos_Fader` (or your preferred name)
3. Don't initialize with README (you already have one)
4. Push your local repo:

```bash
git remote add origin https://github.com/YOUR-USERNAME/Dominos_Fader.git
git branch -M main
git push -u origin main
```

### 3. Configure Secrets (Optional for CurseForge/Wago)

If you want to auto-upload to CurseForge or Wago:

#### For CurseForge:
1. Go to your GitHub repo → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `CF_API_KEY`
4. Value: Your CurseForge API token (get from https://authors.curseforge.com/account/api-tokens)

#### For Wago:
1. Same steps as above
2. Name: `WAGO_API_TOKEN`
3. Value: Your Wago API token (get from https://addons.wago.io/account/apikeys)

**Note:** If you skip these, the packager will still create GitHub releases, just not upload to those platforms.

### 4. Update TOC with Project IDs (Optional)

If using CurseForge or Wago, add these lines to your `.toc` file:

```
## X-Curse-Project-ID: YOUR_PROJECT_ID
## X-Wago-ID: YOUR_WAGO_ID
```

Get these IDs after creating projects on those platforms.

## Creating Releases

### Create a Release

When ready to release, create and push a git tag:

```bash
# Update your CHANGELOG.md first with version notes
git add CHANGELOG.md
git commit -m "Update changelog for v1.0.0"

# Create and push tag
git tag v1.0.0
git push origin v1.0.0
```

The GitHub Action will automatically:
- Build the addon package
- Create a GitHub release
- Upload to CurseForge (if configured)
- Upload to Wago (if configured)

### Version Numbering

Use semantic versioning:
- `v1.0.0` - Major release
- `v1.1.0` - Minor update (new features)
- `v1.0.1` - Patch (bug fixes)
- `v1.0.0-beta1` - Beta/alpha releases

### Tag Naming

The packager supports various tag formats:
- `v1.0.0` (recommended)
- `1.0.0`
- `release-1.0.0`
- Any tag will trigger a build

## Files Explained

### `.github/workflows/release.yml`
The GitHub Action workflow that runs the packager when you push a tag.

### `.pkgmeta`
Packaging configuration:
- `package-as`: The addon folder name in the ZIP
- `manual-changelog`: Points to your changelog file
- `ignore`: Files to exclude from the package
- `enable-nolib-creation`: Whether to create a nolib version

### `CHANGELOG.md`
Your version history. Update this before each release. The packager will automatically extract the relevant section for the release notes.

### `.gitignore`
Files that won't be committed to git (but you can customize this).

## Testing Locally

You can test packaging locally without pushing:

```bash
# Install the packager
git clone https://github.com/BigWigsMods/packager.git
cd packager

# Run it on your addon
./release.sh -d -z "c:\Program Files (x86)\World of Warcraft\_beta_\Interface\AddOns\Dominos_Fader"
```

## Workflow Customization

Edit `.github/workflows/release.yml` to customize:

**Release on every push to main** (not just tags):
```yaml
on:
  push:
    branches:
      - main
```

**Disable specific platforms:**
```yaml
args: -p 0 -w 0  # -p 0 = no CurseForge, -w 0 = no Wago
```

**Enable retail + classic builds:**
```yaml
args: -g ${{ secrets.GITHUB_TOKEN }}  # Builds for all game versions
```

## Troubleshooting

**Action fails:** Check the Actions tab in GitHub for error logs

**Missing secrets:** Make sure CF_API_KEY and WAGO_API_TOKEN are set if uploading to those platforms

**Wrong files in package:** Update the `ignore` list in `.pkgmeta`

**Changelog not included:** Ensure CHANGELOG.md exists and follows the format

## Resources

- [BigWigsMods Packager Documentation](https://github.com/BigWigsMods/packager)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [CurseForge API Tokens](https://authors.curseforge.com/account/api-tokens)
- [Wago API Keys](https://addons.wago.io/account/apikeys)

## Quick Reference

```bash
# Create a new release
git add .
git commit -m "Release v1.0.1"
git tag v1.0.1
git push origin main
git push origin v1.0.1

# Delete a tag if you made a mistake
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1
```

Good luck with your releases! 🚀
