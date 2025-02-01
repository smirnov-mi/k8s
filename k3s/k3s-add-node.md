# Adding a node to a cluser

To add a new worker node to an existing k3s (Kubernetes) cluster, you need to follow a series of steps to ensure proper connectivity, communication, and integration with the existing cluster setup. Here’s a detailed guide for adding a new worker node to an existing k3s cluster:

---

### Prerequisites:
- You should already have a running k3s cluster with at least one master node.
- You need access to the existing k3s master node (both IP and the K3S_TOKEN).
- The new worker node must have access to the k3s master node (via the network).
- The new node should have Docker installed and the necessary ports open to communicate with the master.
- Ensure both master and worker nodes are running a compatible version of k3s.

---

### Step-by-Step Guide:

#### 1. **Prepare the New Worker Node:**
   - Install the necessary dependencies like Docker on the new worker node.
     ```bash
     sudo apt-get update
     sudo apt-get install -y docker.io
     ```

   - Enable Docker to start on boot:
     ```bash
     sudo systemctl enable docker
     sudo systemctl start docker
     ```

   - (Optional) Disable swap on the new worker node:
     Kubernetes requires swap to be disabled on all nodes.
     ```bash
     sudo swapoff -a
     ```
     To disable swap permanently, you can edit `/etc/fstab` and remove or comment out the swap entry.

#### 2. **Obtain the K3S_TOKEN from the Master Node:**
   On your existing k3s master node, you need the `K3S_TOKEN` that will be used to securely join the worker node to the cluster.

   You can obtain this token by running the following command on the master node:
   ```bash
   sudo cat /var/lib/rancher/k3s/server/node-token
   ```

   **Note:** The token is typically a long string of characters and is used to authenticate the new worker node with the master.

#### 3. **Get the IP Address of the Master Node:**
   You will need the IP address of the existing k3s master node for the worker to communicate with the cluster.

   If you're unsure of the master node's IP, you can find it using:
   ```bash
   ip a
   ```

#### 4. **Install k3s on the Worker Node:**
   Now that you have the `K3S_TOKEN` and the master node's IP, you can install k3s on the new worker node.

   Run the following command on the worker node to install k3s and join the cluster:

   ```bash
   curl -sfL https://get.k3s.io | K3S_URL=https://<master-node-ip>:6443 K3S_TOKEN=<your-k3s-token> sh -
   ```

   Replace `<master-node-ip>` with the IP address of the master node, and `<your-k3s-token>` with the token you retrieved earlier.

   **Example:**
   ```bash
   curl -sfL https://get.k3s.io | K3S_URL=https://192.168.1.10:6443 K3S_TOKEN=mySuperSecretToken sh -
   ```

   - This command will install k3s on the worker node and join it to the existing cluster.
   - The installation script will automatically configure the worker node to start the k3s agent and connect it to the master node.

#### 5. **Verify the Node is Added to the Cluster:**
   After the installation process completes, you can verify that the new worker node has successfully joined the cluster.

   From the master node, run the following command:
   ```bash
   sudo kubectl get nodes
   ```

   This will show a list of all the nodes in the cluster. The new worker node should now be listed as a `Ready` node in the cluster. You should see an entry similar to:

   ```
   NAME               STATUS   ROLES    AGE     VERSION
   master-node        Ready    master   12d     v1.24.0+k3s1
   new-worker-node    Ready    <none>   5m      v1.24.0+k3s1
   ```

#### 6. **Verify Worker Node’s Pods:**
   Ensure that the worker node is properly handling workloads and can schedule pods by checking the pods running on the node:
   
   ```bash
   kubectl get pods -o wide
   ```

   If everything is set up correctly, the pods should be distributed across both the master and the new worker node.

---

### Troubleshooting:
- **Network Connectivity:** Ensure that the worker node can communicate with the master node on port 6443 (default API server port for k3s). If there are network issues, make sure firewall rules are properly configured.
  
- **Token Errors:** If you see an error related to the token, ensure the `K3S_TOKEN` used on the worker node matches the token on the master node and that the token is still valid.

- **Firewall Issues:** If you face issues joining the cluster, check the firewall settings on both the master and worker nodes to ensure that the required ports are open (6443 for the k3s API server, 10250 for kubelet, etc.).

---

### Optional: Update Cluster Configuration for the New Node
If you need to modify the role or other configurations of the worker node, you can use `kubectl` commands from the master node. For instance, to label the new node with a custom role, you can run:
```bash
kubectl label nodes <worker-node-name> role=<custom-role>
```

---

### Conclusion:
You’ve now successfully added a new worker node to your existing k3s cluster! The new node should be available for scheduling Kubernetes workloads, and you can scale your cluster further by adding more worker nodes following the same procedure.
