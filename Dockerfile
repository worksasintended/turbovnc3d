############################################################
# Copyright (c) 2015 Jonathan Yantis
# Released under the MIT license
# Changed heavily by Marc Marschall (propably the guy to blame when errors occour)
############################################################

# ├─yantis/archlinux-tiny
#    ├─yantis/archlinux-small
#       ├─yantis/archlinux-small-ssh-hpn
#          ├─yantis/ssh-hpn-x
#             ├─yantis/dynamic-video
#                ├─yantis/virtualgl

FROM yantis/dynamic-video
MAINTAINER Marc Marschall <find_out@your.self>
COPY turbovnc/ turbovnc
COPY .xinitrc /data/
COPY turboscript /
# Don't update
RUN pacman -Syy --noconfirm && \
    echo "root:root" | chpasswd && \
    # Install remaining packages
    pacman --noconfirm -S \
                inetutils \
                libxv \
                virtualgl \
                lib32-virtualgl \
                mesa-demos \
                lib32-mesa-demos \
		jre8-openjdk \
		turbojpeg\
		libxaw \
		libxcursor \
		libxt \
		rsync \
		make \
		gcc \
		cmake \
		fluxbox \
		rox \
		nano &&\
	cd turbovnc &&\
	cmake -DTJPEG_LIBRARY=/usr/lib/libturbojpeg.so -DTVNC_BUILDJAVA=0 -DTVNC_BUILDNATIVE=0 . && \
        make && \
	make install && \
	cd &&\
	
    # Fix VirtualGL for this hardcoded directory otherwise we can not connect with SSH.
    mkdir /opt/VirtualGL && \
    ln -s /usr/bin /opt/VirtualGL && \
    chmod 777 /data && \

    pacman -R  --noconfirm gcc make cmake &&\ 
    # Force VirtualGL to be preloaded into setuid/setgid executables (do not do if security is an issue)
   #  chmod u+s /usr/lib/librrfaker.so && chmod u+s /usr/lib64/librrfaker.so && \

    ##########################################################################
    # CLEAN UP SECTION - THIS GOES AT THE END                                #
    ##########################################################################
    localepurge && \

    # Remove man and docs
    rm -r /turbovnc && \
    rm -r /usr/share/man/* && \
    rm -r /usr/share/doc/* && \

    # Delete any backup files like /etc/pacman.d/gnupg/pubring.gpg~
    find /. -name "*~" -type f -delete && \

    bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
    paccache -rk0 >/dev/null 2>&1 &&  \
    pacman-optimize && \
    rm -r /var/lib/pacman/sync/*
    #########################################################################

CMD /turboscript
# ADD demos.sh /home/docker/demos.sh
