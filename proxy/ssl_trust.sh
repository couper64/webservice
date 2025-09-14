#!/bin/bash

# Add certificates on the client machine, e.g. Ubuntu. And, restart your browser.

sudo cp proxy/ssl/server.crt /usr/local/share/ca-certificates/server.crt
sudo update-ca-certificates
