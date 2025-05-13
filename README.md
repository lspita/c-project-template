# C project template

This is a template C project managed with CMake.

## Usage
Edit the [config.cmake](./config.cmake) file to adapt the template to your project
- [`src`](./src/): main sources directory. Contains C sources and private header files. Has access to `include` directory.
- [`include`](./include/): public headers directory. Contains the public header files of the project. Use a `<project-name>` directory inside instead of storing the header files directly inside.
- [`test`](./test/) tests directory. All `.test.c` sources are treated as test executables, while normal C sources are aviable to use. Has access to `include` and `src` directories.

> [!IMPORTANT]
> The template was tested using clang, but should be customizable using CMake presets.
