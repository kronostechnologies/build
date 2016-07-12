#!/usr/bin/python2
# Simple script to quickly test the package building process

import sys

def eprint(msg):
  sys.stderr.write(__file__ + ": " + msg + "\n")

def import_module_or_exit(module_name):
  try:
    __import__(module_name)
  except ImportError:
    eprint("Aborting !!!")
    eprint("Module '" + module_name + "' is not installed.")

import os
import os.path
try:
  import yaml
except ImportError:
  eprint("Aborting !!!")
  eprint("Module '" + module_name + "' is not installed.")
  sys.exit(1)

if len(sys.argv) != 2:
  eprint("usage: " + __file__ + " /source/to/project")
  sys.exit(1)

SOURCE_PATH = sys.argv[1]
CIRCLEYML_PATH = SOURCE_PATH + '/circle.yml'
AUTODEPLOY_SCRIPT = os.environ['HOME'] + "/kronos/build/circleci/auto_deploy.sh"

# These exports are the actual variable used by the circleci script
def export_circleci_variable():
  eprint("Exporting environment variable")
  global CIRCLEYML_PATH

  yaml_doc = yaml.load(open(CIRCLEYML_PATH))
  if not yaml_doc['machine'] or not yaml_doc['machine']['environment']:
    eprint("There is no environment variable defined under 'machine->environment' in '" + CIRCLEYML_PATH + "'")
  else:
    for key, value in yaml_doc['machine']['environment'].iteritems():
      os.environ[key] = value

def download_deploy_script_if_necessary():
  global AUTODEPLOY_SCRIPT
  if not os.path.exists(AUTODEPLOY_SCRIPT):
    eprint("Path '" + AUTODEPLOY_SCRIPT + "' does not exist. Will wget auto_deploy.sh into /tmp")
    AUTODEPLOY_SCRIPT = '/tmp/auto_deploy.sh'
    os.system("wget -q0 https://raw.githubusercontent.com/kronostechnologies/build/master/circleci/auto_deploy.sh -O " + AUTODEPLOY_SCRIPT)
    os.system("chmod +x " + AUTODEPLOY_SCRIPT)


if not os.path.exists(CIRCLEYML_PATH):
  eprint("Aborting !!!")
  eprint("Looks like '" + CIRCLEYML_PATH + "' does not exist.")
  sys.exit(1)



export_circleci_variable()
download_deploy_script_if_necessary()


eprint("Executing autodeploy script '" + AUTODEPLOY_SCRIPT + "'")
os.chdir(SOURCE_PATH)
os.system(AUTODEPLOY_SCRIPT)

