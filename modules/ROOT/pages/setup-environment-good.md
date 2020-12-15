Before anything le's log in our OpenShift cluster...

```execute
oc login --insecure-skip-tls-verify -u %username% -p %ocp_password% --server=https://%KUBERNETES_SERVICE_HOST%:%KUBERNETES_SERVICE_PORT%
```

Did you type the command in yourself? If you did, click on the command instead and you will find that it is executed for you. You can click on any command which has the <span class="fas fa-play-circle"></span> icon shown to the right of it, and it will be copied to the interactive terminal and run. If you would rather make a copy of the command so you can paste it to another window, hold down the shift key when you click on the command.

Now let's create a project to deploy our knative services (ksvc).

```execute
oc new-project %username%-tutorial
oc new-project %username%-smcp
```

**Installing the OpenShift Service Mesh Control Plane**

> **NOTE:** Although you don't have to do it yourself, it's important to note that the OpenShift Service Mesh Operator needs to be [installed](https://docs.openshift.com/container-platform/4.4/service_mesh/service_mesh_install/installing-ossm.html#ossm-control-plane-deploy-operatorhub_installing-ossm) cluster-wide (on all namespaces on the cluster), this is the default by the way.
>
> **Prerequisites:**
> 
> * Access to the OpenShift Container Platform web console.
> * The Elasticsearch Operator must be installed.
> * The Jaeger Operator must be installed.
> * The Kiali Operator must be installed.
>

So, let's intall the OpenShift Service Mesh Control Plane. You can find all the details [here](https://docs.openshift.com/container-platform/4.4/service_mesh/service_mesh_install/installing-ossm.html#ossm-control-plane-deploy-operatorhub_installing-ossm), but for the sake of simplicity just follow these simple steps.

1. Navigate to **Operators** → **Installed Operators**. If necessary, select **%username%-smcp** from the **Project** menu. You may have to wait a few moments for the Operators to be copied to the new project.
2. Click the **Red Hat OpenShift Service Mesh Operator**. Under **Provided APIs**, the Operator provides links to create two resource types: **ServiceMeshControlPlane** and **ServiceMeshMemberRoll**.
3. Under **Istio Service Mesh Control Plane** click **Create ServiceMeshControlPlane**. On the Create Service Mesh Control Plane page, eave the defaults.
4. Click **Create** to create the control plane. The Operator creates Pods, services, and Service Mesh control plane components based on your configuration parameters.
5. Click the **Istio Service Mesh Control Plane** tab.
6. Click the **name** of the new control plane.
7. Click the **Resources** tab to see the Red Hat OpenShift Service Mesh control plane resources the Operator created and configured. Wait until all the components are installed correctly, as in the next picture.

![Successful Installation](./images/ssss.png)

> **CHECK 1:** By running the next command you should get `True`
> 
> ```
> NAME           READY
> basic-install   True
> ```

```execute
oc get smcp -n %username%-smcp
```

> **CHECK 2:** By running the next command you'll watch the progress of the Pods during the installation process.
> 
> ```
> NAME                                     READY   STATUS             RESTARTS   AGE
> grafana-7bf5764d9d-2b2f6                 2/2     Running            0          28h
> istio-citadel-576b9c5bbd-z84z4           1/1     Running            0          28h
> istio-egressgateway-5476bc4656-r4zdv     1/1     Running            0          28h
> istio-galley-7d57b47bb7-lqdxv            1/1     Running            0          28h
> istio-ingressgateway-dbb8f7f46-ct6n5     1/1     Running            0          28h
> istio-pilot-546bf69578-ccg5x             2/2     Running            0          28h
> istio-policy-77fd498655-7pvjw            2/2     Running            0          28h
> istio-sidecar-injector-df45bd899-ctxdt   1/1     Running            0          28h
> istio-telemetry-66f697d6d5-cj28l         2/2     Running            0          28h
> jaeger-896945cbc-7lqrr                   2/2     Running            0          11h
> kiali-78d9c5b87c-snjzh                   0/1     Running            0          22h
> prometheus-6dff867c97-gr2n5              2/2     Running            0          28h
> ```

```execute
oc get pods -n %username%-smcp
```

**Creating the Red Hat OpenShift Service Mesh member roll**

The **ServiceMeshMemberRoll** lists the projects belonging to the control plane. *Only projects listed in the **ServiceMeshMemberRoll** are affected by the control plane*. A project does not belong to a service mesh until you add it to the member roll for a particular control plane deployment.

*You must create a **ServiceMeshMemberRoll** resource **named default** in the **same project as the ServiceMeshControlPlane***

1. Navigate to **Operators** → **Installed Operators**.
2. Click the **Project** menu and choose the project where your **ServiceMeshControlPlane** is deployed from the list, it should be **%username%-smcp**.
3. Click the **Red Hat OpenShift Service Mesh Operator**.
4. Click the **All Instances** tab.
5. Click **Create New**, and then select **Istio Service Mesh Member Roll**.
6. On the **Create Service Mesh Member Roll** page, modify the YAML to add your projects as members. You can add any number of projects, but a project can only belong to one ServiceMeshMemberRoll resource. Add **%username%-tutorial**
7. Click Create to save the Service Mesh Member Roll.

```yaml
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: %username%-smcp
spec:
  members:
    - %username%-tutorial
```

**Installing the sample application we're going to use in this tutorial**

```execute
oc create -n %username%-tutorial -f /opt/app-root/workshop/content/k8s/curl.yaml 
oc create -n %username%-tutorial -f /opt/app-root/workshop/content/k8s/customer.yaml
oc create -n %username%-tutorial -f /opt/app-root/workshop/content/k8s/gateway.yaml
oc create -n %username%-tutorial -f /opt/app-root/workshop/content/k8s/preference.yaml
oc create -n %username%-tutorial -f /opt/app-root/workshop/content/k8s/recommendation.yaml
```

*If you're a returning customer... I mean student...*

If you have already created the project you can always set it as default running this command:

```execute
oc project %username%-tutorial
```