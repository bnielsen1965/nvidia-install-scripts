#!/bin/bash

PRIVATE_KEY="/root/nvidia/nvidia.key"
PUBLIC_KEY="/root/nvidia/nvidia.der"

NVIDIA_INSTALLER="$1"

if [ -z "$NVIDIA_INSTALLER" ]; then
	echo "Specify installer to use"
	exit 1
fi

if [ ! -f "./$NVIDIA_INSTALLER" ]; then
	echo "Install not found, $NVIDIA_INSTALLER"
	exit 1
fi

if [ ! -f "$PRIVATE_KEY" ]; then
	echo "Private key not found, $PRIVATE_KEY"
	exit 1
fi

if [ ! -f "$PUBLIC_KEY" ]; then
	echo "Public key not found, $PUBLIC_KEY"
	exit 1
fi

echo "Running installer $NVIDIA_INSTALLER"

./$NVIDIA_INSTALLER \
--module-signing-secret-key="$PRIVATE_KEY" \
--module-signing-public-key="$PUBLIC_KEY"

