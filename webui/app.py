# app.py
import streamlit as st
import requests

# Title
st.title("My Streamlit App")

# Slider input
number = st.slider("Pick a number", min_value=0, max_value=100, value=10)

# Display output
st.write(f"The square of {number} is {number**2}")

st.title("Trigger FastAPI Task")

# Input: duration
duration = st.number_input("Duration (seconds)", min_value=1, value=60)

if st.button("Start Task"):
    try:
        # Send POST request to FastAPI.
        url = f"http://fastapi:8000/task/sleep?duration={duration}"
        response = requests.post(url, headers={"Content-Type": "application/json"})
        
        if response.status_code == 200:
            st.success(f"Task started: {response.json()}")
        else:
            st.error(f"Error {response.status_code}: {response.text}")
    except Exception as e:
        st.error(f"Request failed: {e}")

st.title("Check Task Status")

# Input: Task ID
task_id = st.text_input("Task ID", "")

if st.button("Check Status") and task_id:
    try:
        # Replace localhost with FastAPI service name if in Docker
        url = f"http://fastapi:8000/task/{task_id}"
        response = requests.get(url)

        if response.status_code == 200:
            st.success(f"Task status: {response.json()}")
        else:
            st.error(f"Error {response.status_code}: {response.text}")
    except Exception as e:
        st.error(f"Request failed: {e}")