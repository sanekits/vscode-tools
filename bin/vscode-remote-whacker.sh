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

do_rebuild() {
    which rsync &>/dev/null || {
        echo "ERROR:rsync must be installed on $(hostname)" >&2
        false; return;
    }
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

fwd_remote() {
    # Copy ourselves to remote host and run there.
    local server="$1"
    shift

    local fwd_args="$@"
    [[ -n $server ]] || die "No server argument provided"
    local script_name_on_remote=".vscrmwhack-$$.sh"

    which ssh &>/dev/null \
        || die "Can't find ssh on the PATH"
    echo "Relaunching $(basename ${scriptName}) on host ${server}:" >&2
    ssh "$server" true \
        || die "ssh $server true --> command fails"
    local out="$(ssh $server true 2>&1 )"
    [[ -n "$out" ]] \
        && die "ssh $server --> round-trip terminal check fails.  Ensure that ssh does not output any text for command \"ssh $server true\".  This may involve changes to your shell initialization on \"$server\" to suppress commands which emit text on non-interactive shells -- which is important for a variety of reasons."

    # Do the copy:
    ssh "$server" "cat > ./${script_name_on_remote}" < "$scriptName" \
        || die "Failed copying $scriptName to remote \"$server\""

    ssh "$server" "chmod +x ./${script_name_on_remote}"

    # Invoke the whacker:
    ssh "$server" "././${script_name_on_remote} ${fwd_args[@]}" \
        || exit 1

    # Clean up:
    ssh "$server" "rm -f ./${script_name_on_remote}"

}

do_kill() {
    kill -9 $(ps ux | grep vscode-server | awk '{print $2}') # Kill all vscode-server processes
}

main() {
    [[ $# -eq 0 ]] && { $scriptName --help; exit; }
    while [[ -n $1 ]]; do
        case $1 in
            --help|-h)
                echo "Whacks the state of VSCode ssh-remote server to solve stability or connection problems."
                echo ""
                echo "NOTE: run this on the remote host, not on your local VSCode UI installation.  (If "
                echo " that's inconvenient, use the --server option and the script will copy itself to"
                echo " the remote host and forward remaining args there.)"
                echo
                echo "Usage:"
                echo "   $(basename $scriptName) [--server hostname] --kill|-k  --rebuild|-r"
                echo
                echo "...where:"
                echo "   --rebuild: Reset server tree state to force update on window reload."
                echo "   --kill:    Terminate all vscode-server processes."
                echo "   --server [<user>@host]: Forward command to remote host."
                echo "              (--server should precede other options if used)"
                exit 1;;

            --kill|-k)
                shift
                do_kill
                continue
                ;;
            --rebuild|--whack|-r)
                shift
                do_rebuild
                continue
                ;;
            --server|-s)
                shift
                fwd_remote "$@";
                exit ;;
            *) die "Unknown argument: $1"
        esac
        shift
    done
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
