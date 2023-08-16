# wp vagrant mac m1
A vagrantfile + wordpress setup script for m1/m2 mac enjoyers.

Made specifically for the m1 macs, but should work on any mac.
You do have to set it up, but I with VMWare Fusion Player it's
free for personal use vs Parallels which is $80/year.

## Requirements
- [Vagrant](https://www.vagrantup.com/downloads)
- [VMWare Fusion Player](https://customerconnect.vmware.com/en/evalcenter?p=fusion-player-personal-13)
Use VMWare Fusion Player as a backend.
- [Vagrant VMWare Fusion Plugin](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation)


## Setup

1. Clone this repo, probably using `degit`
2. `vagrant up`

Username is `admin` and password is `password` for the wordpress install.

Username is `vagrant` and password is `vagrant` for the VM.

If the provisioning script fail just `vagrant ssh` in a run the same commands line-by-line.
Vagrant is finnicky.