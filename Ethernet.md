

## Linux commands

Info comes from [here](https://www.cyberciti.biz/faq/linux-change-the-speed-and-duplex-settings-of-an-ethernet-card/)

Current port settings:

```
ethtool eth0
```

Change port settings:

```
sudo ethtool -s eth0 speed 1000 duplex full
```

