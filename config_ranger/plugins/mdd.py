#! /usr/bin/env python
# -*- coding: utf-8 -*-

#############################################################
#     Author              :     Daniel Lupu
#     Creation Date       :     [2017-12-04 23:42]
#     Last Modified       :     [2017-12-04 23:48]
#############################################################
import datetime
import os
from ranger.api.commands import *


class mdd(Command):

    def execute(self):

        dt = datetime.datetime.now()
        folder_name = '{}-{:02d}-{:02d}'.format(dt.year, dt.month, dt.day)

        try:
            os.mkdir(folder_name)
        except OSError:
            pass

        self.fm.cd(folder_name)
