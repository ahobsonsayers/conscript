x11docker --xorg \
  --vt 1 \
  --alsa \
  --wm=none \
  --gpu \
  --home=/home/arranhs/kodi \
  -- \
  -v /home/arranhs:/media:ro \
  -p 1234:8080 \
  -p 9777:9777/udp \
  -- \
  erichough/kodi
