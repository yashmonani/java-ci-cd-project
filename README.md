# 🚀 End-to-End DevSecOps Kubernetes Pipeline

![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen) ![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.30-blue) ![Jenkins](https://img.shields.io/badge/Jenkins-2.4-red) ![SonarQube](https://img.shields.io/badge/SonarQube-LTS-blueviolet)

A comprehensive **DevSecOps Pipeline** that automates the deployment of a Java Spring Boot application to a Kubernetes cluster. This project demonstrates a real-world CI/CD workflow integrating **Code Quality (SonarQube)**, **Container Security (Trivy)**, and **Multi-Environment Deployment (Dev, UAT, Prod)**.

---

## 📖 Table of Contents
- [Architecture](#-architecture)
- [Technologies Used](#-technologies-used)
- [Pipeline Workflow](#-pipeline-workflow)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Configuration & Credentials](#-configuration--credentials)
- [How to Run](#-how-to-run)

---

## 🏛 Architecture
<img width="2807" height="887" alt="diagram-export-1-3-2026-4_20_12-PM" src="https://github.com/user-attachments/assets/93146ea7-c37d-48ab-a51a-ba07a4c9cff2" />

---

## 🛠 Technologies Used

### **Application**
* **Language:** Java (Spring Boot)
* **Build Tool:** Maven
* **Container:** Docker (Multi-Stage Build)

### **DevOps Infrastructure**
* **CI/CD Server:** Jenkins
* **Orchestration:** Kubernetes (Self-Managed Cluster)
* **Artifact Registry:** Docker Hub
* **Infrastructure:** AWS EC2 (RedHat/Linux)

### **Security & Quality**
* **SonarQube:** Static Code Analysis (Bugs, Code Smells, Vulnerabilities)
* **Trivy:** Container Image Scanning (CVE Detection)
## 🔄 Pipeline Workflow
The `Jenkinsfile` defines the following stages:

1.  **Checkout SCM:** Pulls the latest code from GitHub.
2.  **Build Maven:** Compiles the Java application into a `.jar` artifact.
3.  **SonarQube Analysis:** Scans source code for quality issues and reports to the SonarQube server.
4.  **Build Docker Image:** Creates a lightweight container using a Multi-Stage Dockerfile.
5.  **Trivy Security Scan:** Scans the Docker image for Critical vulnerabilities. *Build fails if vulnerabilities are found.*
6.  **Push to Registry:** Uploads the verified image to Docker Hub.
7.  **Deploy to Dev:** Updates the `dev` namespace in Kubernetes.
8.  **Deploy to UAT:** Updates the `uat` namespace for final testing.
9.  **Manual Approval:** Pauses the pipeline and waits for human confirmation.
10. **Deploy to Prod:** Updates the `prod` namespace (Live environment).
11. **Cleanup:** Removes local Docker images to save disk space.

---

## ✅ Prerequisites
Before running this pipeline, ensure you have:

1.  **Jenkins Server:** with Docker, Maven, and Trivy installed.
2.  **Kubernetes Cluster:** A working cluster (Master + Worker nodes).
3.  **SonarQube Server:** Running via Docker on port 9000.
4.  **Plugins:**
    * SonarQube Scanner
    * Docker Pipeline
    * Kubernetes CLI

---

## 📂 Project Structure

```bash
├── src/                
├── k8s/                 
│   ├── deployment-dev.yaml
│   ├── deployment-uat.yaml
│   ├── deployment-prod.yaml
│   ├── service.yaml
├── Jenkinsfile          
├── Dockerfile           
├── pom.xml             
└── README.md            

---

## 🔐 Configuration & Credentials
You must configure the following credentials in Jenkins (**Manage Jenkins > Credentials**):

| ID | Type | Description |
| :--- | :--- | :--- |
| `docker-creds` | Username with Password | Docker Hub Login |
| `sonar-token` | Secret Text | SonarQube Authentication Token |
| `kubeconfig` | Secret File | Kubernetes Config File (`~/.kube/config`) |

### **Environment Variables (in Jenkinsfile)**
You will need to update these variables at the top of your `Jenkinsfile` to match your own details:

* `DOCKER_HUB_USER`: Your Docker Hub username 
* `APP_NAME`: Name of the Docker image (e.g., `java-spring-app`)
* `IMAGE_TAG`: The tag versioning strategy (Default: `${BUILD_NUMBER}`)
