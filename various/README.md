# Various notes about k8s


## best OS for high I/O utilization nodes


| **OS**                       | **Filesystem Support**            | **Details**                                                                                      |
|------------------------------|-----------------------------------|--------------------------------------------------------------------------------------------------|
| **Ubuntu**                    | ZFS, ext4                         | Flexible, widely used with good community support. ZFS offers high performance and data integrity. |
| **CentOS / Rocky Linux / AlmaLinux** | XFS, ext4                         | Stable, enterprise-grade choice. XFS excels in high I/O workloads, great for large-scale data.     |
| **Fedora**                    | Btrfs, ext4                       | Cutting-edge kernel and file system features. Btrfs offers compression and snapshots, good for dynamic environments. |
| **Debian**                    | ext4, XFS                         | Stable, minimalistic, and flexible. XFS recommended for large, concurrent I/O operations.          |
| **CoreOS / Flatcar Linux**    | ext4                              | Container-optimized OS with minimal configuration. Suitable for Kubernetes workloads with SSD storage. |

