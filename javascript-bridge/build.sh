#!/usr/bin/env bash
#nix-shell -p yarn nodePackages.webpack nodePackages.webpack-cli nodejs-13_x
cd ~/Code/beagle-web-core
yarn install --ignore-engines
yarn build
cd ~/Code/beagle-flutter/javascript-bridge
npm install ~/Code/beagle-web-core/dist
npm install -g
npm run-script build
