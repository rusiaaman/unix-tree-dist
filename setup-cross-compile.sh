#!/bin/bash

# Setup script for cross-compilation toolchains
# This script helps developers set up the necessary toolchains for cross-compiling tree

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_color() {
    printf "${1}${2}${NC}\n"
}

print_section() {
    echo
    print_color $GREEN "=========================================="
    print_color $GREEN "$1"
    print_color $GREEN "=========================================="
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_color $GREEN "✓ $1 is installed"
        return 0
    else
        print_color $RED "✗ $1 is not installed"
        return 1
    fi
}

install_ubuntu_packages() {
    print_section "Installing Ubuntu/Debian packages"
    
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        gcc-multilib \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnueabihf \
        libc6-dev-i386 \
        libc6-dev-arm64-cross \
        libc6-dev-armhf-cross \
        curl \
        xz-utils \
        git \
        cmake \
        clang \
        llvm
}

install_musl_cross() {
    print_section "Installing musl cross-compilers"
    
    local install_dir="/usr/local"
    local temp_dir="/tmp/musl-cross"
    
    mkdir -p "$temp_dir"
    
    # Download and install x86_64-linux-musl
    print_color $YELLOW "Installing x86_64-linux-musl cross-compiler..."
    curl -L https://musl.cc/x86_64-linux-musl-cross.tgz | tar -xzf - -C "$temp_dir"
    sudo cp -r "$temp_dir/x86_64-linux-musl-cross"/* "$install_dir/"
    
    # Download and install aarch64-linux-musl
    print_color $YELLOW "Installing aarch64-linux-musl cross-compiler..."
    curl -L https://musl.cc/aarch64-linux-musl-cross.tgz | tar -xzf - -C "$temp_dir"
    sudo cp -r "$temp_dir/aarch64-linux-musl-cross"/* "$install_dir/"
    
    # Create symlinks for easier access
    sudo ln -sf "${install_dir}/bin/x86_64-linux-musl-gcc" "${install_dir}/bin/x86_64-alpine-linux-musl-gcc"
    sudo ln -sf "${install_dir}/bin/aarch64-linux-musl-gcc" "${install_dir}/bin/aarch64-alpine-linux-musl-gcc"
    
    rm -rf "$temp_dir"
    print_color $GREEN "musl cross-compilers installed successfully"
}


install_osxcross() {
    print_section "Installing OSXCross for macOS"
    
    local install_dir="/usr/local"
    local temp_dir="/tmp/osxcross"
    
    print_color $YELLOW "Cloning OSXCross..."
    git clone https://github.com/tpoechtrager/osxcross.git "$temp_dir"
    
    cd "$temp_dir"
    
    # Create tarballs directory
    mkdir -p tarballs
    
    print_color $YELLOW "Downloading macOS SDK..."
    curl -L -o tarballs/MacOSX12.3.sdk.tar.xz https://github.com/joseluisq/macosx-sdks/releases/download/12.3/MacOSX12.3.sdk.tar.xz
    
    print_color $YELLOW "Building OSXCross (this may take a while)..."
    UNATTENDED=1 OSX_VERSION_MIN=10.12 ./build.sh
    
    print_color $YELLOW "Installing OSXCross..."
    sudo cp -r target/* "$install_dir/"
    
    # Create symlinks
    sudo ln -sf "${install_dir}/bin/x86_64-apple-darwin21-clang" "${install_dir}/bin/x86_64-apple-darwin21-clang"
    sudo ln -sf "${install_dir}/bin/arm64-apple-darwin21-clang" "${install_dir}/bin/aarch64-apple-darwin21-clang"
    
    cd - > /dev/null
    rm -rf "$temp_dir"
    print_color $GREEN "OSXCross installed successfully"
}

verify_toolchains() {
    print_section "Verifying installed toolchains"
    
    local toolchains=(
        "gcc"
        "aarch64-linux-gnu-gcc"
        "arm-linux-gnueabihf-gcc"
        "x86_64-linux-musl-gcc"
        "aarch64-linux-musl-gcc"
        "x86_64-apple-darwin21-clang"
        "aarch64-apple-darwin21-clang"
    )
    
    for tool in "${toolchains[@]}"; do
        check_command "$tool"
    done
}

test_build() {
    print_section "Testing cross-compilation"
    
    print_color $YELLOW "Testing native build..."
    make clean &> /dev/null || true
    if make; then
        print_color $GREEN "✓ Native build successful"
        ./tree --version
    else
        print_color $RED "✗ Native build failed"
    fi
    
    print_color $YELLOW "Testing cross-compilation with Makefile.cross..."
    
    local targets=(
        "linux-x64"
        "linux-arm64"
        "linux-armhf"
        "alpine-x64"
        "alpine-arm64"
        "darwin-x64"
        "darwin-arm64"
    )
    
    for target in "${targets[@]}"; do
        make -f Makefile.cross clean &> /dev/null || true
        if make -f Makefile.cross "$target"; then
            print_color $GREEN "✓ $target build successful"
        else
            print_color $RED "✗ $target build failed"
        fi
    done
}

main() {
    print_color $GREEN "Tree Cross-Compilation Setup Script"
    print_color $GREEN "==================================="
    
    if [ "$EUID" -eq 0 ]; then
        print_color $RED "Error: Please don't run this script as root"
        print_color $YELLOW "The script will use sudo when needed"
        exit 1
    fi
    
    # Check if we're on a supported system
    if [ ! -f /etc/debian_version ] && [ ! -f /etc/ubuntu_version ]; then
        print_color $YELLOW "Warning: This script is designed for Ubuntu/Debian systems"
        print_color $YELLOW "You may need to adapt the package installation commands"
    fi
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-packages)
                skip_packages=1
                shift
                ;;
            --skip-musl)
                skip_musl=1
                shift
                ;;
            --skip-llvm-mingw)
                skip_llvm_mingw=1
                shift
                ;;
            --skip-osxcross)
                skip_osxcross=1
                shift
                ;;
            --test-only)
                test_only=1
                shift
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --skip-packages    Skip Ubuntu/Debian package installation"
                echo "  --skip-musl        Skip musl cross-compiler installation"
                echo "  --skip-osxcross    Skip OSXCross installation"
                echo "  --test-only        Only run tests, don't install anything"
                echo "  --help             Show this help"
                exit 0
                ;;
            *)
                print_color $RED "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [ "$test_only" = "1" ]; then
        verify_toolchains
        test_build
        exit 0
    fi
    
    # Install components
    [ "$skip_packages" != "1" ] && install_ubuntu_packages
    [ "$skip_musl" != "1" ] && install_musl_cross
    [ "$skip_osxcross" != "1" ] && install_osxcross
    
    # Verify and test
    verify_toolchains
    test_build
    
    print_section "Setup Complete"
    print_color $GREEN "Cross-compilation toolchains have been installed successfully!"
    print_color $YELLOW "You can now use 'make -f Makefile.cross <target>' to build for different platforms"
    print_color $YELLOW "Example: make -f Makefile.cross linux-arm64"
}

main "$@"
