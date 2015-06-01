#!/bin/sh
set -e

xctool -workspace "App Reviews.xcworkspace" -scheme "App Reviews" build test -sdk macosx

