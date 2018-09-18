import click

from utils.initiator import Initiator
from cli.options import Options
from decorators.cli import add_options


if __name__ == '__main__':
    CONTEXT_SETTINGS = dict(
        auto_envvar_prefix='TOREPLACE',
        allow_extra_args=True,
        token_normalize_func=lambda x: x.lower() if isinstance(x, str) else x
    )

    # Load configuration files
    init = Initiator()

    # Initate Options
    options_object = Options()

    @click.group(context_settings=CONTEXT_SETTINGS)
    @add_options(options_object.get_click_options())
    def cli(**kwargs):
        options_object.set_options(**kwargs)


    @cli.command()
    def test():
        pass

    cli()
