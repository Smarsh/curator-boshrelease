#!/bin/bash
set -e
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH=/var/vcap/packages/curator/bin:$PATH
export CONFIG_DIR=/var/vcap/jobs/curator/config
export PYTHONPATH=/var/vcap/packages/curator/lib/python3.8/site-packages/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/var/vcap/packages/python3/lib

curator --config $CONFIG_DIR/config.yml \
                 $CONFIG_DIR/actions.yml
