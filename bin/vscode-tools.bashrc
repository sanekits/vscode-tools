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

codew() {
    code -w -
}


