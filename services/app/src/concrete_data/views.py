"""
Concrete data service custom views.
"""

from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView

from . import serializers


class TestProtectedView(APIView):
    """
    Test that other Django apps apart from 'authentication' remain protected via
    token-based authentication through pinging API endpoints.
    """
    def get(self, request):
        """
        Sample HTTP GET request.
        """
        return Response(
            data={
                "hello": "world"
            },
            status=status.HTTP_200_OK
        )


class FileUploadView(APIView):
    """
    Upload files via API.
    """
    parser_classes = (
        MultiPartParser,
        FormParser,
    )

    def post(self, request, *args, **kwargs):
        file_serializer = serializers.FileSerializer(
            data=request.data
        )
        if file_serializer.is_valid():
            file_serializer.save()
            return Response(
                file_serializer.file,
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                file_serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
