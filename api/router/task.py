from fastapi import APIRouter
from celery.result import AsyncResult

from api.worker import worker

router = APIRouter(
    prefix="/task",
    tags=["task"],
)


@router.post("/sleep")
async def run_task(duration : float):
    result: AsyncResult = worker.send_task("sleep_task", kwargs={"duration": duration})
    return {"task_id": result.id}


@router.get("/{task_id}")
async def get_task_status(task_id : str):
    result : AsyncResult = AsyncResult(task_id)
    return {"status": result.status, "result": result.result}