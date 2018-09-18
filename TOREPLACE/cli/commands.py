import click

from cli.options import Options
from decorators.cli import add_options


CONTEXT_SETTINGS = dict(
    auto_envvar_prefix='TOREPLACE',
    allow_extra_args=True,
    token_normalize_func=lambda x: x.lower() if isinstance(x, str) else x
)

# Initate Options
options_object = Options()


@click.group(context_settings=CONTEXT_SETTINGS)
@add_options(options_object.get_click_options())
def cli(**kwargs):
    options_object.set_options(**kwargs)


@cli.command()
def test():
    # Load configuration files
    click.echo("Test")
