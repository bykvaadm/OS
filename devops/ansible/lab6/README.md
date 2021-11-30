# Задачи

1. Disable debug-shell SystemD Service

   **Цель:** This prevents attackers with physical access from trivially bypassing security on the machine through valid
   troubleshooting configurations and gaining root access when the system is rebooted.

   **Реализация:**
    ```
    systemctl disable debug-shell.service
    ```

2. Disable Ctrl-Alt-Del Reboot Activation

   **Цель:** A locally logged-in user who presses Ctrl-Alt-Del, when at the console, can reboot the system. If
   accidentally pressed, as could happen in the case of mixed OS environment, this can create the risk of short-term
   loss of availability of systems due to unintentional reboot.

   **Реализация:**
    ```
    ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target
    ```

3. Disable Ctrl-Alt-Del Burst Action

   **Цель:** By default, SystemD will reboot the system if the Ctrl-Alt-Del key sequence is pressed Ctrl-Alt-Delete more
   than 7 times in 2 seconds.

   **Реализация:**
    ```
    To configure the system to ignore the CtrlAltDelBurstAction setting, add or modify the following to /etc/systemd/system.conf: CtrlAltDelBurstAction=none
   ```

4. Ensure Home Directories are Created for New Users

   **Цель:** If local interactive users are not assigned a valid home directory, there is no place for the storage and
   control of files they should own.

   **Реализация:**
    ```
    /etc/login.defs -> CREATE_HOME yes
    ```

5. Set Password Hashing Algorithm in /etc/login.defs

   **Цель:** Passwords need to be protected at all times, and encryption is the standard method for protecting
   passwords. If passwords are not encrypted, they can be plainly read (i.e., clear text) and easily compromised.
   Passwords that are encrypted with a weak algorithm are no more protected than if they are kept in plain text.

   Using a stronger hashing algorithm makes password cracking attacks more difficult.

   **Реализация:**

   ```
   /etc/login.defs -> ENCRYPT_METHOD SHA512
   ```  

6. Ensure All Accounts on the System Have Unique Names

   **Цель:** Unique usernames allow for accountability on the system.

   **Реализация:**

   ```
   getent passwd | awk -F: '{ print $1}' | uniq -d
   ``` 

7. Set Account Expiration Following Inactivity

   **Цель:** Disabling inactive accounts ensures that accounts which may not have been responsibly removed are not
   available to attackers who may have compromised their credentials.

   **Реализация:**

   ```
   /etc/default/useradd -> INACTIVE=35
   ``` 

8. Prevent Login to Accounts With Empty Password

   **Цель:** If an account has an empty password, anyone could log in and run commands with the privileges of that
   account. Accounts with empty passwords should never be used in operational environments.

   **Реализация:**

   ```
   /etc/pam.d/system-auth -> remove nullok
   ``` 

9. Verify All Account Password Hashes are Shadowed

   **Цель:** The hashes for all user account passwords should be stored in the file /etc/shadow and never in
   /etc/passwd, which is readable by all users.

   **Реализация:**

   ```
   /etc/passwd -> awk -F: '$2!="x"'
   ``` 

10. Set Password Minimum Length in login.defs

   **Цель:** Requiring a minimum password length makes password cracking attacks more difficult by ensuring a larger
   search space. However, any security benefit from an onerous requirement must be carefully weighed against usability
   problems, support costs, or counterproductive behavior that may result.

   **Реализация:**

   ```
   /etc/default/useradd -> PASS_MIN_LEN=16
   ``` 

11. Set Password Minimum Length in login.defs

   **Цель:** Requiring a minimum password length makes password cracking attacks more difficult by ensuring a larger
   search space. However, any security benefit from an onerous requirement must be carefully weighed against usability
   problems, support costs, or counterproductive behavior that may result.

   **Реализация:**

   ```
   /etc/default/useradd -> PASS_MIN_LEN=16
   ``` 
   
12. Modify the System Message of the Day Banner

   **Цель:** Display of a standardized and approved use notification before granting
   access to the operating system ensures privacy and security notification
   verbiage used is consistent with applicable federal laws, Executive Orders,
   directives, policies, regulations, standards, and guidance.

   **Реализация:**

   ```
   /etc/motd
   ``` 
    
13. Verify /boot/grub2/grub.cfg Permissions

   **Цель:** Proper permissions ensure that only the root user can modify important boot
   parameters.

   **Реализация:**

   ```
   chmod 600 /boot/grub2/grub.cfg
   chown root:root
   ``` 
    
14. Disallow kernel profiling by unprivileged users

   **Цель:** Kernel profiling can reveal sensitive information about kernel behaviour.

   **Реализация:**

   ```
   kernel.perf_event_paranoid=2 -> /etc/sysctl.conf
   ``` 
     
15. Disable vsyscalls

   **Цель:** Virtual Syscalls provide an opportunity of attack for a user who has control
   of the return instruction pointer.

   **Реализация:**

   ```
   /etc/default/grub -> GRUB_CMDLINE_LINUX="vsyscall=none"
   ```      

16. Disable Kernel Image Loading

   **Цель:** Disabling kexec_load allows greater control of the kernel memory.
   It makes it impossible to load another kernel image after it has been disabled.

   **Реализация:**

   ```
   kernel.kexec_load_disabled = 1 -> /etc/sysctl.conf
   ``` 

17. Harden the operation of the BPF just-in-time compiler

   **Цель:** When hardened, the extended Berkeley Packet Filter just-in-time compiler
   will randomize any kernel addresses in the BPF programs and maps,
   and will not expose the JIT addresses in /proc/kallsyms.

   **Реализация:**

   ```
   net.core.bpf_jit_harden = 2 -> /etc/sysctl.conf
   ``` 

18. Restrict Access to Kernel Message Buffer

   **Цель:** Unprivileged access to the kernel syslog can expose sensitive kernel
   address information.

   **Реализация:**

   ```
   kernel.dmesg_restrict = 1 -> /etc/sysctl.conf
   ``` 

18. Disable the Automounter

   **Цель:** The autofs daemon mounts and unmounts filesystems, such as user
   home directories shared via NFS, on demand. In addition, autofs can be used to handle
   removable media, and the default configuration provides the cdrom device as /misc/cd.
   However, this method of providing access to removable media is not common, so autofs
   can almost always be disabled if NFS is not in use. Even if NFS is required, it may be
   possible to configure filesystem mounts statically by editing /etc/fstab
   rather than relying on the automounter.

   **Реализация:**

   ```
   systemctl disable autofs.service
   ``` 

