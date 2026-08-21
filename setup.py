from setuptools import setup, find_packages

setup(
    name="heritage-hub",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "flask",
        "requests",
        "beautifulsoup4",
        "pymupdf",
        "pillow",
    ],
)
