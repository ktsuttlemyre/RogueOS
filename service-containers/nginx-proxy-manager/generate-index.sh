#!/bin/bash
index="<html><head><title></title></head><body><ul>"
list=$(grep -rni "server_name" ~/nginx-proxy-manager/data/nginx/* | tr -s ' ' | cut -d ' ' -f 3)

while IFS= read -r entry; do
    echo "<li><a href='$entry'>$entry</a></li>"
done <<< "$list"

index+="</ul></body></html>"