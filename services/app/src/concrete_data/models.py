"""
Models for managing file uploads.
"""

import os

from django.conf import settings
from django.db import models


DATA_DUMP_DIRECTORY = os.path.join(
    settings.MEDIA_ROOT,
    'data-dumps'
)


class File(models.Model):
    """
    Model for files uploaded to TinyDevCRM.
    """
    file_id = models.AutoField(primary_key=True)
    file = models.FileField(upload_to=DATA_DUMP_DIRECTORY)

    def __str__(self):
        return str(self.file.name)
