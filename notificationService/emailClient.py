import os
from azure.communication.email import EmailClient
from dotenv import load_dotenv
load_dotenv()

ACS_CONNECTION_STRING = os.getenv(
    "ACS_CONNECTION_STRING"
)
SENDER = os.getenv(
    "ACS_SENDER_ADDRESS"
)

def send_email(to_email, subject, content):
    client = EmailClient.from_connection_string(
        ACS_CONNECTION_STRING
    )

    message = {
        "senderAddress": SENDER,
        "recipients": {
            "to":[
                { "address": to_email }
            ]
        },
        "content":{
            "subject": subject,
            "html": content
        }
    }
    poller = client.begin_send(
        message
    )