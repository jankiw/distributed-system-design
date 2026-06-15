import json
import os
import time
import random
from azure.servicebus import ServiceBusClient
from servicebus import publish_event
from dotenv import load_dotenv
load_dotenv()
SERVICE_BUS_CONNECTION_STRING=os.getenv(
    "SERVICE_BUS_CONNECTION_STRING"
    )

ORDERS_TOPIC="orders"
ORDERS_SUBSCRIPTION="payment-sub"

def process_order(event):
    time.sleep(3)
    success = random.random()>0.3
    if success:
        payment_event = {
            "event_type": "PaymentCompleted",
            "order_id": event["order_id"],
            "email": event["email"]
        }
    else:
        payment_event = {
            "event_type": "PaymentFailed",
            "order_id": event["order_id"],
            "email": event["email"]
        }
    publish_event(
        "payments",
        payment_event,
        
    )

def run():
    client=ServiceBusClient.from_connection_string(
        SERVICE_BUS_CONNECTION_STRING
    )
    while True:
        with client:
            receiver = client.get_subscription_receiver(
                topic_name=ORDERS_TOPIC,
                subscription_name=ORDERS_SUBSCRIPTION,
                max_wait_time=5
            )
            with receiver:
                messages = receiver.receive_messages(
                    max_message_count=10,
                    max_wait_time=5
                )
                for msg in messages:
                    try:
                        event=json.loads(
                            str(msg)
                        )
                        if(event["event_type"]=="OrderCreated"):
                            process_order(event)
                        receiver.complete_message(
                            msg
                        )
                    except Exception as e:
                        print("error: ",e)
                        
if __name__ == "__main__":
    run()

