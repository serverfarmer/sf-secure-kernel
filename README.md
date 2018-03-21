sf-secure-kernel extension provides secure Linux kernel configuration,
including:

- protection from bogus ICMP packets from fake/vicious routers
- protection from SYN flood and small DDoS attacks
- logging bad packets
- RAM protection by turning off Firewire interface
- enforcing several standard protection mechanisms (eg. ASLR)
- restricting ptrace and dmesg for non-root users
- disabling core dumping by setuid/setgid programs

It is compatible with all supported Linux systems.
