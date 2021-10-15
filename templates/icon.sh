cat templates.json |jq ".[].logo" -r |while read one; do wget $one;  done

# mkdir -p  logs; mv *.png logos; du -sh logos;

