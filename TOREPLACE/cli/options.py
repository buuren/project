import click


class Options:
    def __init__(self):
        self.verbose = click.option(
            '--verbose',
            is_flag=True,
            default=False,
            show_default=True,
            help='Enables verbose mode.'
        )

    def set_options(self, **kwargs):
        for key, value in kwargs.items():
            print("---> Setting {key} to value -> {value} ".format(
                key=key, value=value
            ))
            setattr(self, key, value)

        return self

    def get_click_options(self) -> list:
        click_options = [
            click_option
            for option, click_option in self.__dict__.items()
        ]

        return click_options

    def get_option_values(self):
        return self.__dict__

    def append_additional_options(self, **kwargs):
        for option, values in kwargs.items():
            for value in values:
                print("---> Appending value [%s] to option [--%s]" % (
                    value, option
                ))
                setattr(self, option, self.__dict__[option] + (value,))
