## Create an image with python2, python3, R, install a set of requirements and upload it to docker hub.

## For the previously created image

### Share build times
- 421.6s
- 602MB

### How would you improve build times?
- Having appropriate caching mechanisms in place. If we are building the ci/cd pipeline with github actions, we can use actions/cache to speed up builds by reusing cache from previously run builds of the same repo.
- I used alpine image as it is more lightweight however this might not always be the best option, depends on the use case of the app itself.
- Depending on the application's architecture, it might be possible that the app can be decoupled into microservies, and have separate images/deployments. If they are thightly coupled perhaps have 3 containers running in the same pod that share same resources. This would require separate builds and breaking it down is generally the best option when possible.

## Scan the recently created container and evaluate the CVEs that it might contain.

### Create a report of your findings and follow best practices to remediate the CVE

I used trivy to scan for vulnerabilities for OS and for python. For R we would need to include also something like oysteR. 
In the report generated, the issues are due to using python2. Ideally migrating to python3 would be the best solution.
Where possible, if using specified versions for packages try to update to the latest or at least to the version which solves the vulnerability. 

alpine-py2-py3-r:1.0.0 (alpine 3.18.5)
======================================
Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)


Python (python-pkg)
===================
Total: 7 (UNKNOWN: 0, LOW: 0, MEDIUM: 4, HIGH: 3, CRITICAL: 0)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                            │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ certifi (METADATA)    │ CVE-2023-37920 │ HIGH     │ fixed  │ 2021.10.8         │ 2023.7.22     │ python-certifi: Removal of e-Tugra root certificate         │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-37920                  │
│                       ├────────────────┼──────────┤        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                       │ CVE-2022-23491 │ MEDIUM   │        │                   │ 2022.12.07    │ untrusted root certificates                                 │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-23491                  │
├───────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ pip (METADATA)        │ CVE-2021-3572  │          │        │ 20.3.4            │ 21.1          │ python-pip: Incorrect handling of unicode separators in git │
│                       │                │          │        │                   │               │ references                                                  │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2021-3572                   │
│                       ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-5752  │          │        │                   │ 23.3          │ pip: Mercurial configuration injectable in repo revision    │
│                       │                │          │        │                   │               │ when installing via pip                                     │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-5752                   │
├───────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ requests (METADATA)   │ CVE-2023-32681 │          │        │ 2.27.1            │ 2.31.0        │ python-requests: Unintended leak of Proxy-Authorization     │
│                       │                │          │        │                   │               │ header                                                      │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-32681                  │
├───────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ setuptools (METADATA) │ CVE-2022-40897 │ HIGH     │        │ 44.1.1            │ 65.5.1        │ pypa-setuptools: Regular Expression Denial of Service       │
│                       │                │          │        │                   │               │ (ReDoS) in package_index.py                                 │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-40897                  │
├───────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ wheel (METADATA)      │ CVE-2022-40898 │          │        │ 0.37.1            │ 0.38.1        │ remote attackers can cause denial of service via attacker   │
│                       │                │          │        │                   │               │ controlled input to...                                      │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-40898                  │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘


### What would you do to avoid deploying malicious packages?
- Always use official/reliable sources
- Scan dependencies for vulnerabilities
- Use versioning on dependencies to avoid auto updated packages 

## Use the created image to create a kubernetes deployment with a command that will keep the pod running

apiVersion: apps/v1
kind: Deployment
metadata:
  name: swish-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: swish-app
  template:
    metadata:
      labels:
        app: swish-app
    spec:
      containers:
      - name: swish-container
        image: jacbug/alpine-py2-py3-r:1.0.0
        command: ["/bin/sh"]
        args: ["-c", "tail -f /dev/null"]


## Expose the deployed resource

- Lets say that the deployed resources is deployed in AWS EKS. Usually, an ingress/egress would be necessary to handle inbound and outbound connections to the cluster such as nginx, istio, amabassador edge stack etc.
- Decide which load balancer is the most appropriate either elb, alb or nlb, depending on the specific use case
- Decide on how you are going to handle TLS
- Install nginx or similar
- Ensure that a loadbalancer is created, dns records updated, and have restricted the IPs from where traffic is coming from (if public restrict from CDN IPs). Also ensure that SSL is working fine.
- Create an ingress.yaml for the application to allow a connection through the loadbalancer and configure the rules accordingly.
- For the sake of this exercise, I will just create a service and expose it via type: LoadBalancer

apiVersion: v1
kind: Service
metadata:
  name: swish-service
spec:
  selector:
    app: swish-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer

## Every step mentioned above have to be in a code repository with automated CI/CD
- https://github.com/jbugeja/test-repo

## How would you monitor the above deployment? Explain or implement the tools that you would use
- Prometheus for metric collection and storage
- Node Exporter to collect node metrics
- kube-state-metrics to collect kubernetes resources
- Loki for log aggregation
- promtail for shipping logs to loki
- Grafana for visualising data from prometheus and loki + for alerting
- Jaeger to monitor and troubleshoot transactions
