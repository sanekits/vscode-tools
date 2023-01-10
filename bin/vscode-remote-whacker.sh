#!/bin/bash
# vscode-remote-whacker.sh
#  Run this on a remote vscode when vscode spins endlessly trying to reconnect.
#
#  In that situation (assuming your ssh configuration and proxy settings are correct)
# this script can often help by rebuilding your ~/.vscode-server tree without removing the
# persistent state data.
#
# Then if you do a Reload Window in vscode, it can usually start fresh quickly.
#

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

do_whack() {
    [[ -d ${HOME}/.vscode-server ]] || {
        echo "Sorry, no ~/.vscode-server/ dir exists.  Nothing I can do to help." >&2
        false; return;
    }
    for dn in {001..100}; do
        [[ -d ${HOME}/.vscold-${dn} ]] \
            && continue
        mv ${HOME}/.vscode-server ${HOME}/.vscold-${dn} || {
            echo "ERROR: failed moving ~/.vscode-server to ~/.vscold-${dn}" >&2
            false; return
        }
        mkdir ${HOME}/.vscode-server || die 109
        cd ${HOME}/.vscode-server || die 110
        echo "Rebuilding ~/.vscode-server/data/ and ../extensions:"
        rsync -a --info=progress2 ${HOME}/.vscold-${dn}/data ${HOME}/.vscold-${dn}/extensions ./  || die 112
        {
            echo "Done. Reload your troubled vscode window(s) now."
            echo "Clean up ~/.vscold-* when no active VSCode instances"
            echo "are in use.  Here's what you have on $(hostname):"
            ( cd ; ls -aldF .vscold-* .vscode-server ) | sed -e 's/^/   /'
            echo "   ( You can clean up with 'rm -rf ~/.vscold-*' )"
        } >&2
        return
    done
    echo "You have too many freakin' ~/.vscold-* directories.  Please clean up and try again." >&2
    false; return
}

main() {
    which rsync &>/dev/null || die "rsync must be installed on $(hostname)"
    do_whack

}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
