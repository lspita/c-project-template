# C project template

## Requirements

- clang, clang-format
- make
- bear <https://github.com/rizsotto/Bear/>

## Usage

To perform a full build, run

```sh
make # or make all
```

This will
1. Clean from any build files
2. Format the source code
3. Compile the project
4. Create `compile_commands.json` for clangd

You can then run the project with

```sh
make run
```
