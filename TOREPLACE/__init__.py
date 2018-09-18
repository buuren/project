#!/usr/bin/env python

from utils.config_parser import ConfigParser

__project__ = 'TOREPLACE'
__version__ = '0.0.0'

VERSION = __project__ + '-' + __version__


class Init:
    def __init__(self):
        """
        Initiator class to load all necessary configurations, logger and HTTP client instances
        """
        config_parser = ConfigParser()

        self.config = config_parser.return_json(path_to_config='config/example.json')
