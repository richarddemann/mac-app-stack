# Mac app stack

A selectable collection of macOS apps for setting up a new Mac. Pick a category, individual apps, or the whole list. This is a curated set of options, **not** a usage ranking or an exact snapshot of one computer. Some choices require a paid license, an account, or macOS permissions. Pure Paste comes from the Mac App Store; it is not a Homebrew cask.

## Choose apps

Install [Homebrew](https://brew.sh/) first. Run `bash choose.sh` to choose everything, a category, or individual apps. The script writes `Brewfile.selected` in your current folder for review. It does not install anything unless you add `--install`.

Examples:
```sh
bash choose.sh --research
bash choose.sh --utilities --output ./Brewfile.utilities
bash choose.sh --choose --output ./Brewfile.mine
bash choose.sh --all --output ./Brewfile.all
bash choose.sh --list
```

After reviewing a generated file, install with `brew bundle install --no-upgrade --file=./Brewfile.mine`. The `--no-upgrade` option avoids updating apps already managed by Homebrew. On an existing Mac, Homebrew may refuse to install over an app it does not manage; check those apps individually before proceeding.

Tinycast comes from the `abue-ammar/tinycast` tap; the chooser adds that tap when Tinycast is selected.

## Scope

This list installs apps. It does not transfer app settings, data, logins, licenses, or macOS permissions. Keep those in a separate personal restore plan, outside any public repository. Apple Silicon and Intel Macs can use this list; Homebrew chooses the appropriate download where a cask supports the machine.

To customize the public list, edit `catalog.tsv` or generate a Brewfile and remove anything you do not want. The chooser accepts these source types: Homebrew casks and Mac App Store apps through Homebrew Bundle's `mas` integration.
