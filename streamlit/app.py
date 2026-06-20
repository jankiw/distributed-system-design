import os
import requests
import streamlit as st

ORDER_API_URL = os.getenv("ORDER_API_URL")
st.title("Streamlit on Azure")

if not ORDER_API_URL:
    st.error("Missing environment variable: ORDER_API_URL")
    st.stop()

st.write(ORDER_API_URL)

if st.button("Post item"):
    endpoint = f"{ORDER_API_URL.rstrip('/products')}/"
    body = {
        'name': 'testProduct',
        'amount': '32',
        'price': '137'
    }
    try:
        response = requests.post(endpoint, json = body, timeout=10)

        if response.status_code == 200:
            data = response.json()
            st.success("Product created!")

        else:
            st.error(f"API Error: Received status code {response.status_code}")
            st.write(response.text)

    except requests.exceptions.ConnectionError:
        st.error("Could not connect to the API.")
    except requests.exceptions.Timeout:
        st.error("The request timed out.")
    except Exception as e:
        st.error(f"An unexpected error occurred: {e}")

if st.button("Get items"):
    endpoint = f"{ORDER_API_URL.rstrip('/')}/"

    try:
        response = requests.get(endpoint, timeout=10)

        if response.status_code == 200:
            data = response.json()
            st.success("Data fetched successfully!")
            st.json(data)

        else:
            st.error(f"API Error: Received status code {response.status_code}")
            st.write(response.text)

    except requests.exceptions.ConnectionError:
        st.error("Could not connect to the API.")
    except requests.exceptions.Timeout:
        st.error("The request timed out.")
    except Exception as e:
        st.error(f"An unexpected error occurred: {e}")