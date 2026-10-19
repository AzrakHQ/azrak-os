<p align="center"><img src="https://raw.githubusercontent.com/AzrakHQ/azrak-launcher/main/assets/azrak.svg" width="128" alt="Azrak"></p>

<h1 align="center">AzrakOS</h1>

<p align="center"><b>Turn a spare PC into a game console.</b><br>
It starts straight into <a href="https://github.com/AzrakHQ/azrak-launcher">Azrak Launcher</a>: pick a game with your controller and play.</p>

<p align="center"><a href="https://github.com/AzrakHQ/azrak-os/releases/latest/download/azrak-os-x86_64.iso"><b>⬇ Download the installer</b></a> (1.2 GB)</p>

![Azrak Launcher: the Home screen, a game's page, then the Library](https://raw.githubusercontent.com/AzrakHQ/azrak-launcher/main/docs/demo/demo-loop.webp)

## What you get

- **A PC that works like a console.** Turn it on and the launcher is there. No desktop, no
  passwords to type, no pop-ups.
- **PS5, PS4 and PC games** with their official artwork and trailers. Download, install and
  play them without leaving the launcher.
- **Use a controller.** DualSense, DualShock 4, Xbox and most others, over USB or Bluetooth.
- **It looks after itself.** The system, the launcher and the emulators update on their own. If
  an update ever breaks something, the previous version is still there in the boot menu.

## What you need

- A **USB stick** of 2 GB or more.
- **Internet** during the install, by cable or Wi-Fi.
- A **PC that can run the games**:
  - a 4-core processor from 2013 or later (Intel Haswell or AMD Excavator and newer)
  - 8 GB of memory (16 GB for PS5 games)
  - a graphics card with Vulkan 1.3 (AMD, NVIDIA or Intel)
  - a 64 GB disk

> [!WARNING]
> **Installing erases the disk you pick.** Copy anything you want to keep first. To keep
> Windows, install AzrakOS on a second disk.

## Install

1. **Download** [the installer](https://github.com/AzrakHQ/azrak-os/releases/latest/download/azrak-os-x86_64.iso).
2. **Put it on the USB stick** with [balenaEtcher](https://etcher.balena.io): choose the file, the
   USB stick, then **Flash**.
3. **Start the PC from the USB stick.** Plug it in, turn the PC on and press the boot menu key
   while it starts (usually **F12**, **F11**, **F8** or **Esc**), then pick the USB stick.
4. **Answer the installer's questions.** Click each item that's marked, then **Done**:
   - **Installation Destination:** the disk to install on. Leave **Encrypt my data** off.
   - **User Creation:** your name and a password.
   - **Network & Host Name:** your Wi-Fi, if there's no cable.

   Then click **Begin Installation**. It downloads the system (about 7 GB), which takes from
   15 minutes to an hour depending on your internet. The installer says "Fedora": that's
   normal, AzrakOS is built on it.
5. **Click Reboot System and remove the USB stick.** Stay at the PC: if a blue screen appears,
   see [The blue "MOK management" screen](#the-blue-mok-management-screen) below.

That's it. The PC now starts straight into Azrak Launcher. It picks the right version for NVIDIA
graphics cards by itself.

## Playing

- **Get a game:** open it in the **Library**, then **Download**, **Install** and **Play**.
- **Already have games?** Add their folder in **Settings → Game folders**.
- **Controls:** see the [list of buttons and keys](https://github.com/AzrakHQ/azrak-launcher#controls).
- **Need the desktop?** Choose **Settings → Quit**. The launcher comes back the next time the PC starts.

> Only download games you own. Downloads use BitTorrent, so other people can see your IP
> address. To hide it, turn on **Settings → Download only through a VPN**.

## Help

### The blue "MOK management" screen

It appears once after installing on PCs with Secure Boot on, and lets AzrakOS start. It waits
about 5 minutes. Use the arrow keys and Enter:

1. **Enroll MOK**, then **Continue**
2. **Yes** (it starts on No)
3. Type `universalblue` and press Enter
4. **Reboot**

**Missed it, and now the PC stops with "bad shim signature"?** Start from the USB stick again,
choose **Troubleshooting → Enroll the Secure Boot key again**, and the blue screen comes back.

### "An unknown error has occurred" while installing

Click **More info...** and take a photo of the text. Then
[tell us about it](https://github.com/AzrakHQ/azrak-os/issues/new) with that photo and your PC's
processor, graphics card and memory, and we'll help.

### Something else

[Open an issue](https://github.com/AzrakHQ/azrak-os/issues/new) and describe what you see. A
photo of the screen helps a lot.

---

<sub>AzrakOS is [Bazzite](https://bazzite.gg), a gaming Linux built on Fedora, with Azrak Launcher
built in. Want to know how it's made, or help build it? See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).</sub>
