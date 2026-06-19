import os
import streamlit as st

ORDER_API_URL = os.getenv("ORDER_API_URL")
st.title("Streamlit on Azure 👋")
st.header('Running on a Web App in a Container 🐳', divider='rainbow')
st.write(ORDER_API_URL)