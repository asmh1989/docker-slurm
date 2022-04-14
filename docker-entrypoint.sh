#!/bin/bash

cd /public/home/sun/slurm_tools/
sudo bash create_slurm_user_without_sacct.sh


sudo service munge start
sudo slurmd -N $SLURM_NODENAME

tail -f /dev/null
