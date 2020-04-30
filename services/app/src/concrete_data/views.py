"""
Concrete data service custom views.
"""

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView


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
