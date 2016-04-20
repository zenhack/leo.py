from setuptools import setup

setup(name='leo',
      version='0.2',
      author='Ian Denhardt',
      author_email='ian@zenhack.net',
      url='https://gitlab.com/isd/leo.py',
      scripts=['leo'],
      install_requires=[
          'six',
          'lxml',
          'requests',
          'tabulate',
      ])
