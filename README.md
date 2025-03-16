# Gitlab CI/CD with Ansible for Spring Boot Dockerized App Deployment

## Continuous Development Pipeline Setup on Gitlab

### Step 1 - Creating a gitlab repository
At the very first, you will need to create a gitlab repository for the application you want to deploy. Then, you will need to add a `Dockerfile` to build the image of the application.

### Step 2 — Registering a GitLab Runner
In order to install the `gitlab-runner` service, you’ll add the official GitLab repository. Download and inspect the install script:

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

sudo apt-get install gitlab-runner
systemctl status gitlab-runner
```

You can create new project runner in gitlab CI/CD settings. After that, you will need to register the project runner in your server in which `gitlab-runner` instance is running. Use the following command to register:

```bash
gitlab-runner register
```

To register the runner you will need to add the following parameters in the prompt:
- Enter your GitLab instance URL (ex. https://gitlab.your-company.com/)
- Enter the registration token for the runner
- Enter runner description
- Choose an exectutor (we are choosing a `docker` environment to provide an image in the next prompt in which every job will run on by default)


To examine the configuration, you can use the following command:

```bash
cat /etc/gitlab-runner/config.toml
```

You will see something like below in `config.toml`
```bash
[[runners]]
  name = "Docker Runner for Spring Boot App"
  url = "https://gitlab.my-company.com"
  id = 125
  token = "glrt-t3_NUXvG4KPa94t"
  token_obtained_at = 2024-11-14T08:05:45Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "docker:24.0.5"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/runner/services/docker", "/var/data/jenkins:/var/data/jenkins"]
    shm_size = 0
    network_mtu = 0
```

### Step 3 — Creating a Deployment User
```bash
sudo adduser gitlab-runner
sudo usermod -aG docker gitlab-runner [Add the deployment user to docker group to give access for running docker commands]
```

### Step 4 — Setting Up an SSH Key

```bash
su gitlab-runner
```
Generate a 4096-bit SSH key. It is important to know the prompt-questions of the `ssh-keygen` command correctly:
- Enter the location to store ssh key
- Enter a passphrase to add another security layer

You can skip the both questions to continue with the default value.

```bash
ssh-keygen -b 4096
```

To authorize the SSH key for the `gitlab-runner` user, you need to append the public key to the authorized_keys file:

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

### Step 5 — Storing the Private Key in a GitLab CI/CD Variable
Now, you can add the ssh key as a variable in Gitlab CI/CD variable settings for authentication.

### Step 5 — Configuring the .gitlab-ci.yml File

You can define `stages` in order the way you want them to be executed. Also, you can define variables in `variables` section.

Gitlab pipeline is composed with `jobs`. Each job has the following sections:
- stage
- tags
- image
- script [to execute the shell commands]
- artifacts
- only [defines the names of branches and tags for which the job will run]

In the `script` section, you will need to run the ansible playbook to deploy the application:
```bash
ansible-playbook -i ansible/inventory/dev.ini ansible/playbook.yml -e "ENV=dev" --ssh-extra-args="-o StrictHostKeyChecking=no"
```