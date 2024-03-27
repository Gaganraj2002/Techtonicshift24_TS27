#include <Servo.h>

const byte numChars = 32;
char receivedChars[numChars];
char tempChars[numChars];        // temporary array for use when parsing

boolean newData = false;

int servo1_val, servo2_val, servo3_val, servo4_val, servo5_val, suction;

const int relayPin = 12;  // define the relay pin

// Define servo objects
Servo servo1, servo2, servo3, servo4, servo5;

void setup() {
    Serial.begin(230400);
    Serial.println("<Arduino is ready>");

    // Attach servos to pins
    servo1.attach(3);
    servo2.attach(5);
    servo3.attach(6);
    servo4.attach(9);
    servo5.attach(11);

    pinMode(relayPin, OUTPUT);  // set the relay pin as output
    digitalWrite(relayPin, HIGH);  // initially set relay to off
}

void loop() {
    recvWithStartEndMarkers();
    if (newData == true) {
        strcpy(tempChars, receivedChars);
        parseData();
        showParsedData();
        setServoValues(); // set servo angles based on parsed values
        setSuctionValue();  // set the relay state based on suction value
        newData = false;
    }
}

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '*';
    char endMarker = '#';
    char rc;

    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

void parseData() {
    char * strtokIndx; // this is used by strtok() as an index

    strtokIndx = strtok(tempChars,","); 
    servo1_val = constrain(atoi(strtokIndx), 0, 180);

    strtokIndx = strtok(NULL, ","); 
    servo2_val = constrain(atoi(strtokIndx), 0, 180);

    strtokIndx = strtok(NULL, ","); 
    servo3_val = constrain(atoi(strtokIndx), 0, 180);

    strtokIndx = strtok(NULL, ","); 
    servo4_val = constrain(atoi(strtokIndx), 0, 180);

    strtokIndx = strtok(NULL, ","); 
    servo5_val = constrain(atoi(strtokIndx), 0, 180);

    strtokIndx = strtok(NULL, "#");
    suction = atoi(strtokIndx); // Assuming 0 or 1 for suction, so no constrain is applied
}

void showParsedData() {
    Serial.print("Servo1: ");
    Serial.println(servo1_val);
    Serial.print("Servo2: ");
    Serial.println(servo2_val);
    Serial.print("Servo3: ");
    Serial.println(servo3_val);
    Serial.print("Servo4: ");
    Serial.println(servo4_val);
    Serial.print("Servo5: ");
    Serial.println(servo5_val);
    Serial.print("Suction: ");
    Serial.println(suction);
}

void setServoValues() {
    moveServoSmoothly(servo1, servo1_val);
    moveServoSmoothly(servo2, servo2_val);
    moveServoSmoothly(servo3, servo3_val);
    moveServoSmoothly(servo4, servo4_val);
    moveServoSmoothly(servo5, servo5_val);
}

void moveServoSmoothly(Servo &servo, int targetValue) {
    int currentValue = servo.read();  // get current servo position
    int step = (currentValue < targetValue) ? 1 : -1;  // determine direction
    
    while (currentValue != targetValue) {
        servo.write(currentValue);
        delay(15);  // delay for smooth movement, adjust as needed
        currentValue += step;
    }
}

void setSuctionValue() {
    if (suction == 1) {
        digitalWrite(relayPin, LOW);  // turn relay on
    } else {
        digitalWrite(relayPin, HIGH );  // turn relay off
    }
}
