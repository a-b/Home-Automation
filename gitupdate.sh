#!/bin/bash
cd /home/homeassistant/.homeassistant/
git add .
git status
git commit
git push origin master

exit