"""
Models for managing file uploads.
"""

import os

from django.conf import settings
from django.db import models


class File(models.Model):
    """
    Model for files uploaded to TinyDevCRM.
    """
    file_id = models.AutoField(primary_key=True)
    file = models.FileField(
        upload_to='concrete-data',
        blank=False,
        null=False
    )

    def __str__(self):
        return str(self.file.name)
