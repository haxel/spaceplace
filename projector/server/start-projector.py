#!/usr/bin/env python
import pkg_resources
pkg_resources.require("TurboGears")

import cherrypy
import turbogears
from os.path import *
import sys

turbogears.update_config(configfile="prodcfg.py",modulename="projector.config")

from projector.controllers import Root

cherrypy.root = Root()
cherrypy.server.start()
