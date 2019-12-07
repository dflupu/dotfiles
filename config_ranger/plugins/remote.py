import os
import sys
import keyring
import ranger
from ranger.ext.shell_escape import shell_escape
from ranger.api.commands import *

CONFIGS_DIR = None
MOUNTS_DIR = None

if sys.platform == 'linux':
    UMOUNT_CMD = 'fusermount -uz {} && rmdir {}'
else:
    UMOUNT_CMD = 'umount {} && rmdir {}'


def init():

    global CONFIGS_DIR
    global MOUNTS_DIR

    MOUNTS_DIR = os.path.expanduser('~/Mounts')
    CONFIGS_DIR = os.path.join(ranger.arg.confdir, 'remote')

    try_makedirs(CONFIGS_DIR)
    try_makedirs(MOUNTS_DIR)


class rls(Command):

    def execute(self):
        self.fm.cd(CONFIGS_DIR)


class radd(Command):

    def execute(self):

        remote_name = self.arg(1)

        template = '\n'.join([
            'protocol(ftp/sftp):',
            'host:',
            'username:',
            'remote directory (default \'/\'):',
        ])

        if not remote_name:
            self.fm.notify('Syntax: radd <name>{3,}')
            return

        conf_path = os.path.join(CONFIGS_DIR, remote_name)
        conf_existed = False

        if os.path.exists(conf_path):
            conf_existed = True
        else:
            with open(conf_path, 'w') as conf_file:
                conf_file.write(template)

        proc = self.fm.run('nvim ' + shell_escape(conf_path))

        if proc.returncode != 0:
            self.fn.notify('Editor returned non-zero exit code. Aborting.')

            if not conf_existed:
                os.remove(conf_path)
            return

        if os.path.getsize(conf_path) == 0:
            self.fn.notify('File was empty. Aborting.')
            os.remove(conf_path)
            return


class rumountall(Command):

    def execute(self):

        for filename in os.listdir(MOUNTS_DIR):
            fp = os.path.join(MOUNTS_DIR, filename)
            cmd = UMOUNT_CMD.format(fp, fp)
            self.fm.run(cmd)


class rumount(Command):

    def tab(self, tabcount):

        rest = self.rest(1)

        remote_list = os.listdir(CONFIGS_DIR)
        filtered_list = [r for r in remote_list if r.startswith(rest)]
        pick = filtered_list[tabcount % len(filtered_list)]
        return 'rumount ' + pick

    def execute(self):

        filename = self.arg(1)
        fp = os.path.join(MOUNTS_DIR, filename)
        cmd = UMOUNT_CMD.format(filename, fp)
        self.fm.run(cmd)


class rcd(Command):

    def tab(self, tabcount):

        rest = self.rest(1)

        remote_list = os.listdir(CONFIGS_DIR)
        filtered_list = [r for r in remote_list if r.startswith(rest)]
        pick = filtered_list[tabcount % len(filtered_list)]
        return 'rcd {}'.format(pick)

    def execute(self):

        remote_conf = self.parse_remote_conf(self.arg(1))
        remote_conf['name'] = self.arg(1)

        if not remote_conf:
            return

        mount_path = os.path.join(MOUNTS_DIR, self.arg(1))

        if not os.path.exists(mount_path):
            try_makedirs(mount_path)

        already_mounted = False

        try:
            already_mounted = len(os.listdir(mount_path)) > 0
        except Exception:
            pass

        if already_mounted:
            self.fm.cd(mount_path)
            return

        if remote_conf['protocol'] == 'sftp':
            mount_func = self.mount_sshfs
        elif remote_conf['protocol'] == 'ftp':
            mount_func = self.mount_sftp
        else:
            self.fm.notify('unknown protocol')
            return

        password = keyring.get_password('ranger', 'host_' + self.arg(1)) or ''
        remote_conf['password'] = password

        mount_result = mount_func(remote_conf, mount_path)

        if mount_result != 0:
            self.fm.notify('failed to mount directory')
        else:
            self.fm.cd(mount_path)

    def mount_sshfs(self, remote_conf, mount_path):

        pw_echo = 'echo ' + shell_escape(remote_conf['password'])
        ssh_uri = shell_escape('{}@{}:'.format(
            remote_conf['username'],
            remote_conf['host'],
        ))

        if remote_conf['root'] and len(remote_conf['root']) > 0:
            ssh_uri += shell_escape(remote_conf['root'])

        if remote_conf['password'] != '':
            cmd = '{pw} | sshfs {uri} {mount} -o password_stdin'.format(
                pw=pw_echo,
                uri=ssh_uri,
                mount=shell_escape(mount_path)
            )
        else:
            cmd = 'sshfs {uri} {mount}'.format(
                uri=ssh_uri,
                mount=shell_escape(mount_path)
            )

        return self.fm.run(cmd).returncode

    def mount_sftp(self, remote_conf, mount_path):

        cmd = 'curlftpfs {host} {mount} -o user={user}:{pw}'.format(
            host=remote_conf['host'],
            mount=mount_path,
            user=shell_escape(remote_conf['username']),
            pw=shell_escape(remote_conf['password'])
        )

        return self.fm.run(cmd).returncode

    def parse_remote_conf(self, remote_name):

        conf_path = os.path.join(CONFIGS_DIR, remote_name)

        data = {}

        if not os.path.exists(conf_path):
            self.fm.notify('remote not found')
            return

        with open(conf_path, 'r') as input_file:
            for line in input_file:
                line = line.strip()

                splits = line.split(':', 1)
                name = splits[0]
                value = splits[1]

                if name.startswith('protocol'):
                    name = 'protocol'
                elif name.startswith('remote directory'):
                    name = 'root'

                data[name.strip()] = value.strip()

        return data

#######################################################################################
# overwrite file execute function and rcd if we're trying to execute a remote conf file

from ranger.core.actions import Actions
original_execute_file = Actions.execute_file


def execute_file(self, files, **kw):

    if isinstance(files, set):
        files = list(files)
    elif type(files) not in (list, tuple):
        files = [files]

    if len(files) > 1 or 'label' in kw:
        return original_execute_file(self, files, **kw)

    filepath = files[0].path
    basename = os.path.basename(filepath)
    abspath = os.path.abspath(filepath)

    if os.path.split(abspath)[0] == CONFIGS_DIR:
        self.execute_console('rcd ' + basename)
        self.signal_emit('execute.after')
        return

    return original_execute_file(self, files, **kw)

Actions.execute_file = execute_file

#######################################################################################
# overwrite function that gets directory file count. skip files in mounted folders

from ranger.container.directory import Directory
from ranger.ext.lazy_property import lazy_property
from ranger.container.fsobject import BAD_INFO

original_directory_size = Directory('.').__class__.__dict__['size']


@lazy_property
def size(self):

    if os.path.abspath(self.path).startswith(MOUNTS_DIR):
        self.infostring = ' ?'
        self.accessible = True
        self.runnable = True
        return 1

    return original_directory_size._method(self)

Directory.size = size

#######################################################################################

def try_makedirs(path):
    try:
        os.makedirs(path)
    except OSError:
        pass


init()
