FROM archlinux:latest

LABEL MAINTAINER fdiblen
ENV container docker
ENV LC_ALL en_US.UTF-8
USER root

# PACKAGES
#===========================================
RUN rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

RUN pacman-key --refresh-keys && \
    pacman -Syyuu --noconfirm && \
    pacman -S --noconfirm --needed \
    binutils gcc fakeroot make base-devel go sudo fish \
    wget rsync unzip git vim


# ADD archep USER
#===========================================
RUN groupadd --gid 1001 archep && \
    useradd -ms /usr/bin/fish -g archep -G users,wheel archep && \
    echo "archep:archep" | chpasswd && \
    echo "archep user:";  su - archep -c id

RUN \
    sed -i /etc/sudoers -re 's/^%wheel.*/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "archep ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the archep user!"

WORKDIR /home/archep
RUN chown archep:archep -R /home/archep
RUN echo "export SHELL=/usr/bin/fish" >> /etc/profile


# SWITCH TO archep USER
#===========================================
USER archep
ENV HOME /home/archep
ENV DISPLAY :0
ENV EDITOR vim
ENV TERM xterm-256color
ENV USER archep


# INSTALL AUR HELPER
#===========================================
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && makepkg -si --noconfirm --ignorearch --cleanbuild --clean
RUN sudo rm -rf /home/archep/yay

# INSTALL PACKAGES
#===========================================
RUN yay -S --noconfirm \
    root python-uproot cern-vdt

RUN yay -S --noconfirm --batchinstall \
    geant4 \
    geant4-incldata geant4-ensdfstatedata geant4-abladata \
    geant4-particlehpdata \
    geant4-ledata geant4-neutronhpdata geant4-realsurfacedata \
    geant4-piidata geant4-levelgammadata geant4-saiddata \
    geant4-radioactivedata geant4-neutronxsdata
    # geant4-particlexsdata


# CLEAN UP
#===========================================
# RUN sudo pacman -Rs --noconfirm \
#     gcc fakeroot make go binutils

RUN sudo rm -rf /home/archep/.cache/yay/* /var/cache/pacman/pkg/*


CMD ["/usr/bin/fish"]
# ENTRYPOINT [ "executable" ]