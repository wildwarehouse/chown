#!/bin/sh

ls -1 /srv | while read DIR
do
    chown user:user /srv/${DIR}
done