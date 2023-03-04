#!/usr/bin/env bash
# Credits to Mark
# Purpose: Deletes network namespaces for all bots.

bot_number=$1
for ((i = 0; i < bot_number; ++i)); do
  NS="ns$i"
  VETH="veth$i"
  VPEER_ADDR="10.200.$i.2"
  INTERFACE=$(route -n | grep '^0\.0\.0\.0' | grep -o '[^ ]*$' | head -1)

  ip netns delete $NS
  ip link del $VETH

  iptables -t nat -D POSTROUTING -s ${VPEER_ADDR}/24 -o "$INTERFACE" -j MASQUERADE
  iptables -D FORWARD -i "$INTERFACE" -o ${VETH} -j ACCEPT
  iptables -D FORWARD -o "$INTERFACE" -i ${VETH} -j ACCEPT
done
