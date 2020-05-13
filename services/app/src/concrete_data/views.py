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
        """
        Handles the HTTP POST request.

        NOTE: These keys, such as 'data' and 'file', are very particular to the
        underlying models and serializers. Do not change without testing in
        development.
        """

        file_serializer = serializers.FileSerializer(
            # Use the form key 'file=' in order to send binary files as part of
            # a multipart/form-data request.
            #
            # Example: curl --header "Content-Type: multipart/form-data"
            # --header "Authorization: JWT $JWT_ACCESS_TOKEN" -X POST  -F
            # 'file=@"/path/to/sample.csv"'
            # http://localhost:8000/v1/data/upload/
            data={
                'file': request.data['file']
            }
        )
        if file_serializer.is_valid():
            file_serializer.save()
            return Response(
                file_serializer.data,
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                file_serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
