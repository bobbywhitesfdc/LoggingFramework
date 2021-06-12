#!/bin/bash
# Exit on error!
set -euxo pipefail
#create scratch org
sfdx force:org:create -f config/project-scratch-def.json -s -a LOGGER username=admin@logger.org --durationdays 28


sfdx force:org:open
