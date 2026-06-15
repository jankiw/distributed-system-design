import json
import os

from azure.servicebus import ServiceBusClient, ServiceBusMessage
from dotenv import load_dotenv
load_dotenv()

SERVICE_BUS_CONNECTION_STRING=os.getenv(
    "SERVICE_BUS_CONNECTION_STRING"
    )

def publish_event(topic_name: str, payload: dict):
    client = ServiceBusClient.from_connection_string(
        SERVICE_BUS_CONNECTION_STRING
    )
    with client:
        sender = client.get_topic_sender(
            topic_name=topic_name
        )
        with sender:
            sender.send_messages(ServiceBusMessage(
                json.dumps(payload)
            ))