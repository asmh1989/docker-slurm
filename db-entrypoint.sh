#! /bin/bash

sudo service munge start
sudo service slurmdbd start

tail -f /dev/null