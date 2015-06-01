#!/bin/sh
set -e

brew unlink xctool
brew update
brew install xctool

- gem install cocoapods -v '0.37.2'