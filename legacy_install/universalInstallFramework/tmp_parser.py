#!/usr/bin/env python
#import sys, json; print(json.load(sys.stdin)['$1'].join(' '))
import sys, yaml

with open(sys.stdin, "r") as stream:
    try:
        print(yaml.safe_load(stream)[$1])
    except yaml.YAMLError as exc:
        print(exc)

