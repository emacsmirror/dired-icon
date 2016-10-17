# dired-icon-mode

This package provides a minor mode `dired-icon-mode` to display an icon for each file type in dired
buffers. Currently systems which run GTK 3, such as GNU/Linux, GNU/kFreeBSD and FreeBSD, are fully
supported
(pre-requisition: [PyGObject for Python 3](https://wiki.gnome.org/action/show/Projects/PyGObject)).
On other systems, currently only directory icons are displayed.

## Screenshot

![](./screenshot.png)

## Installation

### Manual

Download this package and add the following to your `~/.emacs` or `~/.emacs.d/init.el`:

    (add-to-list 'load-path "~/path/to/dired-icon")
    (load "dired-icon.el")

## Configuration

To display the icons in a dired buffer, simply call M-x `dired-icon-mode` inside a dired buffer. To
always display the file icons in dired buffers, add the following to your `~/.emacs` or
`~/.emacs.d/init.el`:

    (add-hook 'dired-mode-hook 'dired-icon-mode)
