#!/bin/bash

sudo apt install quota
sudo mount -o remount,usrquota /
sudo quotacheck -cum /
sudo quotaon /
