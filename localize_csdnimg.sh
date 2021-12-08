#!/bin/bash

grep -rn -l csdnimg source/_posts/ | xargs -I {} basename -s .md "{}" | xargs -t -I {} ./localize.sh "{}"
