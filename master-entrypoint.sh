#!/bin/bash

sudo service munge start
sudo service slurmctld start
sudo service slurmdbd start
sudo service ssh start

tail -f /dev/null
