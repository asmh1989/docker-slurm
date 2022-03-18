#!/bin/bash

sudo service munge start
sudo slurmd -N $SLURM_NODENAME -f /public/slurm/slurm.conf

tail -f /dev/null
