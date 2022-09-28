import sys
import os

# add building.py path
sys.path = sys.path + [os.path.join('..', 'tools')]
from building import *

LaunchMenuconfig()

cwd  = GetCurrentDir()

def BuildDir(dir):
    if os.path.isdir(dir):
        list = os.listdir(dir)

        for item in list:
            path = os.path.join(dir, item)
            if os.path.isfile(os.path.join(path, 'SConscript')):
                BuildApplication(item, path + '/SConscript', usr_root = '.')

AddOption('--app',
          dest = 'make-application',
          type = 'string',
          default = None,
          help = 'make application')

AddOption('--dir',
            dest = 'make-in-directory',
            type = 'string',
            default = None,
            help = 'make in directory')

AddOption('--sdk-libc',
    dest='sdk-libc',
    action='store_true',
    default=False,
    help='build with sdk libc')

if GetOption('sdk-libc'):
    AddDepend('SDK_LIBC')

if GetOption('make-application'):
    item = GetOption('make-application')

    path = os.path.join(cwd, 'apps', item)
    if os.path.isfile(os.path.join(path, 'SConscript')):
        BuildApplication(item, path + '/SConscript', usr_root = '.')
elif GetOption('make-in-directory'):
    dir = GetOption('make-in-directory')
    BuildDir(os.path.join(cwd, dir))
else:
    BuildDir(os.path.join(cwd, 'apps'))
    # BuildDir(os.path.join(cwd, 'testcases'))
    BuildDir(os.path.join(cwd, 'services'))
