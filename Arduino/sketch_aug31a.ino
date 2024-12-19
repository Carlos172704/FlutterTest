// Pin assignments for LEDs
const int ledPins[] = {2, 3, 4, 5, 6};

// Pin assignments for buttons
const int buttonPins[] = {8, 9, 10, 11};

// Button states and last button states for edge detection
int buttonState[] = {0, 0, 0, 0};
int lastButtonState[] = {0, 0, 0, 0};

// LED states (1 = ON, 0 = OFF)
int ledState[] = {0, 0, 0, 0, 0};

void setup() {
  Serial.begin(9600);
  // Initialize LED pins as OUTPUT
  for (int i = 0; i < 5; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW); // Turn LEDs off initially
  }

  // Initialize button pins as INPUT with pullup resistors
  for (int i = 0; i < 4; i++) {
    pinMode(buttonPins[i], INPUT_PULLUP);
  }
}

void loop() {
  // Read button states

  if(ledState[0]== 1 && ledState[1]== 1 && ledState[2]== 1 && ledState[3]== 1 && ledState[4]== 1){
       for (int i = 0; i < 5; i++) {
        digitalWrite(ledPins[i], HIGH); // Turn LEDs off initially
      }
      delay(1000);
       for (int i = 0; i < 5; i++) {
        digitalWrite(ledPins[i], LOW); // Turn LEDs off initially
      }
      delay(1000);
       for (int i = 0; i < 5; i++) {
        digitalWrite(ledPins[i], HIGH); // Turn LEDs off initially
      }
      delay(1000);
       for (int i = 0; i < 5; i++) {
        digitalWrite(ledPins[i], LOW); // Turn LEDs off initially
      }
      for (int i = 0; i < 5; i++) {
        ledState  [i] = 0; // Turn LEDs off initially
      }
    }
  for (int i = 0; i < 4; i++) {
    buttonState[i] = digitalRead(buttonPins[i]);

    // Check if button is pressed (active low)
    if (buttonState[i] == LOW && lastButtonState[i] == HIGH) {
      toggleLEDs(i);  // Toggle LEDs based on button
    }

    // Update the last button state
    lastButtonState[i] = buttonState[i];
  }

  // Update the LEDs
  for (int i = 0; i < 5; i++) {
    digitalWrite(ledPins[i], ledState[i]);
  }
}

// Function to toggle specific LEDs based on which button was pressed
void toggleLEDs(int button) {
  switch (button) {
    case 0:  // Button 1 (pin 8) toggles LEDs 1 and 3
      ledState[0] = !ledState[0];  // Toggle LED 1
      ledState[2] = !ledState[2];  // Toggle LED 3
      break;

    case 1:  // Button 2 (pin 9) toggles LEDs 2 and 4
      ledState[1] = !ledState[1];  // Toggle LED 2
      ledState[3] = !ledState[3];  // Toggle LED 4
      break;

    case 2:  // Button 3 (pin 10) toggles LEDs 3 and 5
      ledState[2] = !ledState[2];  // Toggle LED 3
      ledState[4] = !ledState[4];  // Toggle LED 5
      break;
    case 3:
      ledState[4] = !ledState[4];
      break;
  }
}
