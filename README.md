Runs ```ooniprobe run unattended``` on its own
  
Rootless and distroless

# Example dockker compose: ```run unattended```

``` yaml
services:
  ooniprobe:
    image: ghcr.io/linx-esp/ooni-probe:latest
    container_name: ooniprobe
    environment:
      - TZ=Europe/Madrid
    restart: unless-stopped
    mem_limit: 128m
    # Explicit DNS settings so host DNS doesn't affect it in case of adguard/pihole
    dns:
      - 1.1.1.1
      - 1.0.0.1
      - 2606:4700:4700::1111
      - 2606:4700:4700::1001
    # Optional, see below
    networks:
      ooni-net:
        ipv4_address: 10.14.3.253

# Optional, just for fun if you want to see results with "ooniprobe list"
    volumes:
      - tmp:/tmp

volumes:
  tmp:

# In case you have split tunnels/VPN to workaround some blocks. This makes it run in a different VLAN so you can route thorugh your ISP directly to register the blocks
# Optional of course, but consider it if the previous case applies to you
networks:
  ooni-net:
    enable_ipv6: true
    driver: macvlan
    driver_opts:
      parent: enp2s0.3  # Your network interface + .X (X being Vlan tag/number)
    ipam:
      config:
        - subnet: "10.14.3.0/24"
          ip_range: "10.14.3.0/24"
          gateway: "10.14.3.1"
```
# Example dockker compose: ```run websites``` aka `LaLiga overreach special`

``` yaml
services:
  ooniprobe-laliga:
    image: ghcr.io/linx-esp/ooni-probe:latest
    container_name: ooniprobe-laliga
    environment:
      - TZ=Europe/Madrid
    restart: no
    mem_limit: 128m
    dns:
      - 1.1.1.1
      - 1.0.0.1
      - 2606:4700:4700::1111
      - 2606:4700:4700::1001
    entrypoint:
      - /usr/local/bin/ooniprobe-linux-amd64
      - run
      - websites
      - --input-file
      - /config/urls.txt  # One URL per line, it does need "https://"
    volumes:
      - /path/tou/your/ooni-probe/config:/config
# Feel free to add any of the /tmp or VLAN stuff from the previous
```
### Example `urls.txt`
``` hosts
https://dl.tradingpaints.com
https://dl1.tradingpaints.gg
https://dl2.tradingpaints.gg
https://showroom-assets.tradingpaints.gg
https://update.tradingpaints.gg
https://fetch.tradingpaints.gg
https://www.steamgriddb.com
https://www.pcgamingwiki.com
```
