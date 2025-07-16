# Development Guide

This guide covers how to develop and build the Tree command for multiple platforms.

## Quick Start

### Native Build
```bash
make
./tree --version
```

### Cross-compilation Setup
```bash
# Install all cross-compilation toolchains (Ubuntu/Debian)
sudo ./setup-cross-compile.sh

# Or install specific components
sudo ./setup-cross-compile.sh --skip-osxcross  # Skip macOS toolchain
```

### Building for Specific Platforms
```bash
# Using the cross-compilation Makefile
make -f Makefile.cross linux-arm64
make -f Makefile.cross win32-x64
make -f Makefile.cross darwin-arm64

# Or build all targets
make -f Makefile.cross all-targets
```

## GitHub Actions Workflows

### Native Build Workflow (`build-native.yml`)
- Builds on native runners (Ubuntu, Windows, macOS)
- Most reliable for primary platforms
- Triggered on tag pushes and pull requests

### Cross-compilation Workflow (`build-cross.yml`)
- Cross-compiles on Ubuntu for additional architectures
- Builds ARM Linux and Alpine Linux variants
- Triggered on tag pushes and manual dispatch

### Test Workflow (`test.yml`)
- Basic build and functionality tests
- Runs on every push to main branch

## Development Setup

### Prerequisites
- C compiler (GCC, Clang)
- Make
- Git

### Building
```bash
# Clone the repository
git clone https://github.com/rusiaaman/unix-tree-dist.git
cd unix-tree-dist

# Build
make

# Test
./tree --version
./tree -L 2 .
```

### Cross-compilation
```bash
# Install cross-compilation toolchains
sudo ./setup-cross-compile.sh

# Build for specific targets
make -f Makefile.cross TARGET=linux-arm64
make -f Makefile.cross TARGET=alpine-x64
```

## Supported Targets

### Native Builds
- `linux-x64`: Native Linux x86_64
- `win32-x64`: Native Windows x86_64
- `darwin-x64`: Native macOS x86_64
- `darwin-arm64`: Native macOS ARM64

### Cross-compiled Builds
- `linux-arm64`: ARM64 Linux (glibc)
- `linux-armhf`: ARM32 Linux (glibc, hard float)
- `alpine-x64`: Alpine Linux x86_64 (musl)
- `alpine-arm64`: Alpine Linux ARM64 (musl)

### Experimental
- `win32-arm64`: Windows ARM64 (requires LLVM-MinGW)

## Testing

### Local Testing
```bash
# Test native build
make && ./tree --version

# Test cross-compilation
make -f Makefile.cross linux-arm64
file tree  # Should show ARM64 binary
```

### CI Testing
- Push to main branch triggers test workflow
- Tag push triggers release builds
- Pull requests trigger test builds

## Release Process

1. Update version in source code if needed
2. Commit changes
3. Create and push a tag:
   ```bash
   git tag v2.2.1-release
   git push origin v2.2.1-release
   ```
4. GitHub Actions will automatically build and create a release

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## Troubleshooting

### Cross-compilation Issues
- Check if the cross-compiler is installed: `which <compiler>`
- Verify the target triplet matches your system
- Check the setup script logs for errors

### Build Failures
- Ensure all dependencies are installed
- Check compiler version compatibility
- Review the GitHub Actions logs for detailed error messages

### Missing Binaries
- Some platforms may not have working cross-compilers
- Check the release page for available binaries
- Consider building on the target platform directly

## File Structure

```
├── .github/workflows/     # GitHub Actions workflows
├── doc/                   # Documentation
├── *.c, *.h              # Source code
├── Makefile              # Standard build
├── Makefile.cross        # Cross-compilation build
├── setup-cross-compile.sh # Toolchain setup script
├── install.sh            # User installation script
└── README.md             # Main documentation
```

## License

Tree is licensed under the GNU General Public License v2.0. See LICENSE file for details.
