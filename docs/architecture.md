# Architecture

The main objective of this project is to provide various services to a private network using desktop computers with heterogeneous specifications as hardware. To the end user, all computers look the same. On the inside, we combine a well known container orchestrator to deploy services and desktops for our users.

The set of machines that form part of the platform is called _cluster_. Any
single machine in the _cluster_ may be referred as a _node_. This set
of machines can be heterogeneous and will run only basic services needed for
running and managing the cluster on bare metal. All services provided by the
cluster run on containers.

Among the services provided by the cluster we list:
- **Virtual desktops**: different users may login to what looks like a private
  computer, but is actually containerized.
- **LDAP registry**: an LDAP registry to provide credential for users and
  administrators.
- **Disributed volumes**: a distributed filesystem that provides HA replicated
  access to storage, which is shared among many nodes with storage capabilities.

This design also provides a way of adding more custom services so long they are
compliant with the container orchestrator Kubernetes.

![](/docs/architecture.png)

## Container orchestrator and virtualization

To deploy our services and the employees desktops, we use an orchestrator named [Kubernetes (K8s)](https://kubernetes.io/). K8s is an open-source system for automating deployment, scaling, and management of containerized applications.
But above all, K8s is self-healing. It restarts containers that fail, replaces and reschedules containers when nodes die, kills containers that don’t respond to your user-defined health check, and doesn’t advertise them to clients until they are ready to serve.

In our case, every machine is a K8s node. Each node contains the services necessary to run pods and is managed by the master components. The services on a node include the container runtime, kubelet and kube-proxy. 
Depending on the size of the cluster, we will have three to five nodes selected as masters. Hence these machines will run master components. Master components make global decisions about the cluster (for example, scheduling), and detecting and responding to cluster events (starting up a new pod when a replication controller’s replicas field is unsatisfied).

### Node components
#### kubelet
An agent that runs on each node in the cluster. It makes sure that containers are running in a pod.

The kubelet takes a set of PodSpecs that are provided through various mechanisms and ensures that the containers described in those PodSpecs are running and healthy. The kubelet doesn’t manage containers which were not created by Kubernetes.

#### kube-proxy
kube-proxy nables the Kubernetes service abstraction by maintaining network rules on the host and performing connection forwarding.

#### Continer Runtime
The container runtime is the software that is responsible for running containers. This project implements [Docker](https://www.docker.com/) as its container runtime.

### Master components
#### kube-apiserver
Component on the master that exposes the Kubernetes API. It is the front-end for the Kubernetes control plane.

It is designed to scale horizontally – that is, it scales by deploying more instances. 

#### etcd
Consistent and highly-available key value store used as Kubernetes’ backing store for all cluster data.

Always have a backup plan for etcd’s data for your Kubernetes cluster.

#### kube-scheduler
Component on the master that watches newly created pods that have no node assigned, and selects a node for them to run on.

Factors taken into account for scheduling decisions include individual and collective resource requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference and deadlines.

#### kube-controller-manager
Component on the master that runs controllers.

Logically, each controller is a separate process, but to reduce complexity, they are all compiled into a single binary and run in a single process.

These controllers include:
* Node Controller: Responsible for noticing and responding when nodes go down.
* Replication Controller: Responsible for maintaining the correct number of pods for every replication controller object in the system.
* Endpoints Controller: Populates the Endpoints object (that is, joins Services & Pods).
* Service Account & Token Controllers: Create default accounts and API access tokens for new namespaces.

### Meta orchestrator
Set up scripts typically start all master components on the same machines, and do not run user containers on this machine. But because we want all machines to look the same, and we don't rely on the same machines to be functional forever, we implement a service to orchestrate master nodes. This meta orchestrator is responsible for implementing the K8s self-healing feature at node level.

The meta orchestrator service is deployed on K8s that monitors master node health and readiness conditions. If a kubelet fails to update these variables, and a given time passes, the service assumes the master is gone. A non-master node is chosen and "crowned". This process consists of the following:
* The old master is deleted from the cluster
* A non-master node is chosen, based on a combination of system requirements and few, low priority, scheduled pods.
* The chosen node is drained and rebooted
* New master is configured and master components deployed

New or repaired machines can join the cluster by running the installer.

## Desktops

To emulate a desktop computers, we use of the VNC (Virtual Network Computing) protocol. Essentially a container running
centOS and xfce window manager is deployed for each user upon login. The
container is orchestrated by Kubernetes and may land on any node. To make it
accessible from anywhere in the network, the container also includes a VNC
server, which is serves an http endpoint. This way anyone with access to the
network and a browser (which may run natively in the _node_ or on an external
machine not part of the cluster) can access the remote desktop.

To further simulate an user environment, we provide a personal volume to each
user, mounted in its home. Any changes made there persist if the desktop
container is moved or reseted. A shared volume is also available and visible to all users.

## Storage
Machines hard disks are partitioned in two. The first, and smaller partition, is reserved for the underlying OS and data needed to run node components. The bigger partition or brick is dedicated to save files from the users homes and shared filesystem service.

### Shared file system
To implement our shared file system, we use GlusterFS. [Gluster](https://www.gluster.org/) is a scalable, distributed file system that aggregates disk storage resources from multiple servers into a single global namespace.

A Gluster replicated volume is used to persist homes and sharedfs. Exact copies of the data are maintained on the bricks. 
The number of replicas can be decided by the client (Default is 5). So we need to have at least two bricks to create a volume with 2 replicas or a minimum of three bricks to create a volume of 3 replicas. 
One major advantage of such volume type is that even if one brick fails the data can still be accessed from its replicated bricks. Such a volume is used for better reliability and data redundancy.

## Users
