def add_options(options):
    def wrapper(func):
        for option in reversed(options):
            func = option(func)
        return func

    return wrapper
