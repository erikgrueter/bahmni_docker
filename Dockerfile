FROM scratch
ADD centos-6-docker.tar.xz /

LABEL name="CentOS Base Image" \
    vendor="CentOS" \
    license="GPLv2" \
    build-date="20170406"

CMD ["/bin/bash"]

##### Reference Documents Used to Build this Dockerfile:

## Standard Install Instructions for Bahmni
   #    https://bahmni.atlassian.net/wiki/spaces/BAH/pages/33128505/Install+Bahmni+on+CentOS
   #    https://osric.com/chris/accidental-developer/2017/08/running-centos-in-a-docker-container/
   #    Mandriva Error
   #        https://talk.openmrs.org/t/error-while-installing-the-bahmni/13864
   #        https://talk.openmrs.org/t/error-while-installing-the-bahmni/13864/8

   # Ansible
   #    https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

   # IMPORANT: Changing Bahmni Config values:
   #    https://talk.openmrs.org/t/bahmni-lab-installation-error/17867/9
   # Using bahmni groups, removing certain inventories.
   #    https://talk.openmrs.org/t/can-i-use-bahmni-modules-without-openelis-and-odoo/6826
   # Connect OPenMRS to external database
   #    https://talk.openmrs.org/t/connect-openmrs-to-an-external-database/13976/2
   # Using a Fresh Database
   #    https://bahmni.atlassian.net/wiki/spaces/BAH/pages/45776970/Using+a+Fresh+Database
######

# Building and Running the Image:
# 1. Docker build -t hikma-bahmni-image
# 2. docker run --privileged -i -t <image> To go inside the image.

# Pre-requisite for the Bhamni setup.
RUN yum upgrade python-setuptools -y
RUN yum install python-setuptools -y
RUN yum install sudo -y

# Dependency for Ansible
RUN yum install selinux-policy selinux-policy-targeted -y

## Install Perl
# See deepakneupane's answerL https://talk.openmrs.org/t/upcoming-bahmni-0-91-release-help-us-to-test/18394/29
RUN yum install centos-release-scl -y
RUN yum --enablerepo=centos-sclo-rh-testing install perl516-perl-Thread-Queue.noarch perl516-perl-JSON-PP.noarch perl516-perl-DBD-Pg.x86_64 perl516-perl-Time-HiRes.x86_64 perl516-perl-Digest-SHA.x86_64 perl-DBD-Pg perl-DBI perl-Net-Daemon perl-PlRPC perl-JSON-PP -y
RUN yum install vim -y

# You'll need to install openssh to run keygen commands from ansible.
# and openSSH server. There is no mention of any of this in the Bahmni docs
RUN yum install openssh -y
RUN yum install openssh-server -y

## Install Mandriva, The HTTP worked (see Mandriva Error above, scroll down the page to Webster's answer
## If this breaks, the most likely solution is that you need to set the variable mx_download_url in etc/bahmni-installer/setup.yml
# RUN yum install http://195.220.108.108/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/mx-1.4.5-1-mdv2012.0.x86_64.rpm -y
RUN echo -e "mx_download_url: http://195.220.108.108/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/mx-1.4.5-1-mdv2012.0.x86_64.rpm" >> /etc/bahmni-installer/setup.yml

## Install Bahmni command line tool
    #   This command installs the latest command line tool,
    #   the user is presented with y/n options. The user then clicks Y to runt the installer
RUN yum install yum install https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.90-308.noarch.rpm -y
##

## Add a configuration file for the installer.
    #   This /etc/bhamni-installer/ directory
    #   might need to be created
RUN curl -L https://goo.gl/R8ekg5 >> /etc/bahmni-installer/setup.yml
##

## Set the inventory file name to local in BAHMNI_INVENTORY environment variable.
   #    This way you won't need to use the '-i local' switch every time you use the 'bahmni' command
   #    You can also configure custom inventory file instead of local.
RUN echo "export BAHMNI_INVENTORY=local" >> ~/.bashrc
RUN source ~/.bashrc
##

## Fire the Installer
RUN bahmni install

# Then start the services, might need to start individually.
# The installation should be done in about 15 - 30 minutes depending on your internet speed.
# Verify installed components using the command:
COPY start.sh /start.sh #### u can try using alternative.sh instead of start which will install bahmni during runtime.
RUN chmod +x /start.sh
CMD ["/start.sh"]
