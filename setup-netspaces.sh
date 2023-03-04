#!/usr/bin/env bash
# Credits to Mark
# Purpose: Creates network namespaces for all bots.

bot_number=$1
for ((i = 0; i < bot_number; ++i)); do
  NS="ns$i"
  VETH="veth$i"
  VPEER="vpeer$i"
  VETH_ADDR="10.200.$i.1"
  VPEER_ADDR="10.200.$i.2"
  INTERFACE=$(route -n | grep '^0\.0\.0\.0' | grep -o '[^ ]*$' | head -1)

  # Remove namespace if it exists.
  ip netns del $NS &>/dev/null
  ip link del ${VETH} &>/dev/null

  # Create namespace
  ip netns add $NS

  # Create veth link.
  ip link add ${VETH} type veth peer name ${VPEER}

  # Add peer-1 to NS.
  ip link set ${VPEER} netns $NS

  # Setup IP address of ${VETH}.
  ip addr add ${VETH_ADDR}/24 dev ${VETH}
  ip link set ${VETH} up

  # Setup IP ${VPEER}.
  ip netns exec $NS ip addr add ${VPEER_ADDR}/24 dev ${VPEER}
  ip netns exec $NS ip link set ${VPEER} up
  ip netns exec $NS ip link set lo up
  ip netns exec $NS ip route add default via ${VETH_ADDR}

  # Enable masquerading of 10.200.1.0.
  iptables -t nat -A POSTROUTING -s ${VPEER_ADDR}/24 -o "$INTERFACE" -j MASQUERADE

  iptables -A FORWARD -i "$INTERFACE" -o ${VETH} -j ACCEPT
  iptables -A FORWARD -o "$INTERFACE" -i ${VETH} -j ACCEPT
done
