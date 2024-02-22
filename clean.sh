#!/bin/bash

data_dir=("data/gethdata/geth" "data/beacondata" "data/validatordata")

for dir in ${data_dir[@]};do
    if [ -e ${dir} ]; then
        echo "delete ${dir}"
        rm -r ${dir}
    fi
done
