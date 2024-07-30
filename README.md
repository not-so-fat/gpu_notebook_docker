# gpu_notebook_docker

Notes to enable NVIDIA GeForce RTX 4090 on the docker container.
- Windows side might be more important
    - Make sure Docker is the latest one
    - Make sure Nvidia driver is the latest one
    - Make sure WSL2 is used for Docker
    - Make sure runtime "nvidia" is used for the container
- Aligning torch cuda version was irrelevant for my environment
    - At now this installation make torch.cuda.version=12.1 while my driver is 12.5



# How to use

```
docker build -t my_notebook:latest ./
docker run --gpus all --runtime=nvidia -p 8888:8888 -v <local directory>:/home/neo/notebook_workspace my_notebook:latest
```
