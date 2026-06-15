import json
import os
from azure.servicebus import ServiceBusClient
from dotenv import load_dotenv
load_dotenv()

SERVICE_BUS_CONNECTION_STRING=os.getenv(
    "SERVICE_BUS_CONNECTION_STRING"
)

def receive_message(topic, subscription):
    client = ServiceBusClient.from_connection_string(
        SERVICE_BUS_CONNECTION_STRING
    )
    receiver = client.get_subscription_receiver(
        topic_name=topic,
        subscription_name=subscription,
        max_wait_time=5
    )
    messages = receiver.receive_messages(
        max_message_count=10,
        max_wait_time=5
    )
    return client, receiver, messages

def complete(receiver, message):
    receiver.complete_message(message)