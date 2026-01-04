#!/bin/bash
cp LICENSE ./addons/clog/
cp README.md ./addons/clog/
zip -r clog.zip ./addons/clog -x "*.uid"