# In general, the best practice is to import only what you need (option 1) for clarity and performance, unless you expect to use several items from the module (option 2).
from time import sleep
from app.celery_worker import celery

@celery.task(name="sleep_task")
def sleep_task(duration : float):

    # Do the task.
    sleep(duration)

    return f"Slept for {duration}"