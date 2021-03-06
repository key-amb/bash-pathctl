PATHCTL_VERBOSE=""
PATHCTL_VERSION="0.9.3"

# Vars for check and test
__pathctl_changed=""
__pathctl_contains=""

_pathctl_verbose() {
  if [[ $PATHCTL_VERBOSE ]]; then
    echo "$@"
  fi
}

_pathctl_check_contain() {
  local target=$1
  __pathctl_contains=""
  case ":${PATH}:" in
    *:"${target}":*)
      __pathctl_contains="true"
      ;;
    *)
      ;;
  esac
  if [[ $__pathctl_contains ]]; then
    _pathctl_verbose "\$PATH contains '$target'"
  else
    _pathctl_verbose "\$PATH doesn't contain '$target'"
  fi
}

pathctl_show() {
  local _path
  for _path in $(echo $PATH | tr ':' ' '); do
    echo $_path
  done
}

pathctl_unshift() {
  local _path=$1
  __pathctl_changed=""
  _pathctl_check_contain $_path
  if [[ -z $__pathctl_contains ]]; then
    PATH=$_path:$PATH
    __pathctl_changed="true"
  fi
  if [[ $__pathctl_changed ]]; then
    _pathctl_verbose "unshift '$_path' to \$PATH"
  else
    _pathctl_verbose "Do nothing"
  fi
}

pathctl_unshift_f() {
  local _path=$1
  PATH=$_path:$PATH
  pathctl_uniq
}

pathctl_push() {
  local _path=$1
  __pathctl_changed=""
  _pathctl_check_contain $_path
  if [[ -z $__pathctl_contains ]]; then
    PATH=$PATH:$_path
    __pathctl_changed="true"
  fi
  if [[ $__pathctl_changed ]]; then
    _pathctl_verbose "push '$_path' to \$PATH"
  else
    _pathctl_verbose "Do nothing"
  fi
}

pathctl_push_f() {
  local _tgt=$1
  local _path
  for _p in $(echo $PATH | tr ':' ' '); do
    if [[ $_p = $_tgt ]]; then
      continue
    fi
    if [[ $_path ]]; then
      _path="$_path:$_p"
    else
      _path=$_p
    fi
  done
  PATH="$_path:$_tgt"
}

pathctl_pop() {
  PATH=${PATH%:*}
}

pathctl_shift() {
  PATH=${PATH#*:}
}

pathctl_uniq() {
  local _hash _p _path
  declare -A _hash
  for _p in $(echo $PATH | tr ':' ' '); do
    if [[ ${_hash[$_p]} ]]; then
      continue
    fi
    _hash[$_p]=1
    if [[ $_path ]]; then
      _path="$_path:$_p"
    else
      _path=$_p
    fi
  done
  PATH=$_path
}

: <<'__EOF__'

=encoding utf8

=head1 NAME

B<pathctl.bash> - Utility for PATH management

=head1 SYNOPSYS

    #!bash or zsh
    source pathctl.bash
    pathctl_show    # show each entry per line
    pathctl_push    /path/to/your-bin
    pathctl_unshift /path/to/your-bin
    pathctl_pop     # removes last entry
    pathctl_shift   # removes first entry
    pathctl_push_f    /path/to/your-bin # move to last if exists
    pathctl_unshift_f /path/to/your-bin # move to first if exists

    # remove duplicates in PATH
    pathctl_uniq

    # remove duplicates in PATH
    pathctl_uniq

    # show verbose messages
    PATHCTL_VERBOSE=1

=head1 DESCRIPTION

Add functions to manage PATH variable.

=head1 REQUIREMENTS

Bash or Zsh.

Following function uses associated array which was introduced in Bash v4:

=over 4

=item pathctl_uniq

=item pathctl_unshift_f

=back

=head1 AUTHORS

YASUTAKE Kiyoshi E<lt>yasutake.kiyoshi@gmail.comE<gt>

=head1 LICENSE

The MIT License (MIT)

Copyright (c) 2016 YASUTAKE Kiyoshi

=cut

__EOF__

