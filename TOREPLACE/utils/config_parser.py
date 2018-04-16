import json


class ConfigParser:
    def __init__(self):
        pass

    @staticmethod
    def return_json(path_to_config: str):
        with open(path_to_config) as config_file:
            return json.load(config_file)

    @staticmethod
    def return_read(path_to_config: str):
        with open(path_to_config) as config_file:
            return config_file.read()
