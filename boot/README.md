# Bootstrapping created vm

Install the package containing the ovmf firmware, on Archlinux this is the `edk2-ovmf` package.

The following configuration should be added to `etc/libvirt/qemu.conf`:

```
nvram = [
   "/usr/share/edk2/ovmf/OVMF_CODE.fd:/usr/share/edk2/ovmf/OVMF_VARS.fd"
]
```

Run the script to bootstrap the vm with virtinstall

```
$ ./bootstrap.sh vm-name
