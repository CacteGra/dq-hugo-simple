---
title: "Llama.cpp on Ubuntu using Vulkan SDK for AMD Integrated GPU"
date: 2026-02-11
draft: false
tags: ["dev", "llm", "linux"]
categories: ["tutorial"]
description: "Optimal install and run to serve a LLM through llama.cpp."
---
## Configuring your Ubuntu sever
- Install Ubuntu server with minimal configuration.
- If it is not plugged in with Ethernet, add WiFi during the installation.
- I have a system running at less that a gigabyte of memory usage, and we need every byte we can scrap for our LLM.
- Make sure your system is up to date with latest packages:
  ````
  sudo apt update && sudo apt upgrade -y
  ````
- ## Installing necessary tools and dependencies
- ### Basic packages for Llama.cpp and Vulkan support for your iGPU
	- Install necessary packages for install and to run LLama.cpp:
	  ````
	  sudo apt install -y build-essential cmake git libvulkan-dev vulkan-tools mesa-vulkan-drivers python3 python3-pip jq curl libssl-dev libcurl4-openssl-dev
	  ```
	- Check your GPU with:
	  ````
	  vulkaninfo | grep deviceName
	  ````
	- Vulkan does not release the vulkan-sdk packages for Ubuntu anymore. We have installed dependencies, but lack the real thing.
	- We have to manually run the SDK installer.
	- Go to https://vulkan.lunarg.com/sdk/home#linux and download the tarball (**.tar.xz**) file.
	- Compression utility xz should be installed, if not:
	  ````
	  sudo apt install xz-utils
	  ```
	- Add every packages necessary to install the SDK (some of them, like cmake, we have already installed earlier, but I include anyway just in case):
	  ````
	  sudo apt-get install libglm-dev cmake libxcb-dri3-0 libxcb-present0 libpciaccess0 \
	  libpng-dev libxcb-keysyms1-dev libxcb-dri3-dev libx11-dev g++ gcc \
	  libwayland-dev libxrandr-dev libxcb-randr0-dev libxcb-ewmh-dev \
	  git python-is-python3 bison libx11-xcb-dev liblz4-dev libzstd-dev \
	  ocaml-core ninja-build pkg-config libxml2-dev wayland-protocols python3-jsonschema \
	  clang-format qtbase5-dev qt6-base-dev
	  ````
	- Check the installer for conformity and see if the shasum matches the one on the website:
	  ````
	  sha256sum vulkansdk-linux-x86_64-1.vesion.version.version.tar.xz
	  ```
	- Decompress the tarball
	  `tar xf vulkansdk-linux-x86_64-1.vesion.version.version.tar.xz`
	- Install more dependencies
	  ````
	  sudo apt install libxcb-xinput0 libxcb-xinerama0 libxcb-cursor-dev
	  ````
	- Setup environment variables:
	  ````
	  source ~/vulkan/1.version.version.version/setup-env.sh
	  ```
	- Edit .profile file in order to export the environment variables for every shell session and add the following line at the end of the file:
	  `source $HOME/vulkan/1.version.version.version/setup-env.sh`
	- Copy files to system:
	  `sudo cp -r $VULKAN_SDK/include/vulkan/ /usr/local/include/`
	- `sudo cp -P $VULKAN_SDK/lib/libvulkan.so* /usr/local/lib/`
	- `sudo cp $VULKAN_SDK/lib/libVkLayer_*.so /usr/local/lib/`
	- `sudo mkdir -p /usr/local/share/vulkan/explicit_layer.d`
	- `sudo cp $VULKAN_SDK/share/vulkan/explicit_layer.d/VkLayer_*.json /usr/local/share/vulkan/explicit_layer.d`
	- Refresh system loader
	  `sudo ldconfig`
	- Verify installation with the following command:
	  ````
	  vulkaninfo
	  ```
- ### Cloning and building Llama.cpp
	- Clone llama.cpp:
	  ````
	  cd ~
	  git clone https://github.com/ggerganov/llama.cpp.git
	  cd llama.cpp
	  ````
	- Build llama.cpp:
	  ````
	  cd ~
	  cd llama.cpp
	  mkdir build && cd build
	  cmake .. -DCMAKE_BUILD_TYPE=Release -DGGML_VULKAN=ON -DGGML_NATIVE=ON -DCMAKE_C_FLAGS="-march=native -O3 -ffast-math -fno-finite-math-only" -DCMAKE_CXX_FLAGS="-march=native -O3 -ffast-math -fno-finite-math-only"
	  cmake --build . --config Release -j$(nproc)
	  ````
- ### Running Llama.cpp
	- Add a model:
	  ```
	  cd ../models
	  wget https://huggingface.co/unsloth/Ministral-3-14B-Instruct-2512-GGUF/resolve/main/Ministral-3-14B-Instruct-2512-Q4_K_M.gguf
	  ```
	- ```
	  cd ~/llama.cpp/build/bin
	  ./llama-server -m ~/llama.cpp/models/Ministral-3-14B-Instruct-2512-Q4_K_M.gguf -ngl 99 -cmoe -fa auto -c 16384 -ub 2048 -b 2048 -t 8 --host 0.0.0.0 --port 8080
	  ```
	- For connecting inside a local network use your machine's IP address after **--host**.
- ### Thanks to [Siarhei Berdachuk](https://berdachuk.com/ai/local-ai-on-mini-pcs-a-simple-guide-for-amd-systems) for the tutorial.