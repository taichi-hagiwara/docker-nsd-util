#!/bin/sh

set -e

first_column() {
  echo "$1"
}

update() {
  cat $1 | ldns-read-zone -S 0 | ldns-read-zone -S unixtime
}

mkdir -p /etc/nsd/current_zones
mkdir -p /etc/nsd/old_zones

new_zones_file=$(mktemp)
old_zones_file=$(mktemp)

ls /etc/nsd/zonefiles > ${new_zones_file}
ls /etc/nsd/current_zones > ${old_zones_file}

# modified files
comm -12 ${new_zones_file} ${old_zones_file} | while read line; do
  new_hash=$(first_column $(sha256sum /etc/nsd/zonefiles/${line}))
  old_hash=$(first_column $(sha256sum /etc/nsd/old_zones/${line}))
  if [ "${new_hash}" != "${old_hash}" ]; then
    echo "Modified: ${line}"
    update /etc/nsd/zonefiles/${line} > /etc/nsd/current_zones/${line}
  fi
done

# added files
comm -23 ${new_zones_file} ${old_zones_file} | while read line; do
  echo "Added: ${line}"
  update /etc/nsd/zonefiles/${line} > /etc/nsd/current_zones/${line}
done

# removed files
comm -13 ${new_zones_file} ${old_zones_file} | while read line; do
  echo "Removed: ${line}"
  rm -f /etc/nsd/current_zones/${line}
done

rm ${new_zones_file} ${old_zones_file}

rm -rf /etc/nsd/old_zones
cp -r /etc/nsd/zonefiles /etc/nsd/old_zones

rm -f /etc/nsd/zones.conf
touch /etc/nsd/zones.conf
ls /etc/nsd/current_zones | while read line
do
    echo "zone:" >> /etc/nsd/zones.conf
    echo "    name: ${line}" >> /etc/nsd/zones.conf
    echo "    zonefile: /etc/nsd/current_zones/${line}" >> /etc/nsd/zones.conf
done
