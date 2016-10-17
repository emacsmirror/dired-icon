#!/usr/bin/python2

from __future__ import print_function

import sys

import gio
import gtk

# If we only need to test the availability of gtk libraries, exit now.
if len(sys.argv) == 2 and sys.argv[1] == 'test':
    sys.exit(0)

for line in sys.stdin:
    # adjusted from
    # http://stackoverflow.com/questions/21944166/get-the-default-icon-for-specific-file-type-in-ubuntu-os-by-python/21947530#21947530
    icon = gio.content_type_get_icon(line.strip())
    theme = gtk.icon_theme_get_default()
    info = theme.choose_icon(icon.get_names(), -1, 0)
    if info:
        print(info.get_filename())
    else:
        print()
