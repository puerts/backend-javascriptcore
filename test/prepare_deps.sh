#!/bin/bash

mkdir deps
cd deps
curl -L -O https://github.com/puerts/backend-javascriptcore/releases/download/jsc_bin_240605/jsc_bin.tgz
tar xfz jsc_bin.tgz
