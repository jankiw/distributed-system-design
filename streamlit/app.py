import os
import streamlit as st

FLASK_API_URL = os.getenv("FLASK_API_URL")
st.title("Streamlit on Azure 👋")
st.header('Running on a Web App in a Container 🐳', divider='rainbow')
st.write(FLASK_API_URL)