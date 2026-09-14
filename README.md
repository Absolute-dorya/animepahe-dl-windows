# Anime Downloader for Windows

A simple Windows `.bat` launcher for the `pkg-anime-1` anime downloader package.

The launcher provides a menu for downloading anime, configuring settings, and completing first-time setup.

## Features

- Simple command-line menu
- First-time setup and package installation
- Automatic Python version check
- Automatic pip upgrade
- Installs `pkg-anime-1==1.3.5`
- Download folder picker
- Configurable download threads
- Automatic RAM detection
- Video quality settings
- Audio language settings
- Directly launches the Python anime downloader
- Cloudflare browser support when required by the downloader

## Requirements

- Windows 10 or Windows 11
- Python 3.11 or newer
- Python added to PATH
- Internet connection

## Installation

### 1. Download the launcher

Download the `anime-downloader.bat` file from this repository.

### 2. Install Python

If Python is not installed, download it from:

https://www.python.org/downloads/

During installation, enable:

```text
Add Python to PATH
```

### 3. Run the launcher

Double-click:

```text
anime-downloader.bat
```

Or run it from Command Prompt:

```bat
anime-downloader.bat
```

### 4. Complete first-time setup

Choose:

```text
[3] First-time Setup
```

The setup process will:

1. Check whether Python is installed.
2. Upgrade pip.
3. Install `pkg-anime-1==1.3.5`.
4. Detect your system RAM.
5. Suggest a download thread count.
6. Let you select a download folder.
7. Start the downloader.

## Main Menu

```text
=========================================
 ANIME DOWNLOADER
=========================================

 [1] Download Anime
 [2] Settings
 [3] First-time Setup (install / update)
 [4] Exit
```

## Settings

The launcher provides the following settings:

| Setting | Description |
|---|---|
| Download folder | Choose where downloaded files are saved |
| Thread count | Configure download concurrency |
| Video quality | Select the available video quality |
| Audio language | Select Japanese or English audio |

## Thread Recommendations

The launcher suggests thread counts based on detected RAM:

| System RAM | Suggested threads |
|---:|---:|
| 2 GB | 2 |
| 4 GB | 4 |
| 8 GB | 8 |
| 16 GB | 16 |
| 32 GB or more | 24 |

These are suggestions only. Actual performance depends on your internet connection, server speed, CPU, RAM, and the downloader package.

## Project Structure

```text
anime-downloader/
└── anime-downloader.bat
```

## Troubleshooting

### Python is not recognized

Install Python 3.11 or newer and enable `Add Python to PATH`.

Then close and reopen Command Prompt and run the launcher again.

### Package installation fails

Check:

- Your internet connection
- Whether Python and pip are working
- Whether the package is available from the configured package indexes
- Whether your firewall or antivirus is blocking the installation

The launcher installs the package using TestPyPI with PyPI as an extra index.

### Downloader is not installed

Open the launcher and select:

```text
[3] First-time Setup
```

### A browser window opens

A browser window may open briefly for Cloudflare verification. This can be normal behavior of the underlying downloader.

## Package Source

This launcher installs:

```text
pkg-anime-1==1.3.5
```

The package is installed using:

- TestPyPI: https://test.pypi.org/simple/
- PyPI: https://pypi.org/simple/

## Disclaimer

This project is a launcher for an external Python downloader package.

Use it only to download content that you are legally authorized to access. Respect copyright, website terms of service, and applicable laws in your country.

## Contributing

Contributions and suggestions are welcome.

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Test the launcher on Windows.
5. Open a pull request.

## License

Add your preferred open-source license here.

---

Made for anime fans who want a simple Windows downloader.
