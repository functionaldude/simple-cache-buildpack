# simple-cache-buildpack
A simple buildpack that symlinks a set of folders to the cache directory

# Usage
Create a `.buildpack-cache` file in the project root, and list all directories that you want to link to the CACHE_DIR.

## Example (for a gradle project)
This example caches all build folders of the project
```text
build

submodule1/build
submodule2/build
```
