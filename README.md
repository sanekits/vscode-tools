# vscode-tools

Misc. helpers for use with VSCode

### `vscode-remote-whacker.sh`
When running on a remote host, the `vscode-server` back end often gets confused and must
be restarted. *(e.g. using `Ctrl+Shift+P` - `Remote-SSH: Kill Vs Code Server on Host`)*,
but often that's a real problem of its own -- particularly if you have multiple workspaces
open on the remote and don't want to lose state.

`vscode-remote-whacker.sh` can solve this: if run on the remote host, it resets the state
of the `~/.vscode-server/` tree so that a "Reload Window" operation will load from a
fresh context.

- Choice of `--rebuild`, `--kill`, or both.
- Option to run from client machine, e.g. `vscode-remote-whacker.sh --server my-server --rebuild` *(NOTE: if you don't use this option, the expectation is that you will run the script on the **remote** server manually)*

## Setup

Download and install the self-extracting setup script:
```
curl -L https://github.com/sanekits/vscode-tools/releases/download/0.2.0/vscode-tools-setup-0.2.0.sh \
    -o ~/tmp$$.sh && bash ~/tmp$$.sh && rm ~/tmp$$.sh && exec bash
```

Or **if** [shellkit-pm](https://github.com/sanekits/shellkit-pm) is installed:

    shpm install vscode-tools

##
