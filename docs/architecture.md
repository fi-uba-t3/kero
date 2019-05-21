# Architecture

The main requirement of our project is to provide various services using desktop computers with different specifications. To the end user, all computers look the same. On the inside, we combine a well known container orchestrator to deploy services and desktops for our users.

## Container orchestrator
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

The meta orchestrator service is deployed on K8s and monitors master node health and readiness conditions. If a kubelet fails to update these variables, and a given time passes, the service assumes the master is gone. A non-master node is chosen and "crowned". This process consists of the following:
* The old master is deleted from the cluster
* A non-master node is chosen, based on a combination of system requirements and few, low priority, scheduled pods.
* The chosen node is drained and rebooted
* New master is configured and master components deployed

New or repaired machines can join the cluster by running the installer.

## Desktops
To emulate a desktop computer, we make use of the Virtual Network Computing ????

## Storage

## Users

