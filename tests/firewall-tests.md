# Firewall Test Cases

| ID | Test | Expected | Result |
|---|---|---|---|
| FW-01 | Client accesses approved local service | Allowed | Not run |
| FW-02 | Unapproved inbound WAN connection | Blocked | Not run |
| FW-03 | Remote LAN accesses local service | Only explicitly allowed traffic | Not run |
| FW-04 | Approved monitor reaches TCP 9100 | Allowed | Not run |
| FW-05 | Unrelated network reaches TCP 9100 | Blocked | Not run |
| FW-06 | Management from unapproved interface | Blocked | Not run |

Record source, destination, protocol, port, rule, and observed result. Test only systems/networks you own.
