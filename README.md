# Tree Command Line Tool - Cross-Platform Distribution

This repository contains an automated build system for the Unix `tree` command, providing pre-built binaries for multiple platforms and architectures.

## Supported Platforms

The automated build system creates binaries for the following platforms:

### Linux
- **linux-x64**: Intel/AMD 64-bit Linux (glibc)
- **linux-arm64**: ARM 64-bit Linux (glibc)
- **linux-armhf**: ARM 32-bit Linux (glibc, hard float)

### Alpine Linux
- **alpine-x64**: Intel/AMD 64-bit Alpine Linux (musl libc)
- **alpine-arm64**: ARM 64-bit Alpine Linux (musl libc)

### Windows
- **win32-x64**: Intel/AMD 64-bit Windows
- **win32-arm64**: ARM 64-bit Windows

### macOS
- **darwin-x64**: Intel 64-bit macOS
- **darwin-arm64**: ARM 64-bit macOS (Apple Silicon)

## Download

Pre-built binaries are available on the [Releases](../../releases) page. Download the appropriate binary for your platform.

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

This repository uses GitHub Actions to automatically build binaries for all supported platforms. The workflow is triggered on:

- Push to tags starting with 'v' (creates a release)
- Pull requests to main branch (for testing)
- Manual workflow dispatch

The build process uses various cross-compilation toolchains:
- GCC cross-compilers for Linux ARM targets
- MinGW-w64 for Windows targets
- LLVM-MinGW for Windows ARM64 targets
- OSXCross for macOS targets
- musl-cross for Alpine Linux targets

All binaries are statically linked where possible for maximum compatibility.
