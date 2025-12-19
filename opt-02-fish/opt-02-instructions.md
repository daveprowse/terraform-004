# Installing Fish 
Fish (friendly interactive shell) is an alternative to Bash. Consider using it to make your workflow more efficient. 

> NOTE: This lab is optional!

> NOTE: When working with new technologies, it is best to test them in a virtual machine environment first before applying them to your main systems. 

## Install Fish as your shell

Go to https://fishshell.com/ for installation methods and binaries for all kinds of systems.

You can install it easily on your Debian virtual machine with the following command:

`sudo apt install fish`

Configure Fish as the default shell:

https://fishshell.com/docs/current/index.html#starting-and-exiting 

> Note: the /local part of the directory path works for many Linux distros, but should be omitted in Debian. 

Restart your computer or virtual machine. After the restart the Fish shell should work by default.

Modify the Fish prompt, color scheme, and more, by running the following program in the terminal:

`fish_config`

That will open a browser tab with all of the configuration options for Fish. 

Also, if you like to use aliases you can build them in:

`~/.config/fish/fish_config`

For example, to use `ti` as an alias for `terraform init` (saving you keystrokes) you would add:

`alias ti='terraform init'`

*Add as many as you want!*

> Note: The original Fish option is to use the `abbr` command. You still can, for example: `abbr --add 's' 'sudo'`. More information about that at: https://fishshell.com/docs/current/cmds/abbr.html.

Restart the virtual machine when done. Verify that you can now use the Fish shell by default.

> NOTE: For information on how to use Fish interactively, see the following link: https://fishshell.com/docs/current/interactive.html

---
## *GREAT WORK!*
---