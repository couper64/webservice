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

    fastapi dev main.py

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
