"""
Concrete data service API endpoint configuration.
"""

from django.urls import path

from . import views


urlpatterns = [
    path(
        'test/',
        views.TestProtectedView.as_view(),
        name='test'
    )
]
