"""
Dummy view for root route.

This may be necessary in order to keep the AWS ECS Docker container alive.
"""

import textwrap

from django.http import HttpResponse
from django.views.generic.base import View


class HomePageView(View):
    """
    Dummy homepage view. This will be replaced by OpenAPI documentation around
    API endpoints once they have been constructed.
    """
    def dispatch(request, *args, **kwargs):
        response_text = textwrap.dedent('''\
            <html>
            <head>
                <title>Greetings to the world</title>
            </head>
            <body>
                <h1>Greetings to the world</h1>
                <p>Hello, world!</p>
            </body>
            </html>
        ''')
        return HttpResponse(response_text)
