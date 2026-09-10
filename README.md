# animepahe downloader for Windows

**Double-click it. No command line, no WSL, no copying Cloudflare cookies by hand.**

Pick a title, pick episodes, watch them download. A menu-driven downloader for
[animepahe](https://animepahe.pw) that sets itself up.

![Demo](docs/demo.gif)

**Download → [`anime-downloader.bat`](anime-downloader.bat) → double-click → `[3] First-time Setup`**

---

## Why this one

- **No command line.** Numbered menus. You never memorise a flag.
- **Nothing to install by hand.** No WSL, no `jq`, no `fzf`, no `curl-impersonate`.
  Python is the only requirement.
- **No cookie copying.** It handles the Cloudflare check itself, so it doesn't break
  every time a `cf_clearance` value expires.
- **Threaded downloads**, with a thread count suggested from your actual RAM.
- **Settings that stick.** Quality, audio track, folder and threads are saved once and
  reused.

---

## Requirements

- Windows 10 or 11
- Python 3.11 or newer, installed with **Add Python to PATH** ticked

That's the whole list.

---

## Install

1. Download [`anime-downloader.bat`](anime-downloader.bat).
2. Double-click it.
3. Choose **`[3] First-time Setup`**.
4. It shows you the exact install command, you type `Y`, then answer two questions:
   how many parallel downloads, and where to save files.

Then use **`[1] Download Anime`** whenever you want something.

---

## Menu

| Option | What it does |
|---|---|
| `[1] Download Anime` | Starts the downloader |
| `[2] Settings` | View and change folder, threads, quality, audio |
| `[3] First-time Setup` | Installs or updates the downloader; sets threads and folder |
| `[4] About / Verify` | Publisher, version, install source, uninstall command |
| `[5] Exit` | Closes the window |

### Settings

| Setting | Options |
|---|---|
| Download folder | any folder, chosen in a native Windows picker |
| Threads | 2 / 4 / 8 / 16 / 24 typical |
| Video quality | `best` · `1080` · `720` · `480` · `360` |
| Audio language | `jpn` (subs) · `eng` (dub) |

Settings persist between runs. If a chosen quality or audio track isn't available for an
episode, it falls back instead of failing.

---

## How it works

`anime-downloader.bat` is a **launcher** — about 500 lines, mostly menu text, readable in
one sitting. It contains no download logic. The downloader itself is a Python package
(`anime_pahe`) that the launcher installs and then calls with one line:

```bat
python -c "from anime_pahe.cli import main; main()"
```

### What setup actually does

1. **Finds Python** with `where python`. If there's nothing, it opens python.org and
   explains the one installer checkbox that matters.
2. **Checks the version** is 3.11+. This also catches the Microsoft Store `python`
   placeholder that ships with Windows — a fake `python` that exists on a clean Windows 11
   machine and breaks everything downstream.
3. **Prints the exact `pip install` command** and the index it downloads from, then waits
   for you to type `Y`. Nothing installs silently.
4. **Upgrades pip**, then installs the downloader at a pinned version.
5. **Reads your RAM** with PowerShell (`Get-CimInstance Win32_ComputerSystem`) — not
   `wmic`, and not batch arithmetic, because `set /a` is 32-bit signed and overflows on
   large-memory machines.
6. **Suggests a thread count** from that figure, which you can override.
7. **Opens the native Windows folder picker** and saves your choice. The picker writes the
   path straight to a temp file, so folders with spaces, `&` or brackets in the name can't
   corrupt it.
8. **Saves both settings** into the downloader's config.

### RAM to thread suggestion

| RAM | Threads |
|---|---|
| 2 GB | 2 |
| 4 GB | 4 |
| 8 GB | 8 |
| 16 GB | 16 |
| 32 GB+ | 24 |

---

## Verify it before you run it

Reasonable thing to do with any `.bat` you download from a stranger.

- **Read the file.** It's one file in this repo. There is no obfuscation and no remote
  code in it beyond the package install it prints on screen.
- **Menu `[4] About / Verify`** shows the publisher, the source URL, the exact package and
  version it installs, which index that comes from, and the uninstall command.
- **Check what's installed:** `python -m pip show pkg-anime-1`
- **Remove it:** `python -m pip uninstall pkg-anime-1`

**About the downloader package.** It's `anime_pahe`, published as `pkg-anime-1`. It
currently comes from **TestPyPI**, which is a testing index rather than the production
one — so a release can disappear when the index cleans up, and the install uses
`--extra-index-url` so dependencies resolve from the real PyPI. That's disclosed rather
than hidden, it's shown on screen during setup, and moving off it is the first item on the
roadmap below.

**Why there's no verified publisher name yet.** Windows shows "unknown publisher" for
unsigned software. A real verified name needs a paid code-signing certificate *and* a
signed `.exe` — a `.bat` can't display one at all. Until then, the launcher prints its
publisher on screen instead.

---

## Troubleshooting

**"python is not recognized as an internal or external command"**
Python is missing or not on PATH. Reinstall from python.org and tick **Add Python to PATH**
on the first installer screen. Unticking and re-ticking later doesn't work; it needs a
reinstall.

**Setup says my Python is too old, but I installed it today**
You're hitting the Microsoft Store `python` placeholder. Install the real one from
python.org. The launcher detects this and tells you which case you're in.

**"Not installed yet. Run option [3] First-time Setup first."**
Exactly what it says.

**Install worked before, now it fails**
TestPyPI removes old releases. Run First-time Setup again; if it fails identically, say so
in an issue.

**Windows says "Windows protected your PC"**
SmartScreen reacting to an unsigned download → **More info → Run anyway**. That prompt
exists for a good reason, and it's safe here only because you can read the whole launcher
first. If you haven't, read it.

**Antivirus flags the `.bat`**
Unsigned scripts that install and run downloaded code get flagged heuristically. Read the
file and check the install command it prints. Don't disable your antivirus for it.

**A folder with `!` in the name**
Avoid it, and avoid `!` in your Windows username if you can. Batch delayed-expansion
mangles `!` in paths — a `.bat` limitation, not something the launcher can fully work
around.

---

## Uninstall

```bat
python -m pip uninstall pkg-anime-1
```

Menu `[2] Settings` prints the config file path — delete that too. The `.bat` itself is
just a file; delete it whenever.

---

## Roadmap

- [ ] Publish the `anime_pahe` source in this repo, so the downloader can be read before
      it runs
- [ ] Move the package off TestPyPI — real PyPI, a Release wheel, or `pip install git+`
- [ ] One-file `.exe` built in GitHub Actions and attached to a Release, with a
      `SHA256SUMS.txt` — no Python required at all
- [ ] VirusTotal report link and SHA256 on each Release
- [ ] A signed publisher name, once a certificate is worth the cost
- [ ] A demo GIF at the top of this file

<!-- ONE THING STILL BLANK: list every host the downloader contacts, from the
     anime_pahe source, and add it here as a short "Network" section. Every host,
     including any third-party helper service. Don't guess — read the source.
     This is the single most common reason tools like this get accused of being
     malware, so it's worth doing properly. -->

---

## Disclaimer

A personal tool for downloading anime episodes to watch offline. It hosts and
redistributes no content — it pulls from a third-party site, and whether you have the right
to do that is on you. Watch it, then delete it.

## License

MIT — see [LICENSE](LICENSE).
