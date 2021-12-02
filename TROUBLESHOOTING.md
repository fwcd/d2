# Troubleshooting

## Out of file descriptors

On some machines the build will fail by default since the linker tries to open a very large number of modules at once (partly due to the D2 being a pretty large project), thereby potentially exceeding the default file descriptor limit.

Try setting `ulimit -n 65536` to raise the file descriptor limit for your current shell process and its childs or, if you use `podman` to build a Docker image, pass the `--ulimit` flag, e.g. `podman build --ulimit=nofile=65536:65536 -t d2 .`
