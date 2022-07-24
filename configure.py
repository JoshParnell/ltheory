#!/usr/bin/env python
import os
import sys
import shutil
import subprocess

try:
    os.mkdir('build')
except Exception as e:
    pass

if len(sys.argv) > 1:
    if sys.argv[1] == 'build':
        subprocess.call(['cmake', '--build', './build', '--config', 'RelWithDebInfo'])
    elif sys.argv[1] == 'clean':
        shutil.rmtree('bin', ignore_errors = True)
        shutil.rmtree('build', ignore_errors = True)
    elif sys.argv[1] == 'run':
        subprocess.call(['bin/lt64.exe'] + sys.argv[2:])
else:
    subprocess.call(['cmake', '-S', './', '-B', './build'])
