#!/bin/bash
# maks_ctags.bash - Make ctags in a bunch of places
#
eecho() {
	echo "$@" 1>&2
}
die() {
	ERR=1
	(( ERR = "${1#-}" )) > /dev/null 2>&1 && shift
	[[ "$1" == "--" ]] && shift
	eecho "$@"
	echo $ERR
}
warn() {
	eecho WARNING: "$@"
}

CTAGS=/usr/bin/ctags
[[ -x $CTAGS ]] || 
	die "Can't create tags, ctags executable not found at $CTAGS"

TAG_DIRS=(
	"$HOME/apps/lib"
	"$HOME/projects/korren.org/tt-rss/Tiny-Tiny-RSS"
)

CTAGS_OPTIONS='--exclude=\*.min.js'
CRON_SCHEDULE='*/30 * *   *   *    '

run_ctags() {
	[[ "$1" == "-q" ]] && QUIET="yes" || QUIET=""
	for TD in "${TAG_DIRS[@]}"; do
		if ! cd "$TD"; then
			warn "Failed to enter directory: $TD"
			continue
		fi
		if [[ -n "$QUIET" ]]; then
			$CTAGS -R $CTAGS_OPTIONS * > /dev/null 2>&1 ||
				warn "Ctags failed with error $? in $TD"
		else
			$CTAGS -R $CTAGS_OPTIONS * ||
				warn "Ctags failed with error $? in $TD"
		fi
	done
}
base_name() {
	/usr/bin/basename "$1" ||
		echo "${1##*/}"
}
script_run_cmd() {
	case "$0" in
		./*|../*) CMD="$PWD/$0";;
		/*) CMD="$0";;
		*) 
			CMD="$(/usr/bin/which "$0")" > /dev/null 2>&1 ||
				CMD="$PWD/$0"
			;;
	esac
	[[ -f "$CMD" ]] || return 1
	[[ -x "$CMD" ]] || CMD="$SHELL $CMD"
	echo "$CMD"
	return 0
}
config_cron() {
	CRONTAB=/usr/bin/crontab
	[[ -x $CRONTAB ]] || die "crontab exectable not found at $CRONTAB"
	GREP="/bin/grep"
	[[ -x $GREP ]] || die "grep exectable not found at $GREP"
	CMD="$(script_run_cmd)" || die "Cannot find script executable file"
	CMD_BASE="$(base_name "$CMD")"
	(
		$CRONTAB -l | $GREP -v "/$CMD_BASE "
		echo "$CRON_SCHEDULE" "$CMD" run_ctags_cron
	) | $CRONTAB -
}
usage() {
	echo Usage: $(base_name "$0") "(run_ctags|config_cron)"
	exit 0
}

case "$1" in
	run_ctags)
		run_ctags
		;;
	run_ctags_cron)
		run_ctags -q
		;;
	config_cron)
		config_cron
		;;
	*)
		usage
		;;
esac
exit 0


