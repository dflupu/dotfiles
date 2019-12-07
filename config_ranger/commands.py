# -*- coding: utf-8 -*-
# Copyright (C) 2009-2013  Roman Zimbelmann <hut@lavabit.com>
# This configuration file is licensed under the same terms as ranger.
# ===================================================================
# This file contains ranger's commands.
# It's all in python; lines beginning with # are comments.
#
# Note that additional commands are automatically generated from the methods
# of the class ranger.core.actions.Actions.
#
# You can customize commands in the file ~/.config/ranger/commands.py.
# It has the same syntax as this file.  In fact, you can just copy this
# file there with `ranger --copy-config=commands' and make your modifications.
# But make sure you update your configs when you update ranger.
#
# ===================================================================
# Every class defined here which is a subclass of `Command' will be used as a
# command in ranger.  Several methods are defined to interface with ranger:
#   execute(): called when the command is executed.
#   cancel():  called when closing the console.
#   tab():     called when <TAB> is pressed.
#   quick():   called after each keypress.
#
# The return values for tab() can be either:
#   None: There is no tab completion
#   A string: Change the console to this string
#   A list/tuple/generator: cycle through every item in it
#
# The return value for quick() can be:
#   False: Nothing happens
#   True: Execute the command afterwards
#
# The return value for execute() and cancel() doesn't matter.
#
# ===================================================================
# Commands have certain attributes and methods that facilitate parsing of
# the arguments:
#
# self.line: The whole line that was written in the console.
# self.args: A list of all (space-separated) arguments to the command.
# self.quantifier: If this command was mapped to the key 'X' and
#      the user pressed 6X, self.quantifier will be 6.
# self.arg(n): The n-th argument, or an empty string if it doesn't exist.
# self.rest(n): The n-th argument plus everything that followed.  For example,
#      If the command was 'search foo bar a b c', rest(2) will be 'bar a b c'
# self.start(n): The n-th argument and anything before it.  For example,
#      If the command was 'search foo bar a b c', rest(2) will be 'bar a b c'
#
# ===================================================================
# And this is a little reference for common ranger functions and objects:
#
# self.fm: A reference to the 'fm' object which contains most information
#      about ranger.
# self.fm.notify(string): Print the given string on the screen.
# self.fm.notify(string, bad=True): Print the given string in RED.
# self.fm.reload_cwd(): Reload the current working directory.
# self.fm.thisdir: The current working directory. (A File object.)
# self.fm.thisfile: The current file. (A File object too.)
# self.fm.thistab.get_selection(): A list of all selected files.
# self.fm.execute_console(string): Execute the string as a ranger command.
# self.fm.open_console(string): Open the console with the given string
#      already typed in for you.
# self.fm.move(direction): Moves the cursor in the given direction, which
#      can be something like down=3, up=5, right=1, left=1, to=6, ...
#
# File objects (for example self.fm.thisfile) have these useful attributes and
# methods:
#
# cf.path: The path to the file.
# cf.basename: The base name only.
# cf.load_content(): Force a loading of the directories content (which
#      obviously works with directories only)
# cf.is_directory: True/False depending on whether it's a directory.
#
# For advanced commands it is unavoidable to dive a bit into the source code
# of ranger.
# ===================================================================

from ranger.api.commands import *
from ranger.core.loader import CommandLoader
import shutil


class download(Command):
    '''
    :download [filename]
    Download uri in X clipboard using wget
    '''

    def execute(self):
        from ranger.ext.shell_escape import shell_quote

        command = 'wget --content-disposition --trust-server-names "`xsel -o`"'
        if self.rest(1):
            command += ' -O ' + shell_quote(self.rest(1))
        action = ['zsh', '-c', command]
        self.fm.execute_command(action)


class diff(Command):
    # vimdiff selected files
    def execute(self):
        self.fm.execute_console('shell vimdiff %s')


class diffyanked(Command):
    # vimdiff yanked files
    def execute(self):
        self.fm.execute_command(['vimdiff'] + [f.path for f in self.fm.copy_buffer])


class compress(Command):
    def execute(self):
        ''' Compress marked files to current directory '''
        cwd = self.fm.thisdir
        marked_files = cwd.get_selection()

        if not marked_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        original_path = cwd.path
        dest = self.line[self.line.index(' ')+1:]

        descr = 'compressing files in: ' + os.path.basename(dest)
        obj = CommandLoader(args=['apack', dest] + \
            [os.path.relpath(f.path, cwd.path) for f in marked_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)

    def tab(self):
        ''' Complete with current folder name '''

        extension = ['.zip', '.tbz', '.tgz', '.7z']
        return [self.line + ext for ext in extension]


class compressyanked(Command):
    def execute(self):
        ''' Compress copied files to current directory '''
        copied_files = tuple(self.fm.copy_buffer)

        if not copied_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        one_file = copied_files[0]
        cwd = self.fm.thisdir
        original_path = cwd.path
        parts = self.line.split()
        au_flags = parts[1:]

        descr = 'compressing files in: ' + os.path.basename(parts[1])
        obj = CommandLoader(args=['apack'] + au_flags + \
            [os.path.relpath(f.path, cwd.path) for f in copied_files], descr=descr)

        self.fm.copy_buffer.clear()
        self.fm.do_cut = False

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)

    def tab(self):
        ''' Complete with current folder name '''

        extension = ['.zip', '.tbz', '.tgz', '.7z']
        return [self.line + ext for ext in extension]


class extract(Command):
    def execute(self):
        ''' Extract copied files to current directory '''
        copied_files = tuple(self.fm.copy_buffer)

        if not copied_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        one_file = copied_files[0]
        cwd = self.fm.thisdir
        original_path = cwd.path
        au_flags = ['-X', cwd.path]
        au_flags += self.line.split()[1:]
        au_flags += ['-e']

        self.fm.copy_buffer.clear()
        self.fm.do_cut = False
        if len(copied_files) == 1:
            descr = 'extracting: ' + os.path.basename(one_file.path)
        else:
            descr = 'extracting files from: ' + os.path.basename(one_file.dirname)
        obj = CommandLoader(args=['aunpack'] + au_flags \
            + [f.path for f in copied_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)


class j(Command):

    def execute(self):

        obj = None

        if not self.arg(1):
            self.fm.notify('Syntax: j <pathname>')
            return

        def handle_results(_):
            lines = obj.stdout_buffer.split('\n')
            path = None

            for line in lines:
                splits = line.split(' ', 1)

                if len(splits) < 2:
                    break

                count, path = splits
                count = count.strip()
                path = path.strip()

                if count == 'common:':
                    break

            if path:
                self.fm.cd(path)
            else:
                self.fm.notify('Nothing matched.')

        z_path = os.path.expanduser('~/Tools/z/z.sh')
        cmd = 'source {} && _z -l {} 2>&1'.format(z_path, self.arg(1))
        obj = CommandLoader(args=['/usr/bin/zsh', '-c', cmd], descr = 'Running z', read = True)
        obj.signal_bind('after', handle_results)
        self.fm.loader.add(obj)


class ssh(Command):

    def execute(self):
        cwd = os.getcwd()
        remote_name = ''

        if self.arg(1) and self.arg(1) != 'cd':
            remote_name = self.arg(1)

            if remote_name.endswith('._remote'):
                remote_name = remote_name.replace('._remote', '')

        elif not cwd.startswith('/mnt/'):
            self.fm.notify('Not in a remote directory.')
            return
        else:
            remote_name = cwd[1:].split('/')[1]

        remote_conf = parse_remote_conf(remote_name)
        remote_path = remote_conf['root']

        if self.arg(1) == 'cd':
            remote_path = os.path.join(remote_path, '/'.join(cwd[1:].split('/')[2:]))

        password_part = 'sshpass -p \'{}\' '
        cd_part = '\'cd {}; zsh --login || bash --login\' '
        command = (password_part + 'ssh -l {} {} -t ' + cd_part) \
                .format(remote_conf['password'], remote_conf['username'], remote_conf['host'], remote_path)

        self.fm.execute_command(['zsh', '-c', command])

