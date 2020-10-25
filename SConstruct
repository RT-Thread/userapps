import sys
import os

# add building.py path
sys.path = sys.path + [os.path.join('..', 'tools')]
from building import *

cwd  = GetCurrentDir()
list = os.listdir(os.path.join(cwd, 'apps'))

AddOption('--app',
          dest = 'make-application',
          type = 'string',
          default = None,
          help = 'make application')

app = None
if GetOption('make-application'):
    app = GetOption('make-application')

if app:
    item = app

    path = os.path.join(cwd, 'apps', item)
    if os.path.isfile(os.path.join(path, 'SConscript')):
        BuildApplication(item, path + '/SConscript', usr_root = '.')
else:
    for item in list:
        path = os.path.join(cwd, 'apps', item)
        if os.path.isfile(os.path.join(path, 'SConscript')):
            BuildApplication(item, path + '/SConscript', usr_root = '.')
