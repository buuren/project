# -*- coding: utf-8 -*-
"""Configuration file for sniffer."""
# pylint: disable=superfluous-parens,bad-continuation

import time
import os
import subprocess
import termstyle

from sniffer.api import select_runnable, file_validator, runnable
try:
    from pyncpync import Notifier
except ImportError:
    notify = None
else:
    notify = Notifier.notify

# you can customize the pass/fail colors like this
pass_fg_color = termstyle.green
pass_bg_color = termstyle.bg_default
fail_fg_color = termstyle.red
fail_bg_color = termstyle.bg_default


watch_paths = ['TOREPLACE/', 'tests/']


class Options:
    group = int(time.time())  # unique per run
    show_coverage = False
    rerun_args = None

    targets = [
        (('make', 'test-unit', 'DISABLE_COVERAGE=true'), "Unit Tests", True),
        (('make', 'test-all'), "Integration Tests", False),
        (('make', 'check'), "Static Analysis", True),
    ]


@select_runnable('run_targets')
@file_validator
def python_files(filename):
    return filename.endswith('.py') and not os.path.basename(filename).startswith('.')


@runnable
def run_targets(*args):
    """Run targets for Python."""
    Options.show_coverage = 'coverage' in args

    count = 0
    for count, (command, title, retry) in enumerate(Options.targets, start=1):

        success = call(command, title, retry)
        if not success:
            message = "✅ " * (count - 1) + "❌"
            show_notification(message, title)

            return False

    message = "✅ " * count
    title = "All Targets"
    show_notification(message, title)

    return True


def call(command, title, retry):
    """Run a command-line program and display the result."""
    if Options.rerun_args:
        command, title, retry = Options.rerun_args
        Options.rerun_args = None
        success = call(command, title, retry)
        if not success:
            return False

    print("")
    print("$ %s" % ' '.join(command))
    failure = subprocess.call(command)

    if failure and retry:
        Options.rerun_args = command, title, retry

    return not failure


def show_notification(message, title):
    """Show a user notification."""
    if notify and title:
        notify(message, title=title, group=Options.group)
