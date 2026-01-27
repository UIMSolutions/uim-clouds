
# UIM Clouds Framework

A collection of D language libraries for cloud, container, and virtualization management, built on over eight years of experience.

## Overview

This repository provides a modular framework for interacting with a variety of cloud, container, and virtualization technologies, including:

- **Docker**: Manage containers, images, volumes, and networks via the Docker API.
- **Kubernetes**: Interact with Kubernetes clusters, manage resources, and watch for events.
- **KVM**: Control KVM/libvirt domains, storage, and networks.
- **LXC**: Manage Linux containers, images, networks, and storage.
- **Podman**: Work with Podman containers and pods using the Podman API.
- **VirtualBox**: Control VirtualBox VMs, snapshots, and storage.
- **Virtualization**: Unified interface for KVM, QEMU, Xen, and more.
- **Linux Namespaces**: Inspect and manage Linux namespaces for process isolation.
- **Cgroups**: (see cgroups/README.md for details)

Each module is a standalone DUB package, but all share a common design and can be used together.

## Features

- Modern D language APIs for cloud and virtualization
- Async HTTP clients (vibe.d)
- JSON serialization/deserialization
- Resource lifecycle management (create, list, update, delete)
- Real-world usage examples in each submodule

## Getting Started

Each subdirectory contains its own README with usage, build, and test instructions. See, for example:

- [docker/README.md](docker/README.md)
- [kubernetes/README.md](kubernetes/README.md)
- [kvm/README.md](kvm/README.md)
- [lxc/README.md](lxc/README.md)
- [podman/README.md](podman/README.md)
- [virtualbox/README.md](virtualbox/README.md)
- [virtualization/README.md](virtualization/README.md)
- [namespaces/README.md](namespaces/README.md)

## License

Apache 2.0
