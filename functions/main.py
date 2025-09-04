import logging

from firebase_admin import initialize_app, messaging, firestore
from firebase_functions import firestore_fn
from firebase_functions.options import set_global_options

set_global_options(max_instances=10)

initialize_app()


@firestore_fn.on_document_created(document="chats/{chatId}/messages/{messageId}")
def send_chat_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
    try:
        message_data = event.data.to_dict()
        if not message_data:
            logging.info("Message document is empty, exiting function.")
            return

        sender_id = message_data.get("senderId")
        receiver_id = message_data.get("receiverId")
        message_text = message_data.get("message")

        if not all([sender_id, receiver_id, message_text]):
            logging.error(
                f"Message document {event.params.get('messageId')} is missing a required field.")
            return

        logging.info(f"New message from {sender_id} to {receiver_id}.")

        db = firestore.client()
        tokens_ref = db.collection(f'users/{receiver_id}/tokens')
        tokens_snapshot = tokens_ref.stream()

        fcm_tokens = [doc.id for doc in tokens_snapshot]

        if not fcm_tokens:
            logging.warning(
                f"Receiver {receiver_id} has no FCM tokens. No notification will be sent.")
            return

        logging.info(f"Found {len(fcm_tokens)} tokens for receiver {receiver_id}.")

        sender_doc = db.collection('users').document(sender_id).get()
        sender_name = "New Message"
        sender_prof_image = "https://cdn-icons-png.flaticon.com/512/7915/7915522.png"

        if sender_doc.exists:
            sender_name = sender_doc.to_dict().get("username", "New Message")
            sender_prof_image = sender_doc.to_dict().get(
                "photoUrl") or "https://cdn-icons-png.flaticon.com/512/7915/7915522.png"

        data_payload = {
            "username": sender_name,
            "message": message_text,
            "profImage": sender_prof_image,
            "senderId": sender_id
        }

        message = messaging.MulticastMessage(
            data=data_payload,
            tokens=fcm_tokens,
        )

        batch_response = messaging.send_each_for_multicast(message)

        logging.info(
            f"Notifications sent. Success: {batch_response.success_count}, Failure: {batch_response.failure_count}")

        for idx, response in enumerate(batch_response.responses):
            if not response.success:
                error_code = response.exception.code
                if error_code == 'UNREGISTERED':
                    invalid_token = fcm_tokens[idx]
                    logging.info(f"Deleting invalid/unregistered token: {invalid_token}")
                    db.collection(f'users/{receiver_id}/tokens').document(invalid_token).delete()

    except Exception as e:
        logging.error(f"An unexpected error occurred in send_chat_notification: {e}")
        raise
