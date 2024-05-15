#!/usr/bin/env bash
echo "Executing kasm_post_run_root.sh"

# https://www.reddit.com/r/kasmweb/comments/1cabdwk/question_kasm_users_as_os_users/
# https://github.com/kasmtech/workspaces-issues/issues/461
set -ex
sed -i "s/kasm-user/$KASM_USER/g" /etc/passwd
