##!/usr/bin/env sh
## DancingQuanta/shell-config - https://github.com/DancingQuanta/shell-config
## ssh.sh
##
## SSH shell settings.
## See also: $HOME/.ssh
## From https://github.com/alphabetum/dotfiles/blob/master/home/.shared_rc.d/ssh.sh

# ssh_generate_config
#
# Usage:
#   ssh_generate_config [-h | --help]
#
# Options:
#   -h --help  Display help and usage information.
#
# Description:
#   Combine the contents of `.ssh/config.d` and `.ssh/default.sshconfig` into
#   a `.ssh/config` file that is then used as the config file for `ssh`.
#
#   This function can be called directly in order to manually generate a new
#   `.ssh/config` file, since commands other than `ssh` will use the
#   generated configuration.
#
# NOTE: disable shellcheck SC2120 "ssh_generate_config references arguments,
# but none are ever passed," which appears to be triggered by a call of this
# function later in the file.
# shellcheck disable=SC2120
ssh_generate_config() {
  if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]
  then
    cat <<HEREDOC
Usage:
  ssh_generate_config [-h|--help]

Options:
  -h --help  Display help and usage information.

Description:
  Combine the contents of \`.ssh/config.d\` and \`.ssh/default.sshconfig\` into
  a \`.ssh/config\` file that is then used as the config file for \`ssh\`.

  This function can be called directly in order to manually generate a new
  \`.ssh/config\` file, since commands other than \`ssh\` will use the
  generated configuration.
HEREDOC
    return 0
  fi

  cat <<HEREDOC > ~/.ssh/config
###############################################################################
# .ssh/config
#
# This is a generated ssh config file created by \`ssh_generate_config\`,
# which is a shell function.
#
# WARNING: DO NOT EDIT THIS FILE DIRECTLY. IT WILL BE OVERWRITTEN.
#
# More information: ~/.shared_rc.d/ssh.sh
###############################################################################

HEREDOC
  cat ~/.ssh/config.d/* >> ~/.ssh/config
  cat ~/.ssh/default.sshconfig >> ~/.ssh/config
}

# ssh_generate_key
#
# Usage:
#   ssh_generate_key <user@host.tld>
#   ssh_generate_key -h | --help
#
# Options:
#   -h --help  Display help and usage information.
#
# Description:
#   Generates an ssh key. The generated file uses the following format:
#     <local.host>_<remote_user>@<remote host>_id_rsa
#     <local.host>_<remote_user>@<remote.host>_id_rsa
#
#   More information: http://askubuntu.com/a/423297
ssh_generate_key() {
  if [[ -z "${1:-}" ]]
  then
    printf "Usage: ssh_generate_key <user@host.tld>\n"
    return 1
  elif [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]
  then
    cat <<HEREDOC
Usage:
  ssh_generate_key <user@host.tld>
  ssh_generate_key -h | --help

Options:
  -h --help  Display help and usage information.

Description:
  Generates an ssh key. The generated file uses the following format:
    <local.host>_<remote_user>@<remote host>_id_rsa
    <local.host>_<remote_user>@<remote.host>_id_rsa

  More information: http://askubuntu.com/a/423297
HEREDOC
    return 0
  fi

  local _local_host
  local _username
  local _remote_host

  _local_host="$(hostname)"
  _remote_host="$(echo "${1}" | awk -F '@' '{print $2}')"
  if [[ -z "${_remote_host:-}" ]]
  then
    _remote_host="$(echo "${1}" | awk -F '@' '{print $1}')"
    ssh-keygen \
      -t rsa \
      -b 4096 \
      -C "${_remote_host}_id_rsa" \
      -f "${HOME}/.ssh/${_local_host}_${_remote_host}_id_rsa"
  else
    _username="$(echo "${1}" | awk -F '@' '{print $1}')"
    ssh-keygen \
      -t rsa \
      -b 4096 \
      -C "${_username}@${_remote_host}_id_rsa" \
      -f "${HOME}/.ssh/${_local_host}_${_username}@${_remote_host}_id_rsa"
  fi
}

# ssh_keys
#
# Usage:
#   ssh_keys [<key.pub>]
#
# Description:
#   Print the filename of each public key file in the ~/.ssh directory. If an
#   argument is provided, the public key with a filename matching the argument
#   is printed.
ssh_keys() {
  if [[ "${1:-}" =~ '^-h|--help$' ]]
  then
    cat <<HEREDOC
Usage:
  ssh_keys [<key.pub>]

Description:
  Print the filename of each public key file in the ~/.ssh directory. If an
  argument is provided, the public key with a filename matching the argument
  is printed.
HEREDOC
    return 0
  fi

  local _public_key="${1:-}"

  if [[ -n "${_public_key}" ]]
  then
    local _public_key_path="${HOME}/.ssh/${_public_key}"

    if [[ -e "${_public_key_path}" ]]
    then
      cat "${_public_key_path}"
    else
      printf "Key not found: %s\n" "${_public_key}"
      return 1
    fi
  else
    for _file_path in "${HOME}/.ssh"/*
    do
      if [[ "${_file_path}" =~ pub$ ]]
      then
        printf "%s\n" "$(basename ${_file_path})"
      fi
    done
  fi
}

# Wrap `ssh` in a function that first runs `ssh_generate_config` before
# calling `ssh`.
#
# More information: http://superuser.com/q/247564
_SSH_CMD="$(which ssh)"
ssh() {
  # Disable ShellCheck SC2119: "Use foo "$@" if function's $1 should mean
  # script's $1." The arguments referenced by `ssh_generate_config` are
  # for displaying help and intended to specified by operators calling the
  # function manually.
  #
  # shellcheck disable=SC2119
  ssh_generate_config
  "$_SSH_CMD" "$@"
}
