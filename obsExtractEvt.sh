#!/usr/bin/env bash

pushd ${evtPath} >& /dev/null

yes n | gunzip *.*

popd >& /dev/null




