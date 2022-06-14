#!/usr/bin/env bash
#nix-shell -p yarn nodePackages.webpack nodePackages.webpack-cli nodejs-13_x
cd ~/AndroidStudioProjects/beagle-web-core
yarn install --ignore-engines
yarn build
cd dist
cd ~/AndroidStudioProjects/beagle-flutter/javascript-bridge
npm install -g
npm run-script build
