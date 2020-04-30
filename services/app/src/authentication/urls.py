"""
URL configuration for 'authentication'.
"""

from django.urls import path
from rest_framework_simplejwt import views as jwt_views

from .views import (
    CustomUserRegister,
    CustomObtainTokenPairView,
    CustomBlacklistRefreshTokenView,
)


urlpatterns = [
    path(
        'users/register/',
        CustomUserRegister.as_view(),
        name='users.register'
    ),
    path(
        'tokens/obtain/',
        CustomObtainTokenPairView.as_view(),
        name='tokens.obtain'
    ),
    path(
        'tokens/refresh/',
        jwt_views.TokenRefreshView.as_view(),
        name='tokens.refresh'
    ),
    path(
        'tokens/blacklist/',
        CustomBlacklistRefreshTokenView.as_view(),
        name='tokens.blacklist'
    ),
]
