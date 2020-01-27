#!/bin/bash

openssl req -new -x509 -newkey rsa:2048 -keyout ./nvidia.key -outform DER -out ./nvidia.der -nodes -days 36500 -subj "/CN=Graphics Drivers"
