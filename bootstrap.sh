# Copyright 2020 The Pigweed Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# This script must be sourced, not executed.
#
# Create a new environment:
#
#   source bootstrap.sh
#
# Activate an existing environment:
#
#   source activate.sh

_bootstrap_abspath () {
  python -c "import os.path; print(os.path.abspath('$@'))"
}

# Users are not expected to set PW_CHECKOUT_ROOT, it's only used because it
# seems to be impossible to reliably determine the path to a sourced file in
# dash when sourced from a dash script instead of a dash interactive prompt.
# To reinforce that users should not be using PW_CHECKOUT_ROOT, it is cleared
# here after it is used, and other pw tools will complain if they see that
# variable set.
# TODO(mohrr) find out a way to do this without PW_CHECKOUT_ROOT.
if test -n "$PW_CHECKOUT_ROOT"; then
  _BOOTSTRAP_PATH="$(_bootstrap_abspath "$PW_CHECKOUT_ROOT/bootstrap.sh")"
  unset PW_CHECKOUT_ROOT
# Shell: bash.
elif test -n "$BASH"; then
  _BOOTSTRAP_PATH="$(_bootstrap_abspath "$BASH_SOURCE")"
# Shell: zsh.
elif test -n "$ZSH_NAME"; then
  _BOOTSTRAP_PATH="$(_bootstrap_abspath "${(%):-%N}")"
# Shell: dash.
elif test ${0##*/} = dash; then
  _BOOTSTRAP_PATH="$(_bootstrap_abspath \
    "$(lsof -p $$ -Fn0 | tail -1 | sed 's#^[^/]*##;')")"
# If everything else fails, try $0. It could work.
else
  _BOOTSTRAP_PATH="$(_bootstrap_abspath "$0")"
fi

# Check if this file is being executed or sourced.
_pw_sourced=0
if [ -n "$SWARMING_BOT_ID" ]; then
  # If set we're running on swarming and don't need this check.
  _pw_sourced=1
elif [ -n "$ZSH_EVAL_CONTEXT" ]; then
  case $ZSH_EVAL_CONTEXT in *:file) _pw_sourced=1;; esac
elif [ -n "$KSH_VERSION" ]; then
  [ "$(cd $(dirname -- $0) && pwd -P)/$(basename -- $0)" != \
    "$(cd $(dirname -- ${.sh.file}) && pwd -P)/$(basename -- ${.sh.file})" ] \
    && _pw_sourced=1
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && _pw_sourced=1
else  # All other shells: examine $0 for known shell binary filenames
  # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|dash) _pw_sourced=1;; esac
fi

# Downstream projects need to set something other than PW_ROOT here, like
# YOUR_PROJECT_ROOT. Please also set PW_PROJECT_ROOT and PW_ROOT before
# invoking pw_bootstrap or pw_activate.
######### BEGIN PROJECT-SPECIFIC CODE #########
SAMPLE_PROJECT_ROOT="$(_bootstrap_abspath "$(dirname "$_BOOTSTRAP_PATH")")"
export SAMPLE_PROJECT_ROOT
PW_PROJECT_ROOT="$SAMPLE_PROJECT_ROOT"
PW_ROOT="$SAMPLE_PROJECT_ROOT/third_party/pigweed"

# Set your project's banner and color.
export PW_BRANDING_BANNER="$SAMPLE_PROJECT_ROOT/banner.txt"
export PW_BRANDING_BANNER_COLOR=magenta

sample_project_banner() {
  cat "$PW_BRANDING_BANNER"
  echo
}

PW_BANNER_FUNC="sample_project_banner"
########## END PROJECT-SPECIFIC CODE ##########
export PW_BANNER_FUNC
export PW_PROJECT_ROOT
export PW_ROOT

_util_sh="$PW_ROOT/pw_env_setup/util.sh"

# Double-check that the Pigweed submodule has been checked out.
if [ ! -e "$_util_sh" ]; then
  echo "Error: $_util_sh not found."
  echo "Did you forget to initialize the git submodules?"
  echo "To setup the git submodules run:"
  echo "  git submodule update --init"
  return
fi

. "$_util_sh"

pw_deactivate
pw_eval_sourced "$_pw_sourced"
pw_check_root "$PW_ROOT"
_PW_ACTUAL_ENVIRONMENT_ROOT="$(pw_get_env_root)"
export _PW_ACTUAL_ENVIRONMENT_ROOT
SETUP_SH="$_PW_ACTUAL_ENVIRONMENT_ROOT/activate.sh"

# Run full bootstrap when invoked as bootstrap, or env file is missing/empty.
if [ "$(basename "$_BOOTSTRAP_PATH")" = "bootstrap.sh" ] || \
  [ ! -f "$SETUP_SH" ] || \
  [ ! -s "$SETUP_SH" ]; then
# This is where pw_bootstrap is called. Most small projects will include
# --use-pigweed-defaults.
######### BEGIN PROJECT-SPECIFIC CODE #########
  pw_bootstrap --shell-file "$SETUP_SH" --install-dir "$_PW_ACTUAL_ENVIRONMENT_ROOT" --use-pigweed-defaults --virtualenv-gn-target "$PW_PROJECT_ROOT#:python.install" --virtualenv-gn-out-dir "$PW_PROJECT_ROOT/out"
########## END PROJECT-SPECIFIC CODE ##########
  pw_finalize bootstrap "$SETUP_SH"
else
  pw_activate
  pw_finalize activate "$SETUP_SH"
fi

# This is where any additional checks about the environment should go.
######### BEGIN PROJECT-SPECIFIC CODE #########
########## END PROJECT-SPECIFIC CODE ##########

unset _pw_sourced
unset _BOOTSTRAP_PATH
unset SETUP_SH
unset _bootstrap_abspath
unset _util_sh

pw_cleanup
