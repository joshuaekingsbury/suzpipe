#!/usr/bin/env bash

#gnome-terminal -- bash -c 'echo '$1'; exec bash'

gnome-terminal -- bash -c './obsRetrieveReduce.sh '$1' '${2:-true}'; exec bash'
