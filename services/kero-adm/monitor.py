from kubernetes.config import load_kube_config
from kubernetes.client import CustomObjectsApi

#Run this on a VM
#APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
#SECRET_NAME=$(kubectl get secrets | grep ^default | cut -f1 -d ' ')
#TOKEN=$(kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")



class KubeMonitor:
    def __init__(self):
        load_kube_config()
        cust = CustomObjectsApi()
        cust.list_cluster_custom_object('metrics.k8s.io', 'v1beta1', 'nodes')
        cust.list_cluster_custom_object('metrics.k8s.io', 'v1beta1', 'pods')
