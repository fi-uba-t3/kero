from kubernetes import client, config

# Run this on a VM to test
# $ APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
# $ SECRET_NAME=$(kubectl get secrets | grep ^default | cut -f1 -d ' ')
# $ TOKEN=$(kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")


class KubeMonitor:
    def __init__(self):
        config.load_kube_config()
        self.v1 = client.CoreV1Api()
    def get_pods_status(self):
        ret = self.v1.list_pod_for_all_namespaces(watch=False)

        pods_list = []
        for pod in ret.items:
            pod_dict = {
                "name": pod.metadata.name,
                "namespace": pod.metadata.namespace,
                "start_time": pod.status.start_time,
                "status": pod.status.phase,
                "host_ip": pod.status.host_ip,
                "pod_ip": pod.status.pod_ip
            }
            pods_list.apend(pod_dict)
        return pods_list
    def get_services_status(self):
        ret = self.v1.list_service_for_all_namespaces(watch=False)
        service_list = []
        for service in ret.items:
            service_dict = {
                "cluster_ip": service.spec.cluster_ip,
                "external_ip": service.spec.external_ip,
                "namespace": service.metadata.namespace,
                "name": service.metadata.name,
                "creation_timestamp": service.metadata.creation_timestamp
            }
            service_list.append(service_dict)
        return service_list

