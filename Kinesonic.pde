//#define DEBUG                 1

// Constants
const int LED_PIN = 13;             // LED connected to digital pin 13
const int POT_PIN = 0;              // Pot connected to analog pin 0
const int POT_THRESHOLD = 7;        // Threshold amount to guard against false values
const int MIDI_CHANNEL = 0;         // MIDI Channel 1

#ifdef DEBUG
const int DEBUG_RATE = 9600;        // Serial debugging communicates at 9600 baud
const int SERIAL_PORT_RATE = DEBUG_RATE;
#else
const int MIDI_BAUD_RATE = 31250;   // MIDI communicates at 31250 baud
const int SERIAL_PORT_RATE = MIDI_BAUD_RATE;
#endif


void setup()
{
    pinMode(LED_PIN, OUTPUT);      	// Sets the digital pin as output
    digitalWrite(LED_PIN, HIGH);   	// Turn the LED on
    Serial.begin(SERIAL_PORT_RATE); 	// Starts communication with the serial port
}

void loop()
{
    static int s_nLastPotValue = 0;
    static int s_nLastMappedValue = 0;

    int nCurrentPotValue = analogRead(POT_PIN);
    if(abs(nCurrentPotValue - s_nLastPotValue) < POT_THRESHOLD)
        return;
    s_nLastPotValue = nCurrentPotValue;

    int nMappedValue = map(nCurrentPotValue, 0, 1023, 0, 127); // Map the value to 0-127
    if(nMappedValue == s_nLastMappedValue)
        return;
    s_nLastMappedValue = nMappedValue;

    MidiVolume(MIDI_CHANNEL, nMappedValue);
}

void MidiVolume(byte channel, byte volume)
{
#ifdef DEBUG
    Serial.println(volume, DEC);
#else
    Serial.print(0xB0 | (channel & 0x0F), BYTE);    // Control change command
    Serial.print(0x0B, BYTE);                       // Volume command
    Serial.print(volume & 0x7F, BYTE);              // Volume 0-127
#endif
}
