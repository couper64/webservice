from celery import Celery

celery = Celery(
    __name__,
    broker="redis://redis:6379/0", # Change to localhost when running natively.
    backend="redis://redis:6379/0", # Change to redis when running inside a container.
)

# Use autodiscover_tasks to load tasks automatically.
celery.autodiscover_tasks(["app.task.sleep_task"])
