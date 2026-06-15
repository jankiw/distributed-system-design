import json
import time
from servicebus import receive_message, complete
from emailClient import send_email

ORDERS_TOPIC="orders"
PAYMENTS_TOPIC="payments"
ORDERS_SUB="notification-sub"
PAYMENTS_SUB="notification-payment-sub"

def process_orders_event(event):
    if event["event_type"]=="OrderCreated":
        send_email(
            event["email"],
            "Order created",
            f"""
            <h3>Your order was created</h3>
            <p>Product: {event['product_name']}</p>
            <p>Price: {event['price']}</p>
            """
        )

def process_payment_event(event):
    if event["event_type"]=="PaymentCompleted":
        send_email(
            event["email"],
            "Payment successful",
            f"""
            <h3>Payment successful</h3>
            Order:{event['order_id']}
            """
        )
    elif event["event_type"]=="PaymentFailed":
        send_email(
            event["email"],
            "Payment failed",
            f"""
            <h3>Payment failed</h3>
            Order:{event['order_id']}
            """
        )

def run_orders_consumer():
    client, receiver, messages = receive_message(
        ORDERS_TOPIC,
        ORDERS_SUB
    )
    with client:
        with receiver:
            for msg in messages:
                event = json.loads(str(msg))
                process_orders_event(event)
                complete(receiver,msg)
    

def run_payments_consumer():
    client, receiver, messages = receive_message(
        PAYMENTS_TOPIC,
        PAYMENTS_SUB
    )
    with client:
        with receiver:
            for msg in messages:
                event = json.loads(str(msg))
                process_payment_event(event)
                complete(receiver,msg)

if __name__ == "__main__":
    while True:
        try:
            run_orders_consumer()
            run_payments_consumer()
            time.sleep(1)
        except Exception as e:
            print("error:",e)
            time.sleep(5)
