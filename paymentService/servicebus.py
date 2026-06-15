import json
import os
from dotenv import load_dotenv
load_dotenv()

from azure.servicebus import ServiceBusClient, ServiceBusMessage

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