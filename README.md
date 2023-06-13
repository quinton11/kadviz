# **Kademlia-2d**

Kademlia (***Distributed Hash Table***) is a routing algorithm which mimics a key-value store used in decentralized p2p networks to look up sources of content efficiently using the key of that content.

## **Purpose**
This project is aimed at demonstrating visually the concept of kademlia routing as pertaining to the [swarm](https://docs.ethswarm.org/docs/develop/introduction/) network. How routing tables are formed for each node when it joins the network, how nodes route traffic to remote nodes and how nodes maintain stable "lookup tables" in the event of node's dropping out.

### **Goals**
- Demonstrate new node onboarding and the formation of a routing table
- Demonstrate how nodes store content in a p2p network using kademlia routing tables
- Demonstrate how nodes retrieve content in a p2p network using kademlia routing tables
- Demonstrate how nodes maintain routing table *stability* in the event of *dropout* of known peers 
