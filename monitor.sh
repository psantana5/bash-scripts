#!/bin/bash

airmon-ng stop wlan0

service network-manager restart
