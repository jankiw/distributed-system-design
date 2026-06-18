import os
import json
from flask import Flask
from azure.servicebus import ServiceBusClient
from extensions import db
from models import Orders, Products
from servicebus import publish_event
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv(
    "DATABASE_URI"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)

SERVICE_BUS_CONNECTION_STRING = os.getenv(
    "SERVICE_BUS_CONNECTION_STRING"
)
TOPIC = "payments"
SUBSCRIPTION = "order-sub"

def process_messages():
    client = ServiceBusClient.from_connection_string(
        SERVICE_BUS_CONNECTION_STRING
    )

    while True:
        with client:
            receiver = client.get_subscription_receiver(
                topic_name=TOPIC,
                subscription_name=SUBSCRIPTION,
                max_wait_time=5
            )
            with receiver:
                messages = receiver.receive_messages(
                    max_message_count=5,
                    max_wait_time=5
                )
                for msg in messages:
                    event = json.loads(str(msg))
                    with app.app_context():
                        order = db.session.get(
                            Orders,
                            event["order_id"]
                        )
                        if not order:
                            receiver.complete_message(msg)
                            continue
                        if event["event_type"] == "PaymentCompleted":
                            order.status = "PAID"
                        elif event["event_type"] == "PaymentFailed":
                            order.status = "FAILED"
                            product = db.session.get(
                                Products,
                                order.product_id
                            )
                            if product:
                                product.amount += 1
                        db.session.commit()
                    receiver.complete_message(msg)

if __name__ == "__main__":
    process_messages()