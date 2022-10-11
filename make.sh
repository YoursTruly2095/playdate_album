#!/bin/bash

cp main.lua album-$1
cp Gondomania.fnt album-$1

cd album-$1

pdc . ../$1.pdx

cd ..
