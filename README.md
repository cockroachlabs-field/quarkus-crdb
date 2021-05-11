# Demo: Securely connect a Quarkus Java app to your CockroachCloud Free Tier database

[Quarkus](https://quarkus.io) is a full stack, Kubernetes (_K8s_) native, Java
Application Framework. You can use it to build an _uber JAR_ containing your
application, along with its dependent JAR files, for easy deployment. It seems
similar to Spring Boot in some ways.

[CockroachCloud](https://www.cockroachlabs.com/product/cockroachcloud/) is a
managed CockroachDB service which features a free tier so you can experiment
without having to pay.

The purpose of this demo is to illustrate how to build and run a Quarkus app in
a GKE cluster and have the app connect to a CockroachCloud database instance
using the SSL `verify-full` setting to prevent man-in-the-middle attacks.  This
`verify-full` configuration setting requires the app to have filesystem access
to the CockroachCloud certificate, which poses challenges when running in
Kubernetes (or, it did for me).

Here's the procedure:

## Spin up a K8s cluster in GKE (if you don't already have access to a K8s cluster)

[Here](https://cloud.google.com/kubernetes-engine/docs/quickstart) are Google's
docs on this topic.  The `$` represents the shell command prompt.

```
$ gcloud container clusters create quarkus-crdb --num-nodes=1
```

That will run for a couple of minutes.  Once it's finished, proceed to:

```
$ gcloud container clusters get-credentials quarkus-crdb
```

## (Optional) Build the app

The app was taken from [this example](https://www.coding-daddy.xyz/node/45),
though I apparently messed it up slightly since the `GET` part of it isn't
working. FIXME

```
$ mvn clean package
```

## (Optional) Build the Docker image and publish it

There is an existing Docker image (`mgoddard/quarkus-crdb`) you can use for this; if you want
to use that image, just skip this section.

I have provided the scripts I used to build, tag, test and publish the app's Docker image:

* `Dockerfile`: Probably okay as it is. This refers to [entrypoint.sh](./entrypoint.sh).
* `include.sh`: Edit this since constants defined here are referenced by the `docker_*.sh` scripts.
* `docker_build_image.sh`: Builds the image
* `docker_tag_publish.sh`: Tags and publishes the image (requires a Docker Hub account)
* `docker_run_image.sh`: Runs the image locally
* `entrypoint.sh`: This is copied into the image and translates the environment variables defined in
  [the K8s deployment](./quarkus-crdb.yaml) into Java properties, and it also starts the app.

## Sign up for CockroachCloud and start up a Free Tier instance

* Open [this URL](https://cockroachlabs.cloud/signup) and sign up.  You can _Sign up with GitHub_ to
avoid having to enter data into the form.
* Once logged in, click the _Create Cluster_ button.
* _CockroachCloud Free_ should be selected by default.
* To change the region, click _Additional configuration_ and then you are able to use the drop-down
control under _Regions_.  You can also choose a _Cluster Name_.
* Click _Create your free database_ on the right side of the UI.
* A dialog will appear, telling you the cluster is being created.
* Finally, your _Connection info_ dialog appears, from which you will (see image below):
  - Download your `cc-ca.crt` certificate file
  - Copy (and save) your connection string

![Connection info dialog](./CC_connection_UI.png)

## Create a K8s secret containing the CockroachCloud server certificate

Per [this reference](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/),
_A Secret can contain user credentials required by pods to access a database_, so secrets will enable
our app to access the `cc-ca.crt` file which we need in order to run in `verify-full` mode.  This secret
is referenced by your deployment manifest and will be accessible at `/var/certs/cc-ca.crt` in the K8s pod.

Here's the process:

```
$ mkdir certs
$ cp ~/Downloads/cc-ca.crt ./certs
$ kubectl create secret generic cc-ca --from-file=./certs/cc-ca.crt
$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
cc-ca                 Opaque                                1      37s
default-token-4pvcq   kubernetes.io/service-account-token   3      4h51m
```

## Edit the app's deployment manifest (YAML) and deploy the app

In a previous step, you copied your CockroachCloud connection string (and saved it).
This is the form of the connection string:

```
cockroach sql --url 'postgres://michael:36W2e23Nxg9JdKkw@free-tier.gcp-us-central1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=<your_certs_directory>/cc-ca.crt&options=--cluster=quarkus-demo-1975'
```

Use the values embedded within the `'postgres://...` string to fill in the `quarkus-crdb.yaml` file,
mapping them as follows:

```
- name: JDBC_URL
  value: "jdbc:postgresql://free-tier.gcp-us-central1.cockroachlabs.cloud:26257/quarkus-demo-1975.defaultdb?sslmode=verify-full&sslrootcert=/var/certs/cc-ca.crt"
- name: PGUSER
  value: "michael"
- name: PGPASSWORD
  value: "36W2e23Nxg9JdKkw"
```

(The database name is that part after `--cluster=` plus `.defaultdb`)

* Save this YAML file
* Deploy the app:
```
$ kubectl apply -f quarkus-crdb.yaml
```
* Check the status of the app:
```
$ kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
quarkus-crdb-67b67c48ff-4v5kx   1/1     Running   0          49s
```
* And get the `EXTERNAL-IP` of the app's LoadBalancer (here, `35.245.163.14`):
```
$ kubectl get services
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
kubernetes        ClusterIP      10.99.240.1     <none>          443/TCP        5h11m
quarkus-crdb-lb   LoadBalancer   10.99.241.187   35.245.163.14   80:30750/TCP   5h9m
```

## Test the app

Prior to running the last part of this, you will need to have downloaded and installed the `cockroach` binary
for your platform, which is available from [the releases page](https://www.cockroachlabs.com/docs/releases/).

```
$ export LB_EXT_IP="35.245.163.14"
$ ./test.sh
```

`test.sh` uses Curl to POST data to the app endpoint for creating a user.  This data should now be visible
via a SQL client:

```
$ cockroach sql --url 'postgres://michael:36W2e23Nxg9JdKkw@free-tier.gcp-us-central1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=./certs/cc-ca.crt&options=--cluster=quarkus-demo-1975'             
#
# Welcome to the CockroachDB SQL shell.
# All statements must be terminated by a semicolon.
# To exit, type: \q.
#
# Server version: CockroachDB CCL v20.2.8 (x86_64-unknown-linux-gnu, built 2021/04/23 13:54:57, go1.13.14) (same version as client)
# Cluster ID: c0854300-2c35-44b4-a7d1-2af71acd3e4c
#
# Enter \? for a brief introduction.
#
michael@free-tier.gcp-us-central1.cockroachlabs.cloud:26257/defaultdb> select * from users;
  id |      email       | password | username
-----+------------------+----------+-----------
   1 | test@example.org | secret   | test
(1 row)

Time: 45ms total (execution 1ms / network 43ms)

```

If you can see the row of data in the `users` table, you've successfully run the demo.
Thank you for working through it with me!

