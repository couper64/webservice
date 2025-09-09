from datetime import datetime, timezone, timedelta

from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel

from pathlib import Path
from minio import Minio

from api.router import task


MINIO_BUCKET_NAME : str = "webservice"


api = FastAPI()

api.include_router(task.router)

# MinIO client.
minio_client = Minio(
    endpoint="minio:9000", # MinIO endpoint
    access_key="ROOTNAME",
    secret_key="CHANGEME123",
    secure=False # set True if using https
)

# Ensure bucket exists
if not minio_client.bucket_exists(MINIO_BUCKET_NAME):
    minio_client.make_bucket(MINIO_BUCKET_NAME)


class RootResponse(BaseModel):
    message: str
    date: str
    time: str
    timezone: str

class UrlResponse(BaseModel):
    url: str
    expires: float # `timedelta` - an ISO 8601 duration ("PT1H") is dicouraged due to many industry guidelines and API design standards recommend representing durations simply as seconds—preferably as integers or floats.


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

@api.get("/file/get/url/upload/", response_model=UrlResponse)
def generate_upload_url(filename: str):
    # Expire in 1 hour.
    url = minio_client.presigned_put_object(
        MINIO_BUCKET_NAME,
        filename,
        expires=timedelta(hours=1),
    )

    # Because behind a proxy replace container with actual calling URL.
    url = url.replace("http://minio:9000/", "/minio/api/")

    return UrlResponse(
        url       = url
        , expires = timedelta(hours=1).total_seconds()
    )

@api.get("/file/get/url/download/", response_model=UrlResponse)
def generate_download_url(filename: str):
    url = minio_client.presigned_get_object(
        MINIO_BUCKET_NAME,
        filename,
        expires=timedelta(hours=1)
    )

    # Because behind a proxy.
    url = url.replace("http://minio:9000/", "/minio/api/")

    return UrlResponse(
        url       = url
        , expires = timedelta(hours=1).total_seconds()
    )