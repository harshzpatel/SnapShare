from firebase_functions import https_fn, firestore_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, messaging, exceptions, firestore
import logging

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
            logging.error(f"Message document {event.params.get('messageId')} is missing a required field.")
            return

        logging.info(f"New message from {sender_id} to {receiver_id}.")

        db = firestore.client()
        tokens_ref = db.collection(f'users/{receiver_id}/tokens')
        tokens_snapshot = tokens_ref.stream()

        fcm_tokens = [doc.id for doc in tokens_snapshot]

        if not fcm_tokens:
            logging.warning(f"Receiver {receiver_id} has no FCM tokens. No notification will be sent.")
            return

        logging.info(f"Found {len(fcm_tokens)} tokens for receiver {receiver_id}.")

        sender_doc = db.collection('users').document(sender_id).get()
        sender_name = "New Message"
        sender_prof_image = "https://cdn-icons-png.flaticon.com/512/7915/7915522.png"

        if sender_doc.exists:
            sender_name = sender_doc.to_dict().get("username", "New Message")
            sender_prof_image = sender_doc.to_dict().get("photoUrl") or "https://cdn-icons-png.flaticon.com/512/7915/7915522.png"

        data_payload = {
            "username": sender_name,
            "message": message_text,
            "profImage": sender_prof_image
        }

        message = messaging.MulticastMessage(
            data=data_payload,
            tokens=fcm_tokens,
        )

        batch_response = messaging.send_each_for_multicast(message)
        logging.info(f"Notifications sent. Success: {batch_response.success_count}, Failure: {batch_response.failure_count}")

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


@https_fn.on_request()
def send_fixed_alert(req: https_fn.Request) -> https_fn.Response:
    if req.method != "GET":
        logging.warning(f"Invalid request method received: {req.method}")
        return https_fn.Response("This function only accepts GET requests.", status=405)
    TARGET_FCM_TOKEN = "fOST3t6jS2uioVIYjerg2T:APA91bGegVFPhqIAiCeQ3agz3g_CuU9R76V9BUczv0vr4dcAP-ROKeDs5-dnhZ9wIHK-mKGBZun5k9NnmSAnG0lyzeh48170gikQy5F-6oqNYM715S6UaQg"

    NOTIFICATION_TITLE = "Server Alert!"
    NOTIFICATION_BODY = "A scheduled task was successfully completed."

    try:
        if not TARGET_FCM_TOKEN or TARGET_FCM_TOKEN == "YOUR_STATIC_FCM_TOKEN_HERE":
            raise ValueError(
                "FCM token is not set. Please edit the function code to provide a valid token.")


        data_payload = {
            "username": "Cloud Function",
            "message": "This is a custom notification from the server!",
            "profImage": "https://yt3.ggpht.com/yti/ANjgQV8sJ3Ji-ggJxkWTzwW6qwsSQQiARYU9gobaM2O6HUflT6hB=s108-c-k-c0x00ffffff-no-rj"  # A sample profile image URL
        }

        # --- Construct the message with the DATA payload ---
        message = messaging.Message(
            data=data_payload,
            token=TARGET_FCM_TOKEN,
        )

        # --- Send the message ---
        logging.info(f"Attempting to send hardcoded notification to a device.")
        response_id = messaging.send(message)
        logging.info(f"Successfully sent message: {response_id}")

        # --- Return a success response ---
        return https_fn.Response(
            f"Notification sent successfully to the hardcoded device. Message ID: {response_id}",
            status=200
        )

    except ValueError as e:
        # This will catch the error if the token is not set.
        logging.error(f"Configuration Error: {e}")
        return https_fn.Response(str(e), status=500)  # 500 Internal Server Error is appropriate
    except exceptions.FirebaseError as e:
        # Handle errors from the FCM service (e.g., invalid token).
        logging.error(f"FCM Error: {e}")
        # The UnregisteredError has useful details inside it.
        if isinstance(e, messaging.UnregisteredError):
            return https_fn.Response("The provided FCM token is invalid or unregistered.",
                                     status=404)
        return https_fn.Response(f"Error sending notification: {e}", status=500)
    except Exception as e:
        # Handle any other unexpected errors.
        logging.error(f"An unexpected error occurred: {e}")
        return https_fn.Response("An internal error occurred.", status=500)
