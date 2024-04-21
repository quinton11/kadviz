# **Kademlia-2d**

Kademlia (**_Distributed Hash Table_**) is a routing algorithm which mimics a key-value store used in decentralized p2p networks to look up sources of content efficiently using the key of that content.

## **Purpose**

This project is aimed at demonstrating visually the concept of kademlia routing as pertaining to the [swarm](https://docs.ethswarm.org/docs/learn/technology/disc)(DISC) and [ipfs](https://docs.ipfs.tech/concepts/how-ipfs-works/#kademlia-distributed-hash-table-dht)(DHT) networks. How routing tables are formed for each node when it joins the network and how nodes route traffic to remote nodes to find or store content.

### **Goals**

- Demonstrate new node onboarding and the formation of a routing table
- Demonstrate how nodes route effectively in the p2p network via kademlia, in effect, covering all the different operations.

### Demo

- Here, we depict Swarm's HIVE operation, where nodes get to know about neighbourhood nodes it does not know about, to populate its routing table
