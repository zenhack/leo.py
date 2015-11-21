from setuptools import setup

setup(name='leo',
      version='0.1',
      author='Ian Denhardt',
      author_email='ian@zenhack.net',
      url='https://gitlab.com/isd/leo.py',
      scripts=['leo'],
      install_requires=[
          'compat23',
          'lxml',
          'requests',
      ])
