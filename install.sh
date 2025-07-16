#!/bin/bash

# Tree Binary Installer Script
# This script detects your platform and downloads the appropriate tree binary

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GitHub repository information
REPO_OWNER="arusia"
REPO_NAME="unix-tree-dist"
GITHUB_API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to detect platform
detect_platform() {
    local os=$(uname -s)
    local arch=$(uname -m)
    
    # Normalize architecture names
    case $arch in
        x86_64|amd64)
            arch="x64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        armv7l|armhf)
            arch="armhf"
            ;;
        *)
            print_color $RED "Error: Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    # Detect OS and set target
    case $os in
        Linux)
            # Check if we're on Alpine Linux (musl)
            if [ -f /etc/alpine-release ]; then
                echo "alpine-${arch}"
            else
                echo "linux-${arch}"
            fi
            ;;
        Darwin)
            echo "darwin-${arch}"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "win32-${arch}"
            ;;
        *)
            print_color $RED "Error: Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Function to get latest release information
get_latest_release() {
    curl -s "${GITHUB_API_URL}/releases/latest" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4
}

# Function to download and install binary
install_binary() {
    local target=$1
    local version=$2
    local install_dir=${3:-"$HOME/.local/bin"}
    
    print_color $YELLOW "Detecting platform: $target"
    print_color $YELLOW "Latest version: $version"
    
    # Create install directory if it doesn't exist
    mkdir -p "$install_dir"
    
    # Determine binary name
    if [[ $target == win32-* ]]; then
        binary_name="tree.exe"
    else
        binary_name="tree"
    fi
    
    # Download URL
    download_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${version}/tree-${target}-${binary_name}"
    
    print_color $YELLOW "Downloading from: $download_url"
    
    # Download binary
    if curl -L -o "${install_dir}/${binary_name}" "$download_url"; then
        chmod +x "${install_dir}/${binary_name}"
        print_color $GREEN "Successfully installed tree to ${install_dir}/${binary_name}"
        
        # Check if install_dir is in PATH
        if [[ ":$PATH:" != *":${install_dir}:"* ]]; then
            print_color $YELLOW "Note: ${install_dir} is not in your PATH."
            print_color $YELLOW "Add it to your PATH or run: ${install_dir}/${binary_name}"
        fi
        
        # Test the binary
        if "${install_dir}/${binary_name}" --version > /dev/null 2>&1; then
            print_color $GREEN "Installation verified successfully!"
        else
            print_color $YELLOW "Warning: Binary installed but failed verification test"
        fi
    else
        print_color $RED "Failed to download binary"
        exit 1
    fi
}

# Main function
main() {
    print_color $GREEN "Tree Binary Installer"
    print_color $GREEN "====================="
    
    # Parse command line arguments
    local install_dir="$HOME/.local/bin"
    local force_target=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-dir)
                install_dir="$2"
                shift 2
                ;;
            --target)
                force_target="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --install-dir DIR   Installation directory (default: $HOME/.local/bin)"
                echo "  --target TARGET     Force specific target (e.g., linux-x64, darwin-arm64)"
                echo "  --help              Show this help"
                echo ""
                echo "Supported targets:"
                echo "  linux-x64, linux-arm64, linux-armhf"
                echo "  alpine-x64, alpine-arm64"
                echo "  win32-x64, win32-arm64"
                echo "  darwin-x64, darwin-arm64"
                exit 0
                ;;
            *)
                print_color $RED "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Detect platform or use forced target
    if [ -n "$force_target" ]; then
        target="$force_target"
        print_color $YELLOW "Using forced target: $target"
    else
        target=$(detect_platform)
    fi
    
    # Get latest release
    print_color $YELLOW "Checking for latest release..."
    version=$(get_latest_release)
    
    if [ -z "$version" ]; then
        print_color $RED "Failed to get latest release information"
        exit 1
    fi
    
    # Install binary
    install_binary "$target" "$version" "$install_dir"
}

# Run main function
main "$@"
