FROM nvidia/cuda:11.2.0-cudnn8-devel-ubuntu20.04

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Asia/Shanghai apt-get -y install tzdata

RUN apt-get install mariadb-server libmariadbclient-dev libmariadb-dev -y

ENV MUNGEUSER 966
ENV SLURMUSER 967
ENV SLURM_ROOT root

RUN groupadd -g ${MUNGEUSER} munge
RUN useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u ${MUNGEUSER} -g munge  -s /sbin/nologin munge

RUN groupadd -g ${SLURMUSER} slurm
RUN useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u ${SLURMUSER} -g slurm  -s /bin/bash slurm

RUN apt-get install munge libmunge-dev libmunge2 -y

RUN apt-get install python3 gcc openssl numactl hwloc lua5.3 man2html build-essential \
    make libpam0g-dev -y

RUN apt-get install openssh-server wget bzip2 ca-certificates curl git vim  htop xxd bc parallel cmake mpich \
    libeigen3-dev  libxml2-dev python3 libfontconfig1 libxrender1 -y

RUN apt-get install sudo build-essential byobu environment-modules -y

# for libGL.so.1
RUN apt-get install libgl1-mesa-glx -y

# RUN apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/slurm

COPY slurm-21.08.6 /tmp/slurm

WORKDIR /tmp/slurm
RUN ./configure --prefix=/usr --sysconfdir=/etc/slurm  \
    --enable-pam --with-pam_dir=/lib/x86_64-linux-gnu/security/ --without-shared-libslurm && \
    make -j8 && \
    make contrib -j8 && \
    make install -j8

RUN rm -rf /tmp/*

RUN mkdir -p /etc/munge
COPY munge /etc/munge

RUN mkdir -p /etc/slurm
COPY slurm /etc/slurm

WORKDIR /var/spool

RUN mkdir -p slurm
RUN chown slurm:slurm slurm
RUN chmod 755 slurm
RUN mkdir -p slurm/slurmctld
RUN chown slurm:slurm slurm/slurmctld
RUN chmod 755 slurm/slurmctld
RUN mkdir -p slurm/cluster_state
RUN chown slurm:slurm slurm/cluster_state

WORKDIR /var/log

RUN touch slurmctld.log
RUN chown slurm:slurm slurmctld.log
RUN touch slurm_jobacct.log slurm_jobcomp.log
RUN chown slurm: slurm_jobacct.log slurm_jobcomp.log
RUN touch slurmdbd.log
RUN chown slurm:slurm slurmdbd.log

WORKDIR /var/run
RUN touch slurmctld.pid slurmd.pid
RUN chown slurm:slurm slurmctld.pid slurmd.pid
RUN mkdir -p /etc/slurm/prolog.d /etc/slurm/epilog.d 

WORKDIR /etc/slurm

# RUN chown slurm:slurm slurmdbd.conf
# RUN chmod 600 slurmdbd.conf

RUN mkdir -p /var/spool/slurm/slurmd
RUN chown slurm:slurm /var/spool/slurm/slurmd

RUN mkdir -p /var/spool/slurm/node_state
RUN chown slurm:slurm /var/spool/slurm/node_state

RUN mkdir -p /var/spool/slurm/resv_state
RUN chown slurm:slurm /var/spool/slurm/resv_state

RUN mkdir -p /var/spool/slurm/job_state
RUN chown slurm:slurm /var/spool/slurm/job_state

RUN chown munge:munge /etc/munge/munge.key
RUN chmod 400 /etc/munge/munge.key

RUN useradd -m admin -s /usr/bin/bash -d /home/admin && echo "admin:admin" | chpasswd && adduser admin sudo && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# RUN ln -s /usr/share/modules/init/profile.sh /etc/profile.d/modules.sh
RUN echo "\n# For initiating Modules" | tee -a /etc/bash.bashrc > /dev/null 
RUN echo ". /etc/profile.d/modules.sh" | tee -a /etc/bash.bashrc > /dev/null
RUN echo "export MODULEPATH=/public/software/modules" | tee -a /etc/bash.bashrc > /dev/null

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libseccomp-dev \
    libglib2.0-dev \
    pkg-config \
    squashfs-tools \
    cryptsetup \
    runc

WORKDIR /public/home/test

COPY singularity-ce_3.10.4-focal_amd64.deb /public/home/test

RUN dpkg -i singularity-ce_3.10.4-focal_amd64.deb

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm singularity-ce_3.10.4-focal_amd64.deb

EXPOSE 6817 6818 6819 22

ENTRYPOINT ["/etc/slurm/docker-entrypoint.sh"]

