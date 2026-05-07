#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "./xmir_base/xmir_init.py" ]; then
	echo "ERROR: XMiR: project files not found near run.sh!"
	exit 1
fi

if [ "$(uname -s)" = "Darwin" ]; then
	if command -v brew >/dev/null 2>&1; then
		BREW_LIBSSH2_PREFIX="$(brew --prefix libssh2 2>/dev/null || true)"
		if [ -n "$BREW_LIBSSH2_PREFIX" ] && [ -d "$BREW_LIBSSH2_PREFIX/lib" ]; then
			export DYLD_FALLBACK_LIBRARY_PATH="$BREW_LIBSSH2_PREFIX/lib${DYLD_FALLBACK_LIBRARY_PATH:+:$DYLD_FALLBACK_LIBRARY_PATH}"
		fi
	fi
fi

PY3_PATH=`which python3`
if [ ! -e "$PY3_PATH" ]; then
	echo "ERROR: XMiR: python3 binary not found!"
	exit 1
fi

if [ ! -e "$VIRTUAL_ENV" ] || ! type deactivate &> /dev/null ; then
	python3 -m venv venv
	if [ ! -e "./venv/bin/activate" ]; then
		echo "ERROR: XMiR: python3 venv not initialized!"
		exit 1
	fi
	source ./venv/bin/activate
	PY3_PATH=`which python3`
	if [ ! -e "$PY3_PATH" ]; then
		echo "ERROR: XMiR: python3 venv binary not found!"
		deactivate
		exit 1
	fi
fi
if [ ! -e "$VIRTUAL_ENV" ] || ! type deactivate &> /dev/null ; then
	echo "ERROR: XMiR: python3 venv cannot activate!"
	exit 1
fi

SSH2_PKG=`find ./venv -type d -wholename '*/site-packages/ssh2_python*' | wc -l | tr -d ' '`
if [ "$SSH2_PKG" = "0" ]; then
	# install
	python3 -m pip install -r requirements.txt
	# check
	SSH2_PKG=`find ./venv -type d -wholename '*/site-packages/ssh2_python*' | wc -l | tr -d ' '`
	if [ "$SSH2_PKG" = "0" ]; then
		echo "ERROR: XMiR: python3 package 'ssh2-python' not installed!"
		deactivate
		exit 1
	fi
fi

export PYTHONUNBUFFERED=TRUE

if [ "$1" = "" ]; then
	python3 menu.py
else
	python3 "$@"
fi

#deactivate
