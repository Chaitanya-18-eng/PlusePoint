import unittest
from unittest.mock import MagicMock, patch

from main import PulseVelocityEngine, calculate_pulse_risk

class TestSyndromicSurveillance(unittest.TestCase):

    def test_outbreak_velocity_and_theme_flip(self):
        """
        Verify PulseVelocityEngine risk calculation and ensure ui_theme flips to #FF5252
        when the threshold of 78.5 is exceeded.
        """
        print("\n--- Testing pure PulseVelocityEngine ---")
        
        # Using values to exceed 78.5: (Env * 0.4) + (Pharmacy * 0.4) + (Intent * 0.2)
        # e.g., 90 * 0.4 + 90 * 0.4 + 80 * 0.2 = 36 + 36 + 16 = 88
        
        mock_env_flux = 90.0
        mock_pharmacy_surge = 90.0
        mock_intent_velocity = 80.0
        
        risk_results = PulseVelocityEngine.calculate_risk_index(
            environmental_flux_delta=mock_env_flux,
            pharmacy_surge_alpha=mock_pharmacy_surge,
            intent_velocity_beta=mock_intent_velocity
        )
        
        print(f"Score results: {risk_results}")
        
        # Verify calculated theme matches specifications
        self.assertGreater(risk_results['pulse_risk_index'], 78.5)
        self.assertEqual(risk_results['status'], 'Alert')
        self.assertEqual(risk_results['ui_theme'], '#FF5252')
        print("PASS: Risk threshold crossed, status is 'Alert', ui_theme is '#FF5252'")

    @patch('main.messaging.send')
    def test_fcm_topic_dispatch(self, mock_messaging_send):
        """
        Verify that an FCM message is structured properly for the correct region, 
        dispatching to the pulse_alerts_{regionId} topic.
        """
        print("\n--- Testing full Cloud Function Event Flow ---")
        
        mock_event = MagicMock()
        mock_event.params = {"regionId": "pune"}
        
        mock_after_doc = MagicMock()
        mock_after_doc.exists = True
        mock_after_doc.to_dict.return_value = {
            "environmental_flux_delta": 95.0,
            "pharmacy_surge_alpha": 95.0, 
            "intent_velocity_beta": 85.0
        }
        
        mock_event.data.after = mock_after_doc
        
        def mock_send(message):
            print(f">>> [MOCK FCM DISPATCH] Alert triggered for topic: {message.topic} (Region: {message.data['regionId']})")
            print(f">>> [MOCK FCM DISPATCH] Notification Payload:")
            print(f"      Title: {message.notification.title}")
            print(f"      Body:  {message.notification.body}")
            print(f"      Theme: {message.data['theme']}")
            return "mock_message_id_123"
            
        mock_messaging_send.side_effect = mock_send
        
        calculate_pulse_risk.__wrapped__(mock_event)
        
        mock_after_doc.reference.update.assert_called_once()
        mock_messaging_send.assert_called_once()
        
        print("PASS: calculate_pulse_risk handled the event safely and invoked FCM correctly.")

if __name__ == "__main__":
    unittest.main()
