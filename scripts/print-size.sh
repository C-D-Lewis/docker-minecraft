#!/bin/bash

DIR=${1:-.}

tree --du -h $DIR | grep ^├─
