<p align="center"><img src="https://raw.githubusercontent.com/AzrakHQ/azrak-launcher/main/assets/azrak.svg" width="128" alt="Azrak"></p>

<h1 align="center">AzrakOS</h1>

<p align="center"><b>Turn a spare PC into a game console.</b><br>
It starts straight into <a href="https://github.com/AzrakHQ/azrak-launcher">Azrak Launcher</a>: pick a game with your controller and play.</p>

<p align="center"><a href="https://github.com/AzrakHQ/azrak-os/releases/latest/download/azrak-os-x86_64.iso"><b>⬇ Download AzrakOS</b></a> (1.8 GB)</p>

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

- A **USB stick** of 4 GB or more.
- **Internet** after installing, for games and updates (cable or Wi-Fi, which you can set up
  with your controller).
- A **PC that can run the games**:
  - a 4-core processor from 2013 or later (Intel Haswell or AMD Excavator and newer)
  - 8 GB of memory (16 GB for PS5 games)
  - a graphics card with Vulkan 1.3 (AMD, NVIDIA or Intel)
  - a 64 GB disk

> [!WARNING]
> **Installing erases the disk you pick.** Copy anything you want to keep first. To keep
> Windows, install AzrakOS on a second disk. Trying it from the USB stick changes nothing.

## Install

1. **Download** [AzrakOS](https://github.com/AzrakHQ/azrak-os/releases/latest/download/azrak-os-x86_64.iso)
   and **put it on the USB stick** with [balenaEtcher](https://etcher.balena.io): choose the
   file, the USB stick, then **Flash**.
2. **Start the PC from the USB stick.** Plug it in, turn the PC on and press the boot menu key
   while it starts (usually **F12**, **F11**, **F8** or **Esc**), then pick the USB stick.
   AzrakOS starts from the stick, and nothing on the PC changes.
3. **Choose Try AzrakOS or Install on this PC.** To install, pick the disk, check it, and
   wait a few minutes. Then remove the USB stick and restart.

That's it: the PC now starts straight into Azrak Launcher. With an NVIDIA graphics card, it
gets NVIDIA's driver by itself (see [the blue screen](#the-blue-mok-management-screen) below).

## Playing

- **Get a game:** open it in the **Library**, then **Download**, **Install** and **Play**.
- **Already have games?** Add their folder in **Settings → Game folders**.
- **Controls:** see the [list of buttons and keys](https://github.com/AzrakHQ/azrak-launcher#controls).
- **Wi-Fi, controllers, sound, updates, restart:** all in **Settings → System**.

> Only download games you own. Downloads use BitTorrent, so other people can see your IP
> address. To hide it, turn on **Settings → Download only through a VPN**.

## Help

### The blue "MOK management" screen

Only on PCs with an **NVIDIA** graphics card and Secure Boot on: it appears once after
restarting, so NVIDIA's driver may start. It waits about 5 minutes. A controller doesn't work
there: use a keyboard's arrow keys and Enter.

1. **Enroll MOK**, then **Continue**
2. **Yes** (it starts on No)
3. Type `universalblue` and press Enter
4. **Reboot**

Missed it? AzrakOS starts anyway, with a simpler graphics driver, and the blue screen comes back
at a later restart.

### The installer says "Installation didn't finish"

Take a photo of the screen (with its **Details** line). Then
[tell us about it](https://github.com/AzrakHQ/azrak-os/issues/new) with that photo and your PC's
processor, graphics card and memory, and we'll help.

### Something else

[Open an issue](https://github.com/AzrakHQ/azrak-os/issues/new) and describe what you see. A
photo of the screen helps a lot.

---

<sub>AzrakOS is a small Linux built on Fedora, with Azrak Launcher as the whole screen. Want to know how it's made, or help build it? See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).</sub>
