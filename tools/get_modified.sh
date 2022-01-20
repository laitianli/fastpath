#!/bin/bash
#sed -i -e "s/\t/    /g" `find . -name "*.[hc]"`
for f in `git status | grep "modified" | awk '{print $3}'`
do 
    echo "f=$f"
    git add $f
done

for f in `git status | grep "typechange" | awk '{print $3}'`
do 
    echo "f=$f"
    git add $f
done
