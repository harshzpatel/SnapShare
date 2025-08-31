from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, messaging, exceptions
import logging

set_global_options(max_instances=10)

initialize_app()




# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")
#
#
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


        message = messaging.Message(
            notification=messaging.Notification(
                title=NOTIFICATION_TITLE,
                body=NOTIFICATION_BODY,
            ),
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
