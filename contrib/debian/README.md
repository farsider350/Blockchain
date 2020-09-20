
Debian
====================
This directory contains files used to package autxd/autx-qt
for Debian-based Linux systems. If you compile autxd/autx-qt yourself, there are some useful files here.

## autx: URI support ##


autx-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install autx-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your autx-qt binary to `/usr/bin`
and the `../../share/pixmaps/autx128.png` to `/usr/share/pixmaps`

autx-qt.protocol (KDE)

