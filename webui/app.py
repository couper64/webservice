# app.py
import streamlit as st

# Title
st.title("My First Streamlit App")

# Slider input
number = st.slider("Pick a number", min_value=0, max_value=100, value=10)

# Display output
st.write(f"The square of {number} is {number**2}")
