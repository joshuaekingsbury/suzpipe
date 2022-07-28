#!/usr/bin/env bash

evtPath=$1

pushd ${evtPath}

yes n | gunzip *.*

popd




