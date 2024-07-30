# Start from the NVIDIA CUDA base image with Ubuntu 24.04 and CUDA 12.5
FROM nvidia/cuda:12.5.1-devel-ubuntu24.04

# If you are using Linux, USERID would be important to share files between container and host.
# For Windows, Windows file has permission 777, and Windows user can read all the files.
ARG USERID=1000
ARG PASSWORD=neo
# USERNAME is just internal and fixed (to use it in chown option for ADD)
ENV USERNAME=neo
ENV SHELL=/bin/bash

USER root
RUN apt-get update \
    && apt-get install -y \
        g++ \
        make \
        bzip2 \
        wget \
        unzip \
        sudo \
        git \
        nkf \
        libpng-dev libfreetype6-dev \
        postgresql-client libpq-dev \
        sqlite3 \
        graphviz \
        python3-dev \
        python3-pip \
        python3-venv 

# Remove ubuntu user to use UID 1000 for us
RUN userdel -rf ubuntu
RUN useradd --no-log-init --create-home -ms /bin/bash --uid ${USERID} ${USERNAME}
RUN usermod -aG sudo ${USERNAME}
RUN echo "${USERNAME}:${PASSWORD}" | chpasswd

ENV CUDA_HOME=/usr/local/cuda-12.5
# for NVIDIA GeForce RTX 4090
ENV TORCH_CUDA_ARCH_LIST="8.9"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV PATH=/home/${USERNAME}/venv/bin:$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
RUN nvcc --version

USER ${USERNAME}
WORKDIR /home/${USERNAME}/
ENV LANG=en_US.UTF-8
RUN python3 -m venv venv && chmod 700 ./venv/bin/activate
RUN /home/${USERNAME}/venv/bin/pip install -U pip setuptools cmake

RUN mkdir -p /home/${USERNAME}/pythonlib \
        /home/${USERNAME}/notebook_workspace  
ADD --chown=${USERNAME}:${USERNAME} context/pythonlib /home/${USERNAME}/pythonlib
ADD --chown=${USERNAME}:${USERNAME} context/00-first.ipy /home/${USERNAME}/.ipython/profile_default/startup/
ADD --chown=${USERNAME}:${USERNAME} context/jupyter_notebook_config.py /home/${USERNAME}/.jupyter/

WORKDIR /home/${USERNAME}
# Upgrade pip and install required packages
RUN venv/bin/pip install jupyter notebook pandas
RUN venv/bin/pip install -r /home/${USERNAME}/pythonlib/requirements.txt
RUN venv/bin/jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

WORKDIR /home/${USERNAME}/notebook_workspace
EXPOSE 8888
ENV PYTHONPATH=/home/${USERNAME}/pythonlib/

CMD ["../venv/bin/jupyter", "notebook"]
