# Generated by Django 4.2.1 on 2023-05-25 11:12

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='book',
            name='image',
            field=models.ImageField(upload_to=''),
        ),
        migrations.AlterField(
            model_name='rental',
            name='return_date',
            field=models.DateTimeField(default=datetime.datetime(2023, 5, 28, 19, 12, 59, 623826)),
        ),
    ]