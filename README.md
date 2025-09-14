# A Web Service

This is a web service based on FastAPI.

For the software to work, I had to assume a couple of things. Firstly, the software was developed for Ubuntu 24.04 OS as it is considered one of the most common and, perhaps, the easiest Linux distribution to obtain, maintain, and develop for. And, in my opinion, that ubiquity also helps passing down the software from one person to another. Secondly, the software is developed with Docker in mind, but native installation is also possible as an additional option. Thirdly, the operating system has been setup in a certain way that is documented in the [main manual](https://vladislav.li/manual/).

# How to Copy

Once the computer is booted up and a user is logged in. Open a terminal to download the code and switch the repo directory.

    git clone git@github.com:couper64/webservice.git webservice
    cd webservice

# How to Make .env File

Below is an example of a `.env` created in the root folder of the project. The file is used in `docker-compose.yml`.

    POSTGRES_PASSWORD=password
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

# How to Run using Native Commands

Once the project is [cloned](#how-to-copy), the commands below will setup a `conda` environment.

    conda create -yn webservice python=3
    conda activate webservice
    pip install -r api/requirements.txt -r webui/requirements.txt -r worker/requirements.txt

Open a terminal in the root folder of the project and run the following command.

    fastapi dev api/main.py

To run `celery`, the following command will launch it from a terminal, in Windows.

> :warning: To run this command, install `eventlet`, e.g. `pip install eventlet`.

    celery -A worker.main worker --loglevel=info -P eventlet

On Linux, we could use a regular command.

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

To check the status of `redis-server.service`, on Linux and WSL.

    sudo systemctl status redis-server.service

# How to Test using Terminal

From PowerShell, the following command will create a task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/sleep?duration=60" `
        -Method Post `
        -Headers @{ "Content-Type" = "application/json" }

From the Ubuntu terminal, the following command will create a task.

    curl -L -X POST "http://localhost:8000/task/sleep?duration=60" \
        -H "Content-Type: application/json"

From PowerShell, the following command will check the status of the task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b" `
        -Method Get

From the Ubuntu terminal, the following command will check the status of the task.

    curl -X GET "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b"

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

# Integration

This `webservice` is used to ease both the development and integration. When a developer uses this project, they could develop on their own by deploying everything locally and ensure everything is operational. However, during the integration, the project is added as a *component* and its local `docker-compose.yml` is utilised for a global `docker-compose.yml` that is composed of all the `docker-compose.yml` files found in the *components* of the more global project.