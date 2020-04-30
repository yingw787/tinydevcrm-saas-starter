from django.contrib import admin

from . import models


# Register your models here.
class CustomUserAdmin(admin.ModelAdmin):
    """
    Registration of models.CustomUser with the Django admin dashboard.
    """
    model = models.CustomUser


admin.site.register(
    models.CustomUser,
    CustomUserAdmin
)
