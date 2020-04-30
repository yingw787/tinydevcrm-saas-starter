"""
Authentication service custom serializers.
"""

from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from . import models


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Serializer to customize JSON Web token claim:
    https://github.com/davesque/django-rest-framework-simplejwt#customizing-token-claims

    This may (or may not) help in creating permissioned public APIs:
    https://auth0.com/blog/using-json-web-tokens-as-api-keys/
    """
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        # NOTE: Add custom JWT claims here.

        return token


class CustomUserSerializer(serializers.ModelSerializer):
    """
    Serializes REST API JSON data to database model.
    """
    class Meta:
        """
        This class models models.CustomUser, and enforces a hard failure if
        incoming data doesn't match the Django model (which mirrors the data
        representation in the database).
        """
        model = models.CustomUser
        fields = ('full_name', 'primary_email', 'password')
        extra_kwargs = {
            'password': {
                'write_only': True
            }
        }

    def create(self, validated_data):
        # NOTE: Not sure whether create() can be renamed to register(), who
        # calls this method. Doesn't matter when it comes to API endpoint
        # naming.
        password = validated_data.pop('password', None)
        instance = self.Meta.model(**validated_data)
        if password is not None:
            instance.set_password(password)

        instance.save()
        return instance
