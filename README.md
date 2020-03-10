# container-linaro-aarch64
Docker and bash script for create linaro-aarch64 compile environment

First, build the image:
```
$ ./run.sh create
```

Then you can start up new instances with:
```
$ ./run.sh -s $BUILD_SOURCE_TOP run
```
