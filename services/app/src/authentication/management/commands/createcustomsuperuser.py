"""
Custom, fully scriptable command to create a Django superuser inline with this
authentication model's custom user with password.

Taken from: https://stackoverflow.com/a/42491469/1497211
"""

from django.contrib.auth.management.commands import createsuperuser
from django.core.management import CommandError


class Command(createsuperuser.Command):
    """
    Extending 'python manage.py createsuperuser' with scripted password support.
    """
    def add_arguments(self, parser):
        super(Command, self).add_arguments(parser)
        parser.add_argument(
            '--password',
            dest='password',
            default=None,
            help='Specifies the password for the superuser.'
        )

    def handle(self, *args, **options):
        primary_email = options.get('primary_email')
        password = options.get('password')
        database = options.get('database')

        super(Command, self).handle(*args, **options)

        if password:
            user = self.UserModel._default_manager.db_manager(database).get(
                primary_email=primary_email
            )
            user.set_password(password)
            user.save()
