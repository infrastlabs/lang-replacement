mkdir -p logos; cd logos
cat ../templates-2.0.json |jq ".templates[].logo" -r |while read one; do wget $one;  done

# mkdir -p  logs; mv *.png logos; du -sh logos;

