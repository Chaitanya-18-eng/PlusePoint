import firebase_admin
from firebase_admin import initialize_app, messaging, firestore
from firebase_functions import firestore_fn, logger
from firebase_functions.firestore_fn import Event, DocumentSnapshot

initialize_app()

class PulseVelocityEngine:
    @staticmethod
    def calculate_risk_index(
        environmental_flux_delta: float,
        pharmacy_surge_alpha: float,
        intent_velocity_beta: float
    ) -> dict:
        """
        Calculates the PulsePoint risk index and returns the UI theme properties.
        """
        pulse_risk_index = (environmental_flux_delta * 0.4) + (pharmacy_surge_alpha * 0.4) + (intent_velocity_beta * 0.2)
        
        if pulse_risk_index > 78.5:
            status = 'Alert'
            ui_theme = '#FF5252'
        else:
            status = 'Stable'
            ui_theme = '#4CAF50'
            
        return {
            'pulse_risk_index': pulse_risk_index,
            'status': status,
            'ui_theme': ui_theme
        }

@firestore_fn.on_document_written(document="regional_indices/{regionId}")
def calculate_pulse_risk(event: Event[firestore_fn.Change[DocumentSnapshot]]) -> None:
    """
    2nd Gen Cloud Function: PulsePoint Nervous System
    """
    region_id = event.params["regionId"]
    logger.info("Triggered calculate_pulse_risk", extra={"regionId": region_id})

    if event.data.after is None or not event.data.after.exists:
        logger.info("Document deleted, skipping analysis.")
        return

    doc_data = event.data.after.to_dict()
    if not doc_data:
        return

    # Extract required fields with safe defaults
    environmental_flux_delta = doc_data.get('environmental_flux_delta', 0.0)
    pharmacy_surge_alpha = doc_data.get('pharmacy_surge_alpha', 0.0)
    intent_velocity_beta = doc_data.get('intent_velocity_beta', 0.0)
    
    current_status = doc_data.get('status')
    current_score = doc_data.get('pulse_risk_index')

    logger.debug("Extracted Pulse data", extra={
        "environmental_flux_delta": environmental_flux_delta,
        "pharmacy_surge_alpha": pharmacy_surge_alpha,
        "intent_velocity_beta": intent_velocity_beta
    })

    # Run the PulseVelocityEngine scoring logic
    risk_results = PulseVelocityEngine.calculate_risk_index(
        environmental_flux_delta=environmental_flux_delta,
        pharmacy_surge_alpha=pharmacy_surge_alpha,
        intent_velocity_beta=intent_velocity_beta
    )

    pulse_risk_index = risk_results['pulse_risk_index']
    status = risk_results['status']
    ui_theme = risk_results['ui_theme']

    logger.info("Risk assessment complete", extra={
        "pulse_risk_index": pulse_risk_index, 
        "status": status,
        "ui_theme": ui_theme
    })
    
    needs_update = (
        abs(current_score - pulse_risk_index) > 0.0001 if current_score is not None else True
    ) or current_status != status

    if needs_update:
        logger.info("Updating Firestore document with new Pulse metrics.")
        event.data.after.reference.update({
            'pulse_risk_index': pulse_risk_index,
            'status': status,
            'ui_theme': ui_theme,
        })
    else:
        logger.info("No state change detected; skipping Firestore update.")

    # Localized FCM Dispatch for PulsePoint
    if pulse_risk_index > 78.5 and status == 'Alert':
        topic_name = f"pulse_alerts_{region_id}"
        
        message = messaging.Message(
            notification=messaging.Notification(
                title=f"PulsePoint Alert: Region {region_id}",
                body=f"High risk index detected ({pulse_risk_index:.2f})."
            ),
            topic=topic_name,
            data={
                "regionId": region_id,
                "status": status,
                "score": str(pulse_risk_index),
                "theme": ui_theme
            }
        )
        
        try:
            response = messaging.send(message)
            logger.info("Successfully sent FCM message", extra={"message_id": response, "topic": topic_name})
        except Exception as e:
            logger.error("Error sending FCM message", extra={"error": str(e)})

