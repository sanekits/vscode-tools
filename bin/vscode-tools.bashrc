# vscode-tools.bashrc - shell init file for vscode-tools sourced from ~/.bashrc

vscode-tools-semaphore() {
    [[ 1 -eq  1 ]]
}

which code &>/dev/null || {
    which code-server &>/dev/null && {
        code() {
            code-server "$@"
        }
    }
}

shell_is_wsl() {
    uname -a | grep -q WSL2 || { echo false; return; }
    echo true
}
export IsWsl=${IsWsl:-$(shell_is_wsl)}

if $IsWsl; then
    codew() {
        # From WSL, invoking a Windows-side vscode command
        cmd.exe /C code "$@"
    }
else
    codew() { echo "ERROR: codew only works in WSL" >&2; false; }
fi
