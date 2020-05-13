"""
Serializers for managing file uploads.
See: https://www.django-rest-framework.org/tutorial/1-serialization/
See:
"""

from rest_framework import serializers

from . import models


class FileSerializer(serializers.ModelSerializer):
    """
    Serializer for the File model.
    """
    class Meta:
        model = models.File
        fields = "__all__"
