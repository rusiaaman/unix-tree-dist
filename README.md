# Tree Command Line Tool - Cross-Platform Distribution

This repository contains an automated build system for the Unix `tree` command, providing pre-built binaries for multiple platforms and architectures.

## Supported Platforms

The automated build system creates binaries for the following platforms:

### Native Builds (using platform-specific runners)
- **linux-x64**: Intel/AMD 64-bit Linux
- **win32-x64**: Intel/AMD 64-bit Windows  
- **darwin-x64**: Intel 64-bit macOS
- **darwin-arm64**: ARM 64-bit macOS (Apple Silicon)

### Cross-Compiled Builds (using cross-compilation toolchains)
- **linux-arm64**: ARM 64-bit Linux (glibc)
- **linux-armhf**: ARM 32-bit Linux (glibc, hard float)
- **alpine-x64**: Intel/AMD 64-bit Alpine Linux (musl libc)
- **alpine-arm64**: ARM 64-bit Alpine Linux (musl libc)

### Planned/Experimental
- **win32-arm64**: ARM 64-bit Windows (requires LLVM-MinGW)

## Build Status

[![Build Native](https://github.com/rusiaaman/unix-tree-dist/actions/workflows/build-native.yml/badge.svg)](https://github.com/rusiaaman/unix-tree-dist/actions/workflows/build-native.yml)
[![Build Cross-Platform](https://github.com/rusiaaman/unix-tree-dist/actions/workflows/build-cross.yml/badge.svg)](https://github.com/rusiaaman/unix-tree-dist/actions/workflows/build-cross.yml)
[![Test Build](https://github.com/rusiaaman/unix-tree-dist/actions/workflows/test.yml/badge.svg)](https://github.com/rusiaaman/unix-tree-dist/actions/workflows/test.yml)

## Download

Pre-built binaries are available on the [Releases](../../releases) page. Download the appropriate binary for your platform.

### Quick Install

Use the install script to automatically download the right binary for your system:

```bash
curl -sSL https://raw.githubusercontent.com/rusiaaman/unix-tree-dist/main/install.sh | bash
```

Or download and run with options:

```bash
curl -O https://raw.githubusercontent.com/rusiaaman/unix-tree-dist/main/install.sh
chmod +x install.sh
./install.sh --help
```

## Usage

1. Download the appropriate binary for your platform from the releases page
2. Extract the archive (if .tar.gz) or use the direct binary
3. Make executable (Linux/macOS): `chmod +x tree`
4. Run: `./tree --help`

## Building from Source

To build from source:

```bash
make
```

For cross-compilation, the GitHub Actions workflow demonstrates how to build for all supported platforms.

## About Tree

Tree is a recursive directory listing command that produces a depth-indented listing of files. It's particularly useful for visualizing directory structures.

### Basic Usage Examples

```bash
# Show directory tree
tree

# Show tree with file sizes
tree -s

# Show tree with hidden files
tree -a

# Limit depth to 2 levels
tree -L 2

# Show only directories
tree -d

# Output in JSON format
tree -J
```

## Source Code

This distribution is based on the original tree source code by Steve Baker. The original source code is included in this repository.

## License

Tree is released under the GNU General Public License v2.0. See the `LICENSE` file for details.

## Automated Builds

This repository uses GitHub Actions to automatically build binaries for all supported platforms. There are two main workflows:

### Native Builds (`build-native.yml`)
- Uses platform-specific GitHub runners (Ubuntu, Windows, macOS)
- Provides the most reliable builds for primary platforms
- Triggered on tag pushes and pull requests

### Cross-Compilation Builds (`build-cross.yml`)
- Uses cross-compilation toolchains on Ubuntu runners
- Provides builds for additional architectures (ARM, Alpine)
- Triggered on tag pushes and manual dispatch

### Legacy Cross-Compilation (`build-and-release.yml`)
- Comprehensive cross-compilation setup (may have reliability issues)
- Includes experimental Windows ARM64 and macOS cross-compilation
- Available for reference and advanced users

### Build Process
The build process uses:
- Native compilers for primary platforms
- GCC cross-compilers for Linux ARM targets
- musl-cross toolchain for Alpine Linux targets
- MinGW-w64 for Windows targets

All binaries are statically linked where possible for maximum compatibility.
