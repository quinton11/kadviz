# **Kademlia-2d**

Kademlia (**_Distributed Hash Table_**) is a routing algorithm which mimics a key-value store used in decentralized p2p networks to look up sources of content efficiently using the key of that content.

## **Purpose**

This project is aimed at demonstrating visually the concept of kademlia routing as pertaining to the [swarm](https://docs.ethswarm.org/docs/learn/technology/disc)(DISC) and [ipfs](https://docs.ipfs.tech/concepts/how-ipfs-works/#kademlia-distributed-hash-table-dht)(DHT) networks. How routing tables are formed for each node when it joins the network and how nodes route traffic to remote nodes to find or store content.

### **Goals**

- Demonstrate new node onboarding and the formation of a routing table via the HIVE operation
- Demonstrate how nodes route effectively in the p2p network via kademlia, in effect, covering all the different operations.

### Demo

- Here, Swarm's `HIVE` operation is shown, where nodes get to know about closer nodes it does not know about yet, to populate its routing table

https://github.com/quinton11/kadviz/assets/70300837/b096e5dc-4196-4de0-b8ff-45214338a28d

- Here, is Swarm's `FIND NODE` operation, visualizing the recursive nature of network request in swarm's DISC network.

https://github.com/quinton11/kadviz/assets/70300837/19a1f408-406d-4c66-af07-750f6814c1dd

- Here, a selected path in the `FIND NODE` oepration is visualized, allowing tracking of a single packet's request path, in this case, `path 0` from the `FIND NODE` operation shown here 👆🏿

https://github.com/quinton11/kadviz/assets/70300837/4e2d71e7-7c9a-4052-9127-2b2f8c720e89

### **NB**:

- Not tested for web nor mobile yet, just desktop(mac)
