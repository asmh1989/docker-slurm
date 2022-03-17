#!/bin/bash

sudo service munge start
sudo slurmd -N $SLURM_NODENAME

tail -f /dev/null
