"""core URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))

NOTE: Django REST Framework maintains its own versioning schema to work with
Django's MVC pattern. Use namespace-based versioning to version APIs:
https://www.django-rest-framework.org/api-guide/versioning/#namespaceversioning
"""

import os

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include
from django.urls import path
from django.urls import re_path


# TODO: Review other methods of versioning APIs. Apparently, one other popular
# method for API versioning includes adding an 'X-' HTTP header to denote API
# versioning. This may reduce the amount of code that needs to be rewritten, at
# the cost of code / codebase clarity. See this Stack Overflow answer:
# https://stackoverflow.com/a/21839842/1497211, and this Stack Overflow answer:
# https://stackoverflow.com/a/14380004/1497211, with reference to GitHub's V3
# API: https://developer.github.com/v3/media/, and 'X-GitHub-Media-Type:
# github.v3'.
#
# Django system check warning '?: (urls.W005) URL namespace 'v1' isn't unique.
# You may not be able to reverse all URLs in this namespace' arrives from this
# code block.

from . import Dummy


urlpatterns = [
    path(
        'admin/',
        admin.site.urls
    ),
    re_path(
        r'^v1/auth/',
        include(
            (
                'authentication.urls',
                'authentication'
            ),
        namespace='v1'
        )
    ),
    re_path(
        r'^v1/data/',
        include(
            (
                'concrete_data.urls',
                'concrete_data'
            ),
        namespace='v1'
        )
    ),
    path(
        # Matches the root route only.
        '',
        Dummy.HomePageView.as_view(),
        name='rootdummy'
    ),
]

# Make sure that data files are served in Django setting mode DEBUG.
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT
    )
