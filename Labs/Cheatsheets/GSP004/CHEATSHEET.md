# **To be done using Google Cloud Shell**

**1. Create a new instance in the specified zone.**

**2. Create a new persistent disk in the specified zone.**

**3. Attaching and Mounting the persistent disk.**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute instances create gcelab \
--machine-type e2-standard-2 \
--zone $ZONE

gcloud compute disks create mydisk \
--size=200GB \
--zone $ZONE

gcloud compute instances attach-disk gcelab \
--disk mydisk \
--zone $ZONE

gcloud compute ssh gcelab \
--zone $ZONE \
--command "sudo mkdir /mnt/mydisk &&
  sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 &&
  sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk &&
  echo '/dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk ext4 defaults 1 1' | sudo tee -a /etc/fstab" -q
```

## Lab Completed🎉