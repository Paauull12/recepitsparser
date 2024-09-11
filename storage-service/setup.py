from setuptools import find_packages, setup

setup(
    name='display_service',
    version='0.1.0',
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        'Django==4.2.13',
        "djangorestframework==3.15.2",
        "pillow ~= 9.5.0",
        "gunicorn",
        "psycopg2",
        "django-cors-headers",
        "minio",
        "django-storages",
        "boto3",
        "requests",
        "ollama",
        "regex",
        "easyocr",
        "opencv-python",
    ],
    entry_points={
        'console_scripts': [
            'manage = display_service.manage:main',
        ],
    },
    classifiers=[
        'Environment :: Web Environment',
        'Framework :: Django',
        'Framework :: Django :: 3.2',
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Topic :: Internet :: WWW/HTTP',
        'Topic :: Internet :: WWW/HTTP :: Dynamic Content',
    ],
)
