#!/bin/bash
./scripts/checksums.sh generate
python scripts/changelog.py
bash scripts/git.sh

