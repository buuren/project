import logging
import sys


class LoggingHandler:
    def __init__(self, name, level=logging.DEBUG):
        self.log = logging.getLogger(name)
        self.log.setLevel(level)
        log_format = '%(asctime)s <%(levelname)s> - %(message)s [%(name)s.%(funcName)s]'
        formatter = logging.Formatter(log_format)
        ch = logging.StreamHandler(sys.stdout)
        ch.setFormatter(formatter)
        self.log.addHandler(ch)
        self.log.info("Initialized logger for ")


if __name__ == "__main__":
    logger = LoggingHandler("test")
    logger.log.info("Test")
