# 🚀 Habit Tracker – End-to-End CI/CD & GitOps Deployment on Amazon EKS

A Spring Boot-based Habit Tracker REST API and dashboard, integrated with a production-oriented CI/CD pipeline using **Jenkins, Maven, SonarQube, Docker, Trivy, Helm, Argo CD and Amazon EKS**.

This project demonstrates automated application builds, code quality analysis, container security scanning, Docker image publishing, GitOps-based deployment and continuous reconciliation on Kubernetes.

---

## 🏗️ Project Architecture

```text
                 Developer
                     |
                     ▼
              GitHub Repository
                     |
                     ▼
                  Jenkins
                     |
          ┌──────────┼───────────┐
          ▼          ▼           ▼
        Maven     SonarQube     Tests
       Build       Analysis
          |          |
          └────┬─────┘
               ▼
          Quality Gate
               |
               ▼
          Docker Build
               |
               ▼
          Trivy Scan
               |
               ▼
          Docker Hub
               |
               ▼
       Update GitOps Repository
               |
               ▼
             Argo CD
               |
          Automatic Sync
               |
               ▼
          Helm Deployment
               |
               ▼
          Amazon EKS
               |
               ▼
        Habit Tracker Application
```

### CI/CD Workflow

1. Developer pushes application changes to GitHub.
2. Jenkins automatically checks out the source code.
3. Maven compiles the application and executes tests.
4. SonarQube performs static code analysis.
5. Jenkins verifies the SonarQube Quality Gate.
6. Docker builds the application image.
7. Trivy scans the image for vulnerabilities.
8. Jenkins pushes the image to Docker Hub.
9. Jenkins updates the image tag in the GitOps repository.
10. Argo CD detects the GitOps repository changes.
11. Helm deploys the updated application to Amazon EKS.
12. Argo CD continuously reconciles the cluster with the GitOps repository.

**Important:** Jenkins handles Continuous Integration (CI), while Argo CD handles Continuous Delivery (CD). Kubernetes deployment is managed through GitOps rather than direct `kubectl` deployment from Jenkins.

---

## 🛠️ Technology Stack

| Category | Technologies |
|---|---|
| Application | Java 21, Spring Boot |
| Build Tool | Maven |
| Source Control | Git, GitHub |
| CI/CD | Jenkins |
| Code Quality | SonarQube |
| Containerization | Docker |
| Security Scanning | Trivy |
| Container Registry | Docker Hub |
| Container Orchestration | Kubernetes, Amazon EKS |
| Package Management | Helm |
| GitOps | Argo CD |
| Monitoring | Kubernetes health probes, Spring Boot Actuator |

---

## 📂 Project Repositories

| Repository | Description |
|---|---|
| [Application Repository](https://github.com/Akcodez-cmd/project5) | Java application, Dockerfile and Jenkinsfile |
| [GitOps Repository](https://github.com/Akcodez-cmd/project5-gitops) | Helm charts and Kubernetes deployment configuration |

**Docker Hub:** [ajith7550/habit-tracker](https://hub.docker.com/r/ajith7550/habit-tracker)

---

## ⚙️ Application Overview

The Habit Tracker application provides a REST API and dashboard for managing daily and weekly habits.

### Features

- Create, update and delete habits.
- Activate and deactivate habits.
- Mark habits as completed.
- Track current and longest streaks.
- Calculate last-seven-day completion rates.
- View habit statistics.
- Monitor application health through Spring Boot Actuator.

### Application Technology

- Java 21
- Spring Boot
- Spring Web
- Spring Validation
- Spring Boot Actuator
- Maven
- Vanilla HTML, CSS and JavaScript dashboard

**Database:** No external database is configured. Application data is stored in memory using `ConcurrentHashMap`. Restarting the application clears the stored data.

---

## 🔌 REST API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/habits` | List all habits |
| GET | `/api/habits/{id}` | Get a single habit |
| POST | `/api/habits` | Create a habit |
| PUT | `/api/habits/{id}` | Update a habit |
| DELETE | `/api/habits/{id}` | Delete a habit |
| PATCH | `/api/habits/{id}/active` | Activate/deactivate a habit |
| POST | `/api/habits/{id}/complete` | Mark habit completed |
| DELETE | `/api/habits/{id}/complete` | Unmark completion |
| GET | `/api/habits/{id}/stats` | Get streak and completion statistics |

### Application Health Endpoints

| Endpoint | Purpose |
|---|---|
| `/actuator/health` | Overall application health |
| `/actuator/health/liveness` | Kubernetes liveness probe |
| `/actuator/health/readiness` | Kubernetes readiness probe |

---

## 🐳 Docker Configuration

The application uses a multi-stage Docker build.

### Docker Image

```text
ajith7550/habit-tracker
```

Example image tag:

```text
4-f371a84
```

The image tag combines the Jenkins build number and Git commit hash to identify the exact application build.

### Docker Build

```bash
docker build -t habit-tracker:latest .
```

### Docker Run

```bash
docker run -d \
  --name habit-tracker \
  -p 8080:8080 \
  habit-tracker:latest
```

Application:

```text
http://localhost:8080
```

---

## 🔍 Code Quality – SonarQube

SonarQube is integrated into the Jenkins pipeline.

The pipeline performs:

- Static code analysis.
- Code quality checks.
- Quality Gate verification.
- Analysis reporting.

The Jenkins pipeline waits for the SonarQube Quality Gate before proceeding with Docker image creation.

---

## 🛡️ Container Security – Trivy

Trivy is integrated into Jenkins to scan Docker images for security vulnerabilities.

The pipeline generates a vulnerability report and uses a configured security threshold to determine whether the build can continue.

The scan is configured to fail the pipeline when HIGH or CRITICAL vulnerabilities are detected.

---

## ☸️ Kubernetes Deployment – Amazon EKS

The application is deployed to Amazon Elastic Kubernetes Service (EKS).

### Cluster Information

| Configuration | Value |
|---|---|
| Cloud Provider | AWS |
| Kubernetes Platform | Amazon EKS |
| AWS Region | `ap-south-1` |
| Cluster Name | `project5-eks-cluster` |
| Kubernetes Version | `1.37` |
| Worker Node Type | `t3.small` |
| Container Port | `8080` |
| Service Type | ClusterIP |
| Replicas | 1 |

### Helm Configuration

The GitOps repository contains the Helm chart used to deploy the application.

The chart manages:

- Kubernetes Deployment.
- Kubernetes Service.
- Service Account.
- Container image and version.
- Resource requests and limits.
- Liveness and readiness probes.

### Resource Configuration

| Resource | Request | Limit |
|---|---:|---:|
| CPU | 100m | 500m |
| Memory | 256Mi | 512Mi |

### Health Probes

The Kubernetes Deployment uses Spring Boot Actuator endpoints:

```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: http

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: http
```

---

## 🔄 GitOps – Argo CD

Argo CD manages application deployment and continuously monitors the GitOps repository.

### GitOps Configuration

- Repository: `project5-gitops`
- Branch: `main`
- Application: `habit-tracker`
- Deployment package: Helm
- Sync Policy: Automatic
- Prune Resources: Enabled
- Self Heal: Enabled
- Auto Create Namespace: Enabled

### GitOps Deployment Flow

When Jenkins pushes a new Docker image tag to the GitOps repository:

1. Argo CD detects the new Git commit.
2. Argo CD compares the desired state with the live Kubernetes state.
3. Helm renders the updated Kubernetes manifests.
4. Argo CD synchronizes the changes.
5. Kubernetes creates the updated application deployment.

Argo CD maintains the desired state defined in Git.

---

## 🚀 Local Development

### Requirements

- JDK 21+
- Maven 3.6+
- Git

### Clone Repository

```bash
git clone https://github.com/Akcodez-cmd/project5.git

cd project5
```

### Build Application

```bash
./mvnw clean verify
```

On Windows:

```cmd
mvnw.cmd clean verify
```

### Run Application

```bash
java -jar target/habit-tracker.jar
```

Open:

```text
http://localhost:8080
```

---

## 📸 Project Evidence

Screenshots demonstrating the completed CI/CD and GitOps workflow can be added here.

Suggested evidence:

- Jenkins successful pipeline execution.
- SonarQube Quality Gate.
- Trivy security scan report.
- Docker Hub image repository.
- GitHub application and GitOps repositories.
- Argo CD Healthy and Synced application.
- Amazon EKS cluster and worker nodes.
- Running Habit Tracker Kubernetes pod.
- Application health endpoint response.

---

## 🎯 Key Learning Outcomes

Through this project, I gained practical experience in:

- Building an end-to-end Jenkins CI/CD pipeline.
- Automating Maven builds and test execution.
- Integrating SonarQube Quality Gate into Jenkins.
- Building and scanning Docker images.
- Publishing versioned Docker images.
- Implementing GitOps deployment using Argo CD.
- Managing Kubernetes applications using Helm.
- Deploying Java applications on Amazon EKS.
- Configuring Kubernetes health probes and resource limits.
- Automating deployments through Git-based desired-state management.

---

## 👨‍💻 Author

**Ajith Kumar R**

Software Engineer | Cloud & DevOps Engineer

- LinkedIn: [Ajith Kumar](https://www.linkedin.com/in/ajithkumar-dev01/)
- Portfolio: [ajithkumar.space](https://www.ajithkumar.space/)
- GitHub: [Akcodez-cmd](https://github.com/Akcodez-cmd)