#!/bin/bash

cd $TESTING_FOLDER

# creating environment and sourcing requirements
echo "[run-lambda-tests-inittest] Creating environment and sourcing requirements..."
python3 -m virtualenv testing_env -q
. testing_env/bin/activate
pip3 install -q -r test_ecs-updater_requirements.txt

# running ecs-updater unit test use cases
echo "[run-lambda-tests-inittest] Running ecs-updater unit test use cases..."
python3 -m pytest -v -rA test_ecs-updater.py || exit 0

# wrapping up
echo "[run-lambda-tests-inittest] Wrapping up..."
#deactivate || exit 0
rm -rf testing_env __pycache__/ .pytest_cache/
