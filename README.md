# A Web Service

This is a web service based on FastAPI.

# How to Make .env File

Below is an example of a `.env` created the root folder of the project.

    NETWORK_NAME=webservice

    VOLUME_MINIO=minio_data
    VOLUME_POSTGRES=postgres_data
    VOLUME_PGADMIN4=pgadmin4_data

    CONTAINER_POSTGRES=postgres
    CONTAINER_MINIO=minio
    CONTAINER_REDIS=redis
    CONTAINER_PGADMIN=pgadmin4
    CONTAINER_FASTAPI=fastapi_app
    CONTAINER_CELERY=celery_app

    POSTGRES_PASSWORD=mysecretpassword
    MINIO_ROOT_USER=ROOTNAME
    MINIO_ROOT_PASSWORD=CHANGEME123
    PGADMIN_DEFAULT_EMAIL=admin@admin.com
    PGADMIN_DEFAULT_PASSWORD=admin

# How to Run using Docker Compose

The command below will build any updated images and start the containers in detached mode.

    docker compose up --build --detach

Run the command below in the same directory as your docker-compose.yml to stop and remove all containers, networks, and volumes created by the stack.

    docker compose down --volumes

Use command below to restart only that specific container without affecting the others.

    docker compose restart <service_name>

Add the new service definition to `docker-compose.yml` and run command below to start it without disrupting the rest.

    docker compose up --detach <service_name>

Use the command below to view the logs in real-time (`-f`).

    docker compose logs -f

To view an individual container in real-time (`-f`) use the command below.

    docker compose logs -f <service_name>

# How to Run Docker CLI from Terminal

These are instructions for the deployment. For the software to work, I had to assume a couple of things. Firstly, the software was developed for Ubuntu 24.04 OS as it is considered one of the most common and, perhaps, the easiest Linux distribution to obtain, maintain, and develop for. And, in my opinion, that ubiquity also helps passing down the software from one person to another. Secondly, the software is developed with Kubernetes and Docker in mind, but native installation is also possible as an additional option. Thirdly, the operating system has been setup in a certain way that is documented in the [main manual](https://vladislav.li/manual/).

Once the computer is booted up and a user is logged in. Open a terminal to download the code and switch the repo directory.

> :info: We are using `psycopg` instead of `psycopg2` and `psycopg2-binary` as it is deemed to be next-generation async-capable PostgreSQL driver for async applications (FastAPI, asyncio, etc.).

    git clone git@github.com:couper64/webservice.git webservice
    cd webservice

All of the dependencies should be on the same network for a sucessfull communication.

    docker network list

If network doesn't exist than create a new one. Create a single network for all of the containers involved in the project.

    docker network create webservice

The dependencies of the webservice should be initialised before the API. Starting from PostgreSQL.

> :warning: Don't forget to change the email and password!

    docker run -d --network webservice --name postgres -e POSTGRES_PASSWORD=mysecretpassword --rm postgres

Create folder for file storage.

    mkdir -p data

To run MinIO service.

    docker run \
        -d \
        --network webservice \
        -p 9000:9000 \
        -p 9001:9001 \
        --name minio \
        -v data:/data \
        -e "MINIO_ROOT_USER=ROOTNAME" \
        -e "MINIO_ROOT_PASSWORD=CHANGEME123" \
        quay.io/minio/minio server /data --console-address ":9001"

To run Redis.

    docker run -d --network webservice --name redis --rm redis

Additionally, if there isn't any web interface available, the following command will start `pgadmin4`.

> :warning: Don't forget to change the email and password!

    docker run -d --network webservice -p 8080:80 --name pgadmin4 -e "PGADMIN_DEFAULT_EMAIL=test@test.com" -e "PGADMIN_DEFAULT_PASSWORD=test1234" dpage/pgadmin4

In the same terminal in the root folder of the project run the following command to build the Docker images.

    docker build -t fastapi-app -f Dockerfile.fastapi .
    docker build -t celery-app -f Dockerfile.celery .

The following command will run the container in "*detached*" mode with the same name as the Docker image whilst forwarding host's port 8000 to container's port 8000.

    docker run -d --network webservice --name fastapi-app --rm --publish 8000:8000 fastapi-app
    docker run -d --network webservice --name celery-app --rm celery-app

To view the status of the container, this command will show the logs in real-time.

    docker logs -f fastapi-app
    docker logs -f celery-app

# How to Natively Run from Terminal

Once the computer is booted up and user logged in. Open a terminal with the installed Conda package manager and run the following commands.

    git clone git@github.com:couper64/webservice.git webservice
    cd webservice
    conda create -yn webservice python=3
    conda activate webservice
    pip install -r requirements.txt

Open a terminal in the root folder of the project and run the following command.

    fastapi dev api/main.py

To run `celery`, the following command will launch it from a terminal, in Windows.

> :warning: To run this command, install `eventlet`, e.g. `pip install eventlet`.

    celery -A worker.main worker --loglevel=info -P eventlet

The rest could use a regular command.

    celery -A worker.main worker --loglevel=info

To setup `redis`, on Windows, it requires WSL2, by default, it is Ubuntu. The following should be run with Administrator privileges from PowerShell.

    wsl --update
    wsl --install

Inside Ubuntu, the following command should get us running.

    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

    sudo apt-get update
    sudo apt-get install redis

    sudo service redis-server start

Once Redis is running, you can test it by running redis-cli:

    redis-cli

Test the connection with the ping command:

    127.0.0.1:6379> ping

Expected output is `PONG`.

# How to Test from Terminal

From PowerShell, the following command will create a task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/sleep/?duration=60" `
        -Method Post `
        -Headers @{ "Content-Type" = "application/json" }

From the Ubuntu terminal, the following command will create a task.

    curl -L -X POST "http://localhost:8000/task/sleep/?duration=60" \
        -H "Content-Type: application/json"

From PowerShell, the following command will check the status of the task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b" `
        -Method Get

From the Ubuntu terminal, the following command will check the status of the task.

    curl -X GET "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b"

To check the status of `redis-server.service`, on Linux and WSL.

    sudo systemctl status redis-server.service

# Project Structure

Following the advices on the [official documentation](https://fastapi.tiangolo.com/tutorial/bigger-applications/), [GitHub](https://github.com/zhanymkanov/fastapi-best-practices?tab=readme-ov-file#project-structure), and [Medium](https://medium.com/@amirm.lavasani/how-to-structure-your-fastapi-projects-0219a6600a8f), this project is going to be adhere to a microservice architecture. Thus, the top folder that contains most of the logic will be named `app` as per the [official documentation](https://fastapi.tiangolo.com/tutorial/bigger-applications/).

Knowing the internet, it will be updated and lost forever, so here is a copy of what the project structure is based on.

    .
    ├── app
    │   ├── __init__.py
    │   ├── main.py
    │   ├── dependencies.py
    │   └── routers
    │   │   ├── __init__.py
    │   │   ├── items.py
    │   │   └── users.py
    │   └── internal
    │       ├── __init__.py
    │       └── admin.py

# Roadmap

- [x] Use `celery` with `redis` to create asynchronous task execution with task queueing. Integrate the idea of "*Returning Task ID and Checking Progress via Polling*" at, for example, the `/task-status/{task_id}` endpoint. Otherwise, experiment with the WebSocket connection.
- [x] Store the results in a file server using `minio`. In case of textual information, store the results in a database using `postgresql`.
- [x] Configure a `docker-compose.yml` file to run the entire project with the dependencies at once.