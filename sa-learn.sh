#!/bin/sh
find "$HOME"/Maildir/.Junk/cur/ -type f -print0 | xargs -0r sa-learn --spam >> /dev/null 2>&1
find "$HOME"/Maildir/.Junk/new/ -type f -print0 | xargs -0r sa-learn --spam >> /dev/null 2>&1
find "$HOME"/Maildir/cur/ -type f -print0 | xargs -0r sa-learn --ham >> /dev/null 2>&1
find "$HOME"/Maildir/new/ -type f -print0 | xargs -0r sa-learn --ham >> /dev/null 2>&1
