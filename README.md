## Venom Linux iso/rootfs creator

This repository contain utilities for Venom Linux:

* mkiso (create venom's iso)
* mkrootfs (create venom's updated image tarball)

#### Dependencies

Host:

* squashfs-tools (to create venom squasfs filesystem for the iso)
* libisoburn (use xorriso to create iso)

Venom rootfs (incase you modified it):

* [mkinitramfs](https://github.com/emmett1/mkinitramfs) (to create initrd)
* [scratchpkg](https://github.com/emmett1/scratchpkg) (to install/upgrade package before create the iso)
* [rc](https://github.com/emmett1/rc) (init system used by Venom Linux)
* squashfs-tools (to unsquash venom filesystem to disk while installing)
* dialog (required by the installer)

Note: squashfs-tools and dialog will get installed by default before the iso is created, it needed for the installer.

### mkiso

By default, `mkiso` script will download venom rootfs base image from [here](https://github.com/emmett1/venom/releases)
to create the iso if not found in the current directory (venom-rootfs.txz) but you can use custom venom image tarball or
venom filesystem directory (in case you need customize it first). Eg: `# ./mkiso mycustomvenom.txz` or `# ./mkiso /path/to/venomfs`.


    Usage:
      mkiso [options] <venom source>
  
    Options:
      -p <path>           set packages cache directory
      -s <path>           set sources cache directory
      -P <pkg1 pkgN ...>  package to install into iso
      -i <initrd>         use custom initrd
      -k <kernel>         use custom kernel
      -o <name.iso>       output name for iso
      -c <file.preset>    use preset file
      -h                  show this help msg
      
#### Example

Create base venom iso with custom output name

    # ./mkiso -o venomlinux.iso
    
Create venom iso with some extra package

    # ./mkiso -P nano mc xorg
    
Create venom iso using your own created initrd/kernel (make sure you know what you doing)

    # ./mkiso -i /path/to/initrd -k /path/to/kernel
    
Create venom iso using preset file

    # ./mkiso -c file.preset
    
Create venom iso using existing venom rootfs

    # ./mkiso custom-venom-rootfs.txz
    
Create venom iso using custom packages path (its save you compile time, if you already use Venom Linux as host OS :D)
    
    # ./mkiso -p /path/to/packagedir
    
You can use these options altogether example:

    # ./mkiso -p /var/cache/packages -s /var/cache/sources -P xorg xfce4 lxdm -o venom-xfce4-custom.iso
    
Note: Be careful when adding custom packages, adding non-existing packages may cause build error. Look [here](https://github.com/emmett1/ports) for exist custom packages.
    
#### Preset

Preset file is file contain variable that will get source by `mkiso` script to create the iso. Preset file should
suffix with `.preset`. You can set custom iso name and needed package to include into the iso (more options will
come soon :D) in the preset file. See existing preset file as example to create your own. Be careful when set the variable, it may interfere
the mkiso script's variable.

### mkrootfs

`mkrootfs` is a script to create venom's updated base image tarball. `mkrootfs` script will remove orphan package and keep
only base and linux package (and its dependencies) in the image tarball.

    Usage:
      mkrootfs [options] <venom source>
  
    Options:
      -p <path>           set packages cache directory
      -s <path>           set sources cache directory
      -o <name.txz>       output name for rootfs
      -h                  show this help msg
      
#### Example

Create the image tarball with custom name

    # ./mkrootfs -o venom-updated.txz
    
Create the image tarball using custom packages path (its save you compile time, if you already use Venom Linux as host OS :D)
    
    # ./mkrootfs -p /path/to/packagedir
    
### Some notes

* default password for 'root' is 'root' and default user is 'venom' with password 'venom'.
* you can change default password and user in 'virootfs/root/custom_script.sh' file.
* 'virootfs' directory will included into the iso and will copy over to live environment before swith_root.
* if you need customize the live environment, make change in the 'virootfs' directory, assume 'virootfs' as overlay in live environment.
* 'virootfs/root/custom_script.sh' script will get execute after get copied over to live environment and before switch_root.
* if you want customize 'custom_script.sh', keep in mind, '/' in 'custom_script.sh' is '/' in live environment.
* the installer is included in the iso, so the iso you created is installable, run 'venom-installer' to start the installer.

** These scripts is still work in progress but its quite usable now. Things may change from time to time.

    
