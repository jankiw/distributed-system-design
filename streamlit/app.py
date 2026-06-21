import os
import requests
import streamlit as st

ORDER_API_URL = os.getenv("ORDER_API_URL")
st.title("Streamlit on Azure")

if not ORDER_API_URL:
    st.error("Missing environment variable: ORDER_API_URL")
    st.stop()

st.write(ORDER_API_URL)

with st.form("form1"):
    name = st.text_input("Product name")
    amount = st.number_input("Amount")
    price = st.number_input("Price"
                            "")
    post = st.form_submit_button("Post item")

if post:
    endpoint = f"{ORDER_API_URL.rstrip('/')}/products"
    body = {
        'name': name,
        'amount': amount,
        'price': price
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

with st.form("form2"):
    id = st.text_input("Product ID")
    order = st.form_submit_button("Order item")

if order:
    endpoint = f"{ORDER_API_URL.rstrip('/')}/{id}"
    try:
        response = requests.post(endpoint, json = body, timeout=10)

        if response.status_code == 200:
            data = response.json()
            st.success("Product ordered!")

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