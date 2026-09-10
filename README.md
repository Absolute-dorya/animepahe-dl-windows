# animepahe downloader for Windows

**Double-click it. No Python command line, no WSL, no copying Cloudflare cookies by hand.**

A menu-driven launcher for downloading anime from [animepahe](https://animepahe.pw) on
Windows. Pick a title, pick episodes, watch the progress bars.

![demo](docs/demo.gif)

> ### TODO — fill these in before you publish, then delete this block
>
> - `YOUR-NAME-HERE` — the publisher name, in the `.bat` EDIT block and below
> - `YOUR-USERNAME/YOUR-REPO` — the repo URL, in the `.bat` EDIT block and below
> - `docs/demo.gif` — a screen recording of the menu. Highest-value item in this file.
> - `<config path>` in "What this does to your PC" — find it via menu option [2]
> - the network call list in the same section — read it out of the `anime_pahe` source,
>   do not guess
> - the license you actually want (the `.bat` currently declares MIT)
> - delete the "Known limitations" entries you have fixed

---

## What this actually is

Two separate things. Read this part before you run anything.

| | What it is | Where the code lives |
|---|---|---|
| `anime-downloader.bat` | The launcher. Menus, settings, setup, folder picker, RAM detection. This is what you download and double-click. | **In this repo.** About 500 lines, mostly menu text, readable in one sitting. |
| `anime_pahe`, published as `pkg-anime-1` | The downloader. Searching, episode listing, Cloudflare handling, the download itself. | **Not in this repo.** It is a Python package installed by the launcher. |

The `.bat` contains **no download logic at all**. All it does is install the package above
and then run one line:

```bat
python -c "from anime_pahe.cli import main; main()"
```

That split is deliberate, but it is also the thing you should be suspicious about. Keep
reading.

---

## The publisher, and why you should check before you run this

Downloading a stranger's `.bat` from the internet and double-clicking it is a genuinely
bad idea in general. This section exists so you can decide, rather than trust.

**Who made this.** `YOUR-NAME-HERE`. Source, issues and the full revision history:
`https://github.com/YOUR-USERNAME/YOUR-REPO`. License: MIT.

**The `.bat` shows its own provenance.** When you run it, the main menu prints the
publisher name and launcher version, and menu option **[4] About / Verify** shows:

- the publisher, the source URL and the license
- the exact package name and version it installs
- which index it installs from
- the command to check the installed version (`python -m pip show pkg-anime-1`)
- the command to remove it (`python -m pip uninstall pkg-anime-1`)

**Nothing installs without your explicit consent.** First-time Setup prints the complete
`pip install` command on screen and waits for you to type `Y`. There is no silent step.

**The author is not the only thing to check.** If you are security-minded, the honest
answer is: `pkg-anime-1` is currently published on TestPyPI rather than the real PyPI, and
the downloader's source is not in this repository. Both of those are real reasons to
hesitate, they are explained in full under
[About the `pkg-anime-1` package](#about-the-pkg-anime-1-package), and moving them off that
footing is the first item on the roadmap.

**No verified publisher name (yet).** Windows shows "Windows protected your PC — unknown
publisher" for unsigned software. Getting a real verified publisher name requires a paid
Authenticode code-signing certificate from a certificate authority *and* shipping a signed
`.exe` — a `.bat` cannot display a verified publisher at all. Signing certificate vendors
generally advertise pricing from roughly USD 200/year, and Microsoft's own Azure Trusted
Signing is a lower-cost route; check current eligibility and pricing before paying for
anything. Until then, this launcher prints its publisher and provenance on screen instead,
which is the free version of the same idea. See the roadmap.

---

## Requirements

- Windows 10 or 11
- Python 3.11 or newer, installed with **Add Python to PATH** ticked

You do **not** need `jq`, `fzf`, `curl-impersonate`, `yt-dlp`, WSL, or any command-line
knowledge.

---

## Install

1. Download [`anime-downloader.bat`](anime-downloader.bat) — right-click → Save link as,
   or clone this repo.
2. Double-click it.
3. Choose **[3] First-time Setup**.
4. Read the install command it shows you, type `Y`, then answer the two questions about
   download threads and where to save files.

After that, option **[1] Download Anime** starts the downloader.

---

## How the launcher works

A walkthrough of every step, so nobody has to reverse-engineer a `.bat`.

### Main menu

| Option | What it does |
|---|---|
| `[1] Download Anime` | Checks the package is installed with `python -m pip show`, then runs the downloader |
| `[2] Settings` | Shows current settings and lets you change folder, threads, quality, audio |
| `[3] First-time Setup` | Installs or updates the package; configures threads and download folder |
| `[4] About / Verify` | Publisher, source, version, install source, uninstall command |
| `[5] Exit` | Closes the window |

### First-time Setup, step by step

1. **Python check.** Runs `where python` first. If nothing is found it opens
   python.org, explains that "Add Python to PATH" must be ticked, and stops.
2. **Version check.** Runs `python -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)"`.
   This deliberately also catches the fake `python` alias that ships with Windows via the
   Microsoft Store, which exists on a clean Windows 11 machine but is not real Python.
3. **Shows the exact command** it is about to run, including the index it downloads from,
   then waits for `Y`.
4. **Upgrades pip,** then installs the package at a pinned version.
5. **Detects your RAM** with PowerShell
   (`Get-CimInstance Win32_ComputerSystem`). Not `wmic`, and not batch arithmetic —
   `set /a` is 32-bit signed and overflows on large-RAM machines.
6. **Suggests a thread count** from that RAM figure and lets you override it.
7. **Opens a native Windows folder picker** for the download location.
8. **Saves both settings** into the downloader's config.

### RAM to thread suggestion

| RAM | Suggested threads |
|---|---|
| 2 GB | 2 |
| 4 GB | 4 |
| 8 GB | 8 |
| 16 GB | 16 |
| 32 GB+ | 24 |

### Settings, and where they live

| Setting | Options | Storage |
|---|---|---|
| Download folder | any folder | chosen via the native picker |
| Threads | 2 / 4 / 8 / 16 / 24 typical | `<config path — fill in>` |
| Video quality | `best`, `1080`, `720`, `480`, `360` | same |
| Audio language | `jpn` (subs), `eng` (dub) | same |

Settings persist between runs. If a chosen quality or audio track is unavailable for a
given episode, the downloader falls back rather than failing.

---

## About the `pkg-anime-1` package

Full disclosure, because where software comes from is part of whether you should run it.

**What it is.** The actual downloader: the Python package `anime_pahe`, published under
the distribution name `pkg-anime-1` and imported as `anime_pahe`.

**Where it comes from.** TestPyPI, with dependencies resolved from the real PyPI:

```
python -m pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ "pkg-anime-1==1.3.5"
```

**Why that is worth knowing.**

1. **TestPyPI is a testing index.** The Python project runs it so people can rehearse
   releases. It is not meant to serve real users, and its releases **are periodically
   deleted**. If installation suddenly fails for no reason, the package having been purged
   is the most likely cause.
2. **`--extra-index-url` is the classic dependency-confusion pattern.** It lets pip look
   at both indexes, so a package with a matching name on the real PyPI can be selected
   ahead of the dependency you meant. It is a known, actively abused construction. The
   launcher shows you this exact line rather than hiding it, but disclosing a risk is not
   the same as removing it.
3. **The package source is not in this repository**, so you cannot read the downloader
   before running the launcher. `YOUR-USERNAME/anime_pahe` — link the source repo here the
   moment it exists, or better, put it in this repo.

**The plan.** Move to the real PyPI, or attach a wheel to a GitHub Release and install
from the release URL, or install straight from this repo with
`pip install git+https://github.com/YOUR-USERNAME/YOUR-REPO.git@v1.4.0`. When that
happens this section gets shorter and the install gets one less caveat. The `.bat` has a
single `EDIT THIS BLOCK` section at the top where the package source is defined, so it is
a one-line change.

---

## What this does to your PC

Written to be checkable rather than reassuring.

- **Config file:** `<config path — fill in>` (view it via menu option [2] Settings)
- **Downloads:** only into the folder you chose in the picker. Nothing is written
  elsewhere.
- **Registry:** nothing is written to the registry.
- **Telemetry:** none. No analytics, no usage reporting, no accounts, no update pings.
- **Uninstall:** `python -m pip uninstall pkg-anime-1`, then delete the config file above.
- **Network connections it makes:** `<fill this in from the anime_pahe source — list every
  host it contacts, including any third-party service. Do not guess; read the source.>`

That last line is the one people actually want. A downloader that talks to an undisclosed
third party (for example, to unpack the site's obfuscated player JavaScript) is the single
most common reason tools like this get accused of being malware. List every host, or state
plainly that there are exactly two.

---

## Troubleshooting

**"python is not recognized as an internal or external command"**
Python is missing or not on PATH. Reinstall from python.org and tick **Add Python to PATH**
on the first screen of the installer. Untick-then-retick requires a full reinstall.

**Setup says my Python is too old, but I just installed it**
You are almost certainly hitting the Microsoft Store `python` alias that Windows ships.
Install the real thing from python.org. The launcher detects this specifically and tells
you which of the two it is.

**"Not installed yet. Run option [3] First-time Setup first."**
Exactly what it says. The downloader package is not present in your Python.

**Installation failed and it used to work**
TestPyPI removes old releases. Run First-time Setup again, and if it fails the same way,
report it — see the roadmap for the permanent fix.

**Windows says "Windows protected your PC"**
That is SmartScreen reacting to an unsigned download. Click **More info → Run anyway**.
Be aware that this is generally terrible advice — it is safe here only because you can
read the whole `.bat` in this repo before running it. If you have not read it, read it.

**A folder with `!` in the name**
Avoid it, and avoid `!` in your Windows username if you can. Batch file delayed expansion
mangles `!` in paths; the folder picker writes your choice to a temp file to dodge the
related spaces-and-ampersands problems, but `!` is a batch limitation rather than
something the launcher can fully work around.

**Antivirus flags the `.bat`**
Unsigned scripts that download and execute code get flagged heuristically. Read the file,
check the install command it prints, and decide. Do not disable your antivirus for it.

---

## Uninstall

```bat
python -m pip uninstall pkg-anime-1
```

Then delete the config file listed in "What this does to your PC". The `.bat` itself is
just a file — delete it whenever.

---

## Known limitations

- The downloader's source is not in this repo, so it cannot be audited before use.
- Distribution goes through TestPyPI, which is a testing index.
- No `.exe` yet, so Python 3.11+ is a hard requirement.
- No signed release, so SmartScreen warns on first run.
- Threads apply to parallel episode downloads; a single episode still downloads as one
  stream.
- Folder names containing `!` are not handled (batch limitation, see Troubleshooting).

---

## Roadmap

1. Publish the `anime_pahe` source in this repository so it can be read before it is run.
2. Move the package off TestPyPI — real PyPI, a Release wheel, or `pip install git+`.
3. Build a one-file `.exe` in GitHub Actions and attach it to a Release, with a
   `SHA256SUMS.txt` file. No Python required at all.
4. Add a VirusTotal report link and the SHA256 to each Release, since unsigned binaries
   get flagged heuristically.
5. Replace "unknown publisher" with a real signed publisher name once a code-signing
   certificate is worth the cost.
6. A demo GIF at the top of this README.

---

## Disclaimer

This is a personal tool for downloading anime episodes to watch offline. It hosts and
redistributes no content of its own — it downloads from a third-party site, and whether
you have the right to do that is your responsibility, not the author's. Watch what you
download, then delete it.

Note also that repositories in this category do receive takedown requests, and a takedown
takes the whole repo with it.

## License

MIT. See [LICENSE](LICENSE).
