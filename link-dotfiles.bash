#!/bin/bash
# link-dotfiles.bash - This script creates symlinks in $HOME
# to the dotfiles that reside in ~/autosync/dotfiles

DFDIR="autosync/dotfiles"
DFILES="asciidoc bash_profile bashrc ports profile vim vimrc gnome2/nautilus-scripts purple/logs"

for df in $DFILES; do
	[ -e "$HOME/$DFDIR/$df" ] || continue
	[ -e "$HOME/.$df" ] &&
		mv "$HOME/.$df" "$(mktemp -u "$HOME/.$df.XXXXX")"
	ln -s "$HOME/$DFDIR/$df" "$HOME/.$df"
	echo "Linked $df"
done

