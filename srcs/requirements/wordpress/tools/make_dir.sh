#!/bin/bash
if [ ! -d "/home/${USER}/data" ]; then
        mkdir ~/data
        mkdir ~/data/db-volume
        mkdir ~/data/www-vol
fi
