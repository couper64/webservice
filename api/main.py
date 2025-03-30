from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel

from pathlib import Path

from celery import Celery
from celery.result import AsyncResult

worker = Celery(
    __name__,
    broker="redis://redis:6379/0", # Change to localhost when running natively.
    backend="redis://redis:6379/0", # Change to redis when running inside a container.
)

api = FastAPI()


class RootResponse(BaseModel):
    message: str
    date: str
    time: str
    timezone: str


@api.get("/", response_model=RootResponse)
async def root():

    # Get current time in UTC
    now = datetime.now(timezone.utc)

    return RootResponse(
        message    = "Welcome to a web service developed by couper64!"
        , date     = f"{now.strftime('%Y-%m-%d')}"
        , time     = f"{now.strftime('%H:%M:%S')}"
        , timezone = f"{now.strftime('%Z%z')}"
    )

# The keyword include_in_schema=False included in the decorator hides the path operation from the schema used to autogenerate API docs.
# The reason is that favicon requests (/favicon.ico) are automatically sent by browsers, but they are not part of the API’s core functionality. Including it in the schema could clutter the auto-generated API documentation (e.g., Swagger UI), which should focus on actual API endpoints. By using include_in_schema=False, you keep the API docs clean while still serving the favicon when requested.
@api.get('/favicon.ico', include_in_schema=False)
async def favicon():

    # The / operator in Path objects is overloaded to work as a path concatenation operator in Python’s pathlib module.
    return FileResponse(Path(__file__).parent / "favicon.ico")


@api.post("/task/sleep")
async def run_task(duration : float):
    result: AsyncResult = worker.send_task("sleep_task", kwargs={"duration": duration})
    return {"task_id": result.id}


@api.get("/task/{task_id}")
async def get_task_status(task_id : str):
    result : AsyncResult = AsyncResult(task_id)
    return {"status": result.status, "result": result.result}
