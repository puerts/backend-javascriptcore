#!/bin/bash

mkdir deps
cd deps
curl -L -O https://github.com/puerts/backend-javascriptcore/releases/download/jsc_bin_240605/jsc_bin.tgz
tar xvfz jsc_bin.tgz
