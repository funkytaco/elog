#!/bin/bash
sudo firewall-cmd --zone=ushr --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
