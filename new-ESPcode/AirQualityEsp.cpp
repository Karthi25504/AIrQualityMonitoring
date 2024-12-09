#include <PMS.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <HardwareSerial.h>

#define DHTPIN 4 
#define DHTTYPE DHT11
  

DHT dht(4, DHTTYPE);
const int mq135Pin = 35; 
float R0 = 10.0;

FirebaseConfig config;
FirebaseAuth auth;

const char* ssid = "Amrita_CHN";         
const char* password = "amrita@321"; 

#define FIREBASE_HOST "https://air-quality-index-7396c-default-rtdb.firebaseio.com/"  
#define FIREBASE_AUTH "HGDwQCodRg4Q6BIICDYWL9XalZK4rIpds7JvMmCQ"  
FirebaseData firebaseData;

HardwareSerial pmsSerial(1); 


struct pms5003data data;

void setup() {
  Serial.begin(115200);
  pmsSerial.begin(9600);
  dht.begin();
  delay(2000);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  // Set Firebase configuration
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;

  // Initialize Firebase
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Firebase Initialized");
}

void loop() {
  Serial.println("*************************************************");
  
  // Read temperature and humidity from DHT-11
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    Serial.print("Temperature: ");
    Serial.print(temperature);
    Serial.println(" °C");
    Serial.print("Humidity: ");
    Serial.print(humidity);
    Serial.println(" %");

    // Send temperature and humidity to Firebase
    if (Firebase.setFloat(firebaseData, "/temperature", temperature)) {
      Serial.println("Temperature sent to Firebase successfully");
    } else {
      Serial.println("Failed to send temperature to Firebase");
      Serial.println(firebaseData.errorReason());
    }

    if (Firebase.setFloat(firebaseData, "/humidity", humidity)) {
      Serial.println("Humidity sent to Firebase successfully");
    } else {
      Serial.println("Failed to send humidity to Firebase");
      Serial.println(firebaseData.errorReason());
    }
  }
   if(readPMSdata(&pmsSerial)) {
    Serial.println();
    Serial.println("---------------------------------------");
    Serial.println("Concentration Units (standard)");
    Serial.print("PM 1.0: "); Serial.print(data.pm10_standard);
    Serial.print("\nPM 2.5: "); Serial.print(data.pm25_standard);
    Serial.print("\nPM 10: "); Serial.println(data.pm100_standard);
    Serial.println("\n---------------------------------------");
    Serial.println("Concentration Units (environmental)");
    Serial.print("PM 1.0: "); Serial.print(data.pm10_env);
    Serial.print("\nPM 2.5: "); Serial.print(data.pm25_env);
    Serial.print("\nPM 10: "); Serial.println(data.pm100_env);
    Serial.println("---------------------------------------");
    Serial.print("Particles > 1.0um / 0.1L air:"); Serial.println(data.particles_10um);
    Serial.print("Particles > 2.5um / 0.1L air:"); Serial.println(data.particles_25um);
    Serial.print("Particles > 10.0 um / 0.1L air:"); Serial.println(data.particles_100um);
    Serial.println("---------------------------------------");
  }
  if (Firebase.setFloat(firebaseData, "/PM1_0", data.pm10_standard)) {
    Serial.println("PM 1.0 sent to Firebase successfully");
} else {
    Serial.println("Failed to send PM 1.0 to Firebase");
    Serial.println(firebaseData.errorReason());
}
if (Firebase.setFloat(firebaseData, "/PM2_5", data.pm25_standard)) {
    Serial.println("PM 2.5 sent to Firebase successfully");
} else {
    Serial.println("Failed to send PM 2.5 to Firebase");
    Serial.println(firebaseData.errorReason());
}
if (Firebase.setFloat(firebaseData, "/PM10_0", data.pm100_standard)) {
    Serial.println("PM 10.0 sent to Firebase successfully");
} else {
    Serial.println("Failed to send PM 10.0 to Firebase");
    Serial.println(firebaseData.errorReason());
}


  // Reading and sending MQ-135 data
int mq135Value = analogRead(35);
float mq135Voltage = mq135Value * (3.3 / 4096); // Corrected for ESP32's 3.3V ADC
Serial.print("MQ-135 Raw Value: ");
Serial.println(mq135Value);

// Calculate Rs and gas concentrations
float Rs = (3.3 - mq135Voltage) / mq135Voltage; // Rs in clean air
float ratio = Rs / R0;
float co2_ppm = calculateGasConcentration(ratio, 2.3, 0.72); // CO2 curve coefficients
float nh3_ppm = calculateGasConcentration(ratio, 1.5, 0.60); // NH3 curve coefficients
float smoke_ppm = calculateGasConcentration(ratio, 1.8, 0.65); // Smoke curve coefficients
// Send gas concentrations to Firebase
if (Firebase.setFloat(firebaseData, "/CO", co2_ppm)) {
  Serial.println("CO2 concentration sent to Firebase successfully");
} else {
  Serial.println("Failed to send CO2 concentration to Firebase");
  Serial.println(firebaseData.errorReason());
}

if (Firebase.setFloat(firebaseData, "/NO2", nh3_ppm)) {
  Serial.println("NH3 concentration sent to Firebase successfully");
} else {
  Serial.println("Failed to send NH3 concentration to Firebase");
  Serial.println(firebaseData.errorReason());
}

if (Firebase.setFloat(firebaseData, "/Smoke", smoke_ppm)) {
  Serial.println("Smoke concentration sent to Firebase successfully");
} else {
  Serial.println("Failed to send Smoke concentration to Firebase");
  Serial.println(firebaseData.errorReason());
}
  delay(10000);
}
float calculateGasConcentration(float ratio, float a, float b) {
  return pow(10, (log10(ratio) - b) / a);
}
