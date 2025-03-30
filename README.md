# A Web Service

This is a web service based on FastAPI.

# Installation

Open a terminal with the installed Conda package manager and run the following commands.

    git clone git@github.com:couper64/webservice.git
    cd webservice
    conda create -yn webservice python=3
    conda activate webservice
    pip install -r requirements.txt

# How to Run from Terminal

Open a terminal in the root folder of the project and run the following command.

    fastapi dev app/main.py

To run `celery`, the following command will launch it from a terminal, in Windows.

> :warning: To run this command, install `eventlet`, e.g. `pip install eventlet`.

    celery -A app.celery_worker worker --loglevel=info -P eventlet

The rest could use a regular command.

    celery -A app.celery_worker worker --loglevel=info

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

From PowerShell, the following command will check the status of the task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b" `
        -Method Get

To check the status of `redis-server.service`, on Linux and WSL.

    sudo systemctl status redis-server.service

# How to Run Dockerfile

Open a terminal in the root folder of the project and run the following command to build the Docker image.

    docker build -t fastapi-app -f Dockerfile.fastapi .
    docker build -t celery-app -f Dockerfile.celery .

Create a single network for all of the containers involved in the project.

    docker network create webservice

The following command will run the container in "*detached*" mode with the same name as the Docker image whilst forwarding host's port 8000 to container's port 8000.

    docker run -d --network webservice --name fastapi-app --rm --publish 8000:8000 fastapi-app
    docker run -d --network webservice --name celery-app --rm celery-app

To view the status of the container, this command will show the logs in real-time.

    docker logs -f fastapi-app
    docker logs -f celery-app

# How to Run Redis

From the terminal, run the following command.

    docker run -d --network webservice --name redis --rm redis

# How to Run PostgreSQL

From the terminal, run the following command.

> :warning: Don't forget to change the password!

    docker run -d --network webservice --name postgres -e POSTGRES_PASSWORD=mysecretpassword --rm postgres

Additionally, if there isn't any web interface available, the following command will start `pgadmin4`.

> :warning: Don't forget to change the email and password!

    docker run -d --name pgadmin4 -e "PGADMIN_DEFAULT_EMAIL=test@test.com" -e "PGADMIN_DEFAULT_PASSWORD=test1234" -p 8080:80 dpage/pgadmin4

# How to Run MinIO

From the terminal, run the following command.

> :warning: Don't forget to change the email and password!

    mkdir -p data

    docker run \
        -p 9000:9000 \
        -p 9001:9001 \
        --name minio \
        -v data:/data \
        -e "MINIO_ROOT_USER=ROOTNAME" \
        -e "MINIO_ROOT_PASSWORD=CHANGEME123" \
        quay.io/minio/minio server /data --console-address ":9001"

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

Use `celery` with `redis` to create asynchronous task execution with task queueing. Integrate the idea of "*Returning Task ID and Checking Progress via Polling*" at, for example, the `/task-status/{task_id}` endpoint. Otherwise, experiment with the WebSocket connection.

Store the results in a file server using `minio`. In case of textual information, store the results in a database using `postgresql`.

Configure a `docker-compose.yml` file to run the entire project with the dependencies at once.