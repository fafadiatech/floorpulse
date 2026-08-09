from setuptools import setup, find_packages

with open("requirements.txt") as f:
    install_requires = f.read().strip().split("\n")

install_requires = [r for r in install_requires if r]

setup(
    name="floorpulse",
    version="0.0.1",
    description="ERPNext backend for FloorPulse — field operations platform",
    author="Fafadia Tech",
    author_email="sidharth@fafadiatech.com",
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=install_requires,
)
