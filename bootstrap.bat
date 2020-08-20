:<<"::WINDOWS_ONLY"
@echo off
:: Copyright 2020 The Pigweed Authors
::
:: Licensed under the Apache License, Version 2.0 (the "License"); you may not
:: use this file except in compliance with the License. You may obtain a copy of
:: the License at
::
::     https://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
:: WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
:: License for the specific language governing permissions and limitations under
:: the License.
::WINDOWS_ONLY
:; echo "ERROR: Attempting to run Windows .bat from a Unix/POSIX shell!"
:; echo "Instead, run the following command."
:; echo ""
:; echo "    source ./activate.sh"
:; echo ""
:<<"::WINDOWS_ONLY"

:: The bootstrap.bat must be run initially to install all required programs.
:: After that, use activate.bat to enter the environment in a shell.

:: First, activate the Pigweed development environment.
set "pw_bootstrap_script=%~dp0\third_party\pigweed\bootstrap.bat"

if not exist "%pw_bootstrap_script%" (
  echo Error: "%pw_bootstrap_script%" not found.
  echo Did you forget to initialize the git submodules?
  echo To setup the git submodules run:
  echo   git submodule init
  echo   git submodule update
  goto finish
)

call "%pw_bootstrap_script%"

:: Add user-defined initial setup here.

:finish
::WINDOWS_ONLY
