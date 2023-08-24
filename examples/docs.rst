=============================
Give Pigweed a Whirl Workshop
=============================

.. toctree::
  :titlesonly:
  :glob:

  */docs


Intro
-----

Welcome! In this workshop we will introduce some of the more compelling
Pigweed features that make embedded product development easier.

You can find each section linked above numbering ``00`` to ``05``.

1. Host Machine Setup
---------------------

Python and Git are the only prerequisites for getting started with
Pigweed. Download and install if you don’t already have them available.

**Windows**

1. Use the Windows installers for Python and Git from:

   -  https://www.python.org/downloads/windows/
   -  https://git-scm.com/download/win

   Make sure to add them to your system path during installation.

2. Enable long file paths enabled on Windows. This can be done using
   ``regedit`` or by running this as an administrator:

   .. code:: bat

      REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1

**Linux**

If you are using a `Teensy 3.x or
4.x <https://www.pjrc.com/teensy/td_download.html>`__ board for the
first time on a Linux machine you will need to install the udev rules
from: https://www.pjrc.com/teensy/49-teensy.rules

**Mac**

Python and Git should be installed by default on Mac OS.

2. Repo Setup
-------------

Open a Terminal (``cmd.exe`` on Windows) and clone this repo with:

.. code:: sh

   git clone --recursive https://pigweed.googlesource.com/pigweed/sample_project

\**\* note No worries if you missed ``--recursive``! Run this to pull
``third_party/nanopb`` and ``third_party/pigweed``.

.. code:: sh

   git submodule update --init

If you want to pull new changes run:

.. code:: sh

   git pull --recurse-submodules


3. Run ``bootstrap``
--------------------


After cloning the build tools can be installed with the ``bootstrap``
scripts. This is only required after the initial clone or updating
Pigweed.

**Windows**

.. code:: sh

   bootstrap.bat

**Linux & Mac**

.. code:: sh

   . ./bootstrap.sh

After the initial bootstrap, use the ``activate`` scripts to setup your
shell for development.

**Windows**

.. code:: sh

   activate.bat

**Linux & Mac**

.. code:: sh

   . ./activate.sh

4. Install Teensyduino Core
---------------------------

To build for Arduino boards you must install a core. At this time only
the `Teensyduino core <https://www.pjrc.com/teensy/td_download.html>`__
is supported. Check the Pigweed `Arduino target
docs <https://pigweed.dev/targets/arduino/target_docs.html>`__ for more
info.

All Arduino cores should be installed into
``third_party/pigweed/third_party/arduino/cores/``

Run this to install the Teensy core:

.. code:: sh

   arduino_builder install-core --prefix third_party/pigweed/third_party/arduino/cores/ --core-name teensy

5. Build!
---------

STM32F429i Discovery Board
~~~~~~~~~~~~~~~~~~~~~~~~~~

To build for the ``stm32f429i_disc1`` board run:

.. code:: sh

   gn gen out

Then start the compile with:

.. code:: sh

   ninja -C out

Teensy 3.x/4.x
~~~~~~~~~~~~~~

To build for a Teensy 4.0 board run the following.

**Windows**

Run ``gn args out`` which will open a text editor. Paste in the
following, save and close the editor.

.. code:: sh

   pw_arduino_build_CORE_PATH="//third_party/pigweed/third_party/arduino/cores"
   pw_arduino_build_CORE_NAME="teensy"
   pw_arduino_build_PACKAGE_NAME = "teensy/avr"
   pw_arduino_build_BOARD="teensy40"
   pw_arduino_build_MENU_OPTIONS=["menu.usb.serial", "menu.keys.en-us"]
   pw_arduino_use_test_server=false

The ``arduino_board`` arg can be set to any of these:

-  ``"teensy31"`` - Teensy 3.2 / 3.1
-  ``"teensy35"`` - Teensy 3.5
-  ``"teensy36"`` - Teensy 3.6
-  ``"teensy40"`` - Teensy 4.0
-  ``"teensy41"`` - Teensy 4.1

Args need only be set once per ``out`` directory. After setting them
``gn gen out`` alone can be used. Once ``gn`` is done, compile
everything with:

.. code:: sh

   ninja -C out

**Linux & Mac**

You can use ``gn args out`` as shown above or include the args on the
command line:

.. code:: sh

   gn gen out --args='
     pw_arduino_build_CORE_PATH="//third_party/pigweed/third_party/arduino/cores"
     pw_arduino_build_CORE_NAME="teensy"
     pw_arduino_build_PACKAGE_NAME = "teensy/avr"
     pw_arduino_build_BOARD="teensy40"
     pw_arduino_build_MENU_OPTIONS=["menu.usb.serial", "menu.keys.en-us"]
     pw_arduino_use_test_server=false
   '

After ``gn`` is done, compile everything with:

.. code:: sh

   ninja -C out

GN and Ninja Reference
----------------------


Basics
~~~~~~

-  Create a build directory named ``out``.

   .. code:: sh

      gn gen out

-  Set build options with ``gn args``.

   .. code:: sh

      gn args out

-  Compile with

   .. code:: sh

      ninja -C out

-  Clean by deleting the out folder or running:

   .. code:: sh

      ninja -C out -t clean

Inspecting
~~~~~~~~~~

-  List buildable targets.

   .. code:: sh

      gn ls out

-  Inspect a target to see it’s dependencies. E.g. ``cflags``,
   ``ldflags``, etc.

   \**\* promo Target names start with a ``//`` to denote the root level
   of the project. The format in this example is
   ``//{FOLDER1}/{$FOLDER2}:{BUILD.gn_TARGET_NAME}({TOOLCHAIN})`` \**\*

   **Teensy**

   .. code:: sh

      gn desc out "//examples/01-blinky:blinky(//targets/arduino:arduino_debug)" --tree

   **stm32f429i_disc1**

   .. code:: sh

      gn desc out "//examples/01-blinky:blinky(//targets/stm32f429i_disc1:stm32f429i_disc1_debug)" --tree

   **Host**

   .. code:: sh

      gn desc out "//examples/01-blinky:blinky(//targets/host:host_debug)" --tree

ccache
~~~~~~

Pigweed can make use of ``ccache`` if you have it available on your
system ``PATH``. This will speed up recompiling previously compiled
artifacts dramatically. Useful if you regularly clean your out
directory. Set this build arg to enable:

.. code:: text

   pw_command_launcher="ccache"

Editor Integration
~~~~~~~~~~~~~~~~~~

Use ``--export-compile-commands`` to create the
``out/compile_commands.json`` file for use with lsp servers like
``clangd``.

.. code:: sh

   gn gen out --export-compile-commands

``clangd`` can be integrating with various text editor extensions such
as:

-  `VSCode
   clangd <https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd>`__
-  `emacs lsp-mode <https://github.com/emacs-lsp/lsp-mode>`__
-  `vim lsp <https://github.com/prabirshrestha/vim-lsp>`__

Further Reading
~~~~~~~~~~~~~~~

-  `GN Quick Start
   Guide <https://gn.googlesource.com/gn/+/main/docs/quick_start.md>`__
-  `GN
   Reference <https://gn.googlesource.com/gn/+/main/docs/reference.md>`__
