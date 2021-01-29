from setuptools import setup, find_packages

def read(filename):
  return [
    req.strip()
    for req 
    in open(filename).readlines()
  ]

setup(
  name='wordcount',
  version='0.0.1',
  description='An awesome package that does something',
  packages=find_packages(),
  scripts=[],
  install_requires=read("requirements.txt"),
)