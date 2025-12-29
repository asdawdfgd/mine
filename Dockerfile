FROM pufferpanel/pufferpanel:latest

# الطريقة الخاصة بك ممتازة وتفي بالغرض
ENTRYPOINT ["/bin/sh", "-c", "/pufferpanel/pufferpanel user add --name anvlo --password anvlo123 --email sonk12122@gmail.com --admin || true && /pufferpanel/pufferpanel run"]
