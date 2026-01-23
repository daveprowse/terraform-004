# VirtualBox Notes

VirtualBox is an excellent choice for building virtual machines - especially for people who are new to virtualization. It is free, easy to use, and runs on many platforms.

If you choose to use VirtualBox, you can install it from here: https://www.virtualbox.org/wiki/Downloads.

> Note: There are lots of virtualization platforms. For more information check out Sander van Vugt's video course: *Virtualization for Everyone* at [this link](https://learning.oreilly.com/course/virtualization-for-everyone/9780135338698/). 


---


For those of you using VirtualBox you will note that the installation of Debian is quite automated. If for some reason it is not in your virtualization system, I have step-by-step tutorials at my website:

  https://prowse.tech/linux-installs/

## Login Details

In fact, VirtualBox might complete the *entire* installation for you and place you at a login prompt.

If you get to a login prompt, it might show *vboxuser* as the username. The default password for this is *changeme*. Be sure to change the password after you login!

## NAT Network  
By default, VirtualBox sets up the virtual machine as NAT. In VirtualBox that means that the VM can connect to the Internet. Also, the host computer can communicate with the VM. However, additional VMs will not be able to communicate with each other unless you change the network setting to "NAT Network". 
So if you plan to have multiple VMs and you would like them to communicate with each other, set them all to NAT Network.

> Note: For more information on VirtualBox, NAT Networks, SSH access, and more: see these links:

- https://prowse.tech/virtualbox/
- https://www.virtualbox.org/manual/ch06.html

---



