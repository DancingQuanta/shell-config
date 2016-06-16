# set editor

if [[ $OSTYPE == "linux" ]]; then
  if which vim &> /dev/null; then
    export EDITOR="vim"
  elif which vi &> /dev/null; then
    export EDITOR="vi"
  elif which nano &> /dev/null; then
    export EDITOR="nano"
  fi
elif [[ $OSTYPE == "cygwin" ]]; then
  NOTEPAD="C:/PROGRA~2/Notepad++/notepad++.exe"
  CNOTEPAD=$(cygpath -u -a $NOTEPAD)
  if [[ -a $CNOTEPAD ]]; then
    export EDITOR="$NOTEPAD"' -multiInst -nosession $(cygpath -w "$@")'
    # ed () {
      # $NOTEPAD $(cygpath -w -a $@) &
    # }
  elif which vi &> /dev/null; then
    export EDITOR="vi"
  fi
fi

ed () {
  if test "$@" == ""
  then
      $(eval $EDITOR .) &
  else
      $(eval $EDITOR $@) &
  fi
}
