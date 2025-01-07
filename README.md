# All Docker commands while I learnt docker

1. docker run <image>
2. docker stop <container_ID> or docker stop <container_name>
3. docker run -it <image> bash 
    1. opens a session and auto-saves all the actions performed.
4. docker ps -a 
    1. lists all the containers in all states - running, exited.
5. docker pull <image_name>
    1. pulls an image from dockerhub if not present locally.
6. docker rmi <image_name>
    1. note: while removing make sure none of the containers are using the image.

[Continued]

1. docker run centos
2. docker run -it centos bash
3. docker run -it centos sleep 2000 
4. docker stop <container_ID of the above container>
5. docker rm <container_ID>
6. docker ***rmi*** <image_name> 
    1. you cannot remove an image if it is being used by a running container
    2. you need to stop the container and then remove the container and then the image
7. docker exec <container_ID> command
    1. Note: the container must be running before execution
8. List container with specific image used
    1. docker ps -f name=value
        1. ex: docker ps -f name=nginx1.1

## Docker with Jenkins

1. docker in detached mode and attached mode
    1. docker run -d ubuntu sleep 1000 - will make the container run in background 
    2. docker attach <conatiner_id> - this will bring the container running in background to foreground
2. docker inspect 
    1. This command will give detailed information about the container.
3. Install docker using:
    1. docker run jenkins/jenkins
        1. This will initiate a jenkins container, we cannot access it because it has an IP which is inaccessible. To make it accesible to node port or our host port we use the below
    2. docker run -p 8080:8080  jenkins/jenkins
        1. Once we shut down our container after doing this, the state and all the dependencies will be lost. In order to save the state and other container data we attach a volume
    3. docker run -p 8080:8080 -v /Users/madhug/POC-DevOps/Docker/jenkins-data:/var/jenkins_home jenkins/jenkins
        1. Here the volume is mapped in this format <local_folder>:<jenkins_folder>.

## Docker environment variables

1. to pass a docker environment variable through commandline, use 
    1. docker run **-e <key>=<value>** simple_webapp
2. To inspect a docker environment variable
    1. docker inspect <container_name> 
        1. you will find it under config section of the output

## Docker command & entrypoint [CMD & ENTRYPOINT]

Q: How would you start a container with a default command ?

A: That’s when we use CMD. We specify like below

```docker
FROM UBUNTU
CMD sleep 10
```

Now there are 2 ways of passing the commands through dockerfile

1. The command simply
    
    ```docker
    Syntax:
    CMD command parameter1 
    Example:
    CMD sleep 5
    ```
    
2. JSON

```docker
CMD ["command" "parameter"]
example:
CMD ["sleep","5"]
```

The command can be overridden at startup when we run from commandline.

ex: 

```bash
docker run ubuntu sleep 10
```

This will override **Sleep 5** which is the default command at container startup.

Q: How do you start a container without the default environment variable? In such a way that we need to pass the parameters from commandline.

A: **ENTRYPOINT** 

```docker
FROM ubuntu
ENTRYPOINT ["sleep"]
```

```bash
docker run ubuntu 10
```

This will take the argument 10 and pass it to the ubuntu container.

Q: What if an argument is not passed? 

A: The container will fail with **argument missing,** We need to pass a default argument to the ENTRYPOINT, this is done using CMD in json format

```docker
FROM ubuntu
ENTRYPOINT ["sleep"]
CMD ["5"]
```

This will pass 5 to the below command and makes the container sleep for 5s.

```bash
docker run ubuntu
```

## Docker Compose

**Problem:** In a microservice architecture, take for example a simple voting app, which consists of the following:

- Front end - voting, results app,
- Data - Redis [In mem-cache]
- Worker
- DB - postgres

To run all these separately, you need to run docker commands multiple times.

Note: There will be no interlinking of these containers. We need to use “docker run ——link” which might be deprecated due to docker swarm. 

```bash
docker run -d --name worker --link redis:redis db:db worker
```

**Solution:**

Use docker compose by creating a simple yaml file which consists of all the containers required and specifications, finally use docker-compose to create all the containers along with links.

- There are 3 versions of docker compose
    
    ![Screenshot 2024-10-06 at 10.56.34 PM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/129e9f6d-2760-45be-b2c8-0dca30471c74/Screenshot_2024-10-06_at_10.56.34_PM.png)
    

## Example-voting-app demo

### Steps:

1. Clone the repo from github
2. Build the voting app from image and run the container
3. Run Redis container
4. Run PostgreSQL container taking reference from the dockerfile
5. Run the worker-app container with links
6. Run the results app container with relavant port mapping and link to db.

### Building the voting app

1. Change dir to voting app

```bash
docker build . -t voting-app
```

1. Run the redis container and then link to voting app

```bash
docker run --name=redis redis
```

1. Link the redis container to voting-app

```bash
docker run -p 5001:80 -d --link redis:redis voting-app
```

### Building worker-app

```bash
docker run --name=worker-app --link redis:redis --link db:db -d worker-app
```

Here you might find an issue with the password, login to the db container, find the file pg_hba.conf → md5 → replace md5 with trust

```bash
docker exec -it db /bin/bash
sed -i 's/md5/trust/g' /var/lib/postgresql/data/pg_hba.conf
```

exit from the container bash, now when you re-run the container with links you must be able to see it running.

### Building the Results app

1. To build the results app we need PostgreSQL(db)

```bash
docker run --name=db -d -e POSTGRES_PASSWORD=password postgres:9.45
```

1. Build the Results-app using the image under ***result*** directory

```bash
docker build -t result-app
```

1. Run the container with link

```bash
docker run --name=result-app -d -p 5002:80 --link db:db result-app
```

## Output:

### Voting-app:

![Screenshot 2024-10-08 at 2.32.55 AM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/44eac3e8-5066-4f5a-a5ae-fcb11bdbf65f/Screenshot_2024-10-08_at_2.32.55_AM.png)

### All Containers:

![Screenshot 2024-10-08 at 2.36.15 AM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/97028c8c-6cc2-49f0-9490-0f5a4a3ef2c1/Screenshot_2024-10-08_at_2.36.15_AM.png)

### Result-app

![Screenshot 2024-10-08 at 2.38.11 AM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/a67009e9-b851-4754-bc98-74424d05247f/Screenshot_2024-10-08_at_2.38.11_AM.png)

# Docker Engine

When we install Docker on our host, we install 3 components:

- **Docker CLI**
    - Interface where we run the commands.
- **REST API**
    - Interface used by programs to talk to the deamon and provide instructions.
- **Docker deamon**
    - Background process that manages docker objects such as images, volumes, containers, & networks.

Note: Docker CLI need not run on the same host as REST, Deamon. 

CLI can be on one machine and Docker Engine can be on another machine.

It can be run on different host using a command option -H as below.

```bash
docker -H=remote-docker-engine:2375
```

![Screenshot 2024-10-09 at 12.53.42 PM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/874dc189-b5c3-4c9c-ae23-19345176ed38/Screenshot_2024-10-09_at_12.53.42_PM.png)

## Containerization in the background

Docker uses namespaces to isolate workspace:

- PID
- networks
- Interprocess
- Unix time sharing
- Mount

All of the above are created with a unique namespace, thereby providing isolation between containers.

**Taking PID as example:**

Whenever a linux system boots up there will be a handful of PIDs. PIDs are always unique. When we create a container, it is a child system and it will have it’s own PIDs

From isolation point of view, container thinks the PIDs are of it’s own, but they are just another set of processes of the main system.

![Screenshot 2024-10-09 at 1.13.56 PM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/048a3bd3-4b34-4d90-8141-0a6017e42664/Screenshot_2024-10-09_at_1.13.56_PM.png)

**Analogy:**

Let’s take an nginx container nginx runs as a service in container which will have a unique PID.

when we check the same PID from the host machine, there will be a different PID, but both the processes are same.

## Docker Storage

Q: How does docker store data ?

A: Default storage is under /var/lib/docker

- under this we have the directories
    - aufs
    - containers
    - images
    - volumes

Understanding layered architecture - docker resuses the exisiting layers, meaning each line in the docker file is considered & built as a layer.

When we build a new image whose config might be similar to the existing config(layers). Docker makes use of the already existing layers and builds upon them, saving up storage.

![Screenshot 2024-10-19 at 6.37.11 PM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/b09a061f-def8-4f86-b49f-56e40b2c94ba/1ac08a68-4210-4dd3-8c25-adfec6fd3d19/Screenshot_2024-10-19_at_6.37.11_PM.png)

### Layered Architecture in-depth

Rearranging the layers from bottom to top, docker builds up from the **FROM** part which will be the base layer upto the **ENTRYPOINT**. Forming the final docker image.

- Once the image is built we **cannot** modify the content of the layers, as it will be in Read-Only format.
- **Copy on Write:** When we run a container based off this image, a copy of the layers will be created inside the container. Contents of this container can be modified but it will be destroyed once the container is destroyed. Therefore, the lifecycle of the contents inside the container is the same as lifecycle of the container.

### Volumes

If we wish to persist the data that is processed on the container, we use docker volumes.

**command:**

```bash
docker volume create <volume_name>
```

This will create a folder in:

/var/lib/docker/

 |—— volume

     |—— volume_name

NOTE: This will only create a volume, but to mount it to the container we use 

```bash
docker run **-v <volume_name>:<path/to/dir> <image_name>**
```

What if we forget to run the docker 

# Key takeaways

## Docker:

- Troubleshooting by logging into container.
- Difference between CMD and RUN

## Docker Compose:

- Importance of environment variables for DB
