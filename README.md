<!--
# This file is part of chown.
#
#    chown is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    chown is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with chown .  If not, see <http://www.gnu.org/licenses/>.
-->
# Synopsis

This image kludgily solves https://github.com/moby/moby/issues/2259 for certain cases.

The problem is that we can not - in general - mount a volume with other than root ownership.
If we do `VOLUME=$(docker volume create) && docker run -it --rm ${VOLUME}:/home/user alpine:3.4 sh` then '/home/user' is owned by root when we probably intended for it to be owned by 'user'.

However, if we do `VOLUME=$(docker volume create) && docker run --it --rm --volume ${VOLUME}:/srv wildwarehouse/chown:0.0.0 && docker run -it --rm ${VOLUME}:/home/user alpine:3.4 sh`,
then '/home/user' should be owned by 'user' instead of root.

This only works for user 'user'.
This would not work if we wanted a volume to be owned by user 'apache'.

# Usage

```
ALPHA=$(docker volume create) &&
    BETA=$(docker volume create) &&
    docker run --interactive --tty --rm --volume ${ALPHA}:/srv wildwarehouse/chown:0.0.0 &&
    docker run --interactive --tty --rm --volume ${ALPHA}:/srv/alpha wildwarehouse/fedora:0.0.0 touch /srv/alpha/good &&
    ! docker run --interactive --tty --rm --volume ${BETA}:/srv/beta wildwarehouse/fedora:0.0.0 touch /srv/beta/bad &&
    echo SUCCESS

```

Notice that the 5th line generates an error.
The script nonetheless proceeds because of the `!` operator.
(It would stop if the line did not generate an error.)

This is important because it tells you that the 'chown' image did its job and allowed the touch to work in 'ALPHA' where it failed in 'BETA'.

