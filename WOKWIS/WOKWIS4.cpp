#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>


const char* WIFI_SSID = "Wokwi-GUEST";
const char* WIFI_PASSWORD = "";

const char* API_URL = "http://andre-savedra-turmab-iiot-app.azurewebsites.net/data";
const char* WRITE_API_KEY = "4247cca7-12cd-47d0-9ba8-a9a248a7003d";
const char* SENSOR_ID = "9a99028c-adda-49ee-9630-ee7370129154";

unsigned long timer;


void setup() {
  Serial.begin(115200);  
  Serial.println("Connecting to wifi...");
  wifiConnect();
  
  Serial.println("IIOT application started!");
}

void loop() {
  if(timeout(5)){
    readDataAndSend();
    timer = millis();
  }
}

void readDataAndSend(){
  Serial.println("Start Reading data...");
  float quant = readQuant();
  String tipo = readTipo();
  
  Serial.println("Start Sending data...");
  sendData(quant, tipo);
}

float readQuant(){
  float quant = random(10, 10000);
  // FIX: formato %.2ML inválido trocado por %.2f
  Serial.printf("Quant: %.2f mL \n", quant);
  return quant;
}

String readTipo(){
  // FIX: variáveis locais dentro dos ifs não alteravam a variável externa 'tipo'.
  // Agora a atribuição é feita diretamente na variável do escopo externo.
  String tipo = "Irrigação";
  int tipo_sort = random(1, 3);
  if (tipo_sort == 1){
    tipo = "Irrigação";
  } else if (tipo_sort == 2){
    tipo = "Fertilização";
  } else {
    tipo = "Aplicação Defensivo";
  }

  // FIX: printf sem especificador de formato; trocado para %s com .c_str()
  Serial.printf("tipo: %s \n", tipo.c_str());
  return tipo;
}

void sendData(float quant, String tipo){
  StaticJsonDocument<200> payload;
  payload["id_evento"] = SENSOR_ID;
  // FIX: campos tipo_evento e quantidade_gasta estavam invertidos/com valores errados.
  // tipo_evento deve receber o tipo (string), quantidade_gasta deve receber a quantidade (número).
  payload["tipo_evento"] = tipo;
  payload["quantidade_gasta"] = quant;

  char bodyJsonString[255];
  serializeJson(payload, bodyJsonString);
  Serial.printf("Data to be sent: %s \n", bodyJsonString);

  WiFiClient wifiClient;
  HTTPClient http;
  http.begin(wifiClient,API_URL);
  http.addHeader("Content-Type","application/json");
  http.addHeader("X-API-KEY",WRITE_API_KEY);

  int httpResponse = http.POST(bodyJsonString);
  if(httpResponse > 0){
    Serial.printf("Response received: %d \n", httpResponse);
    if(httpResponse == 201){
      Serial.println("Data was successfully sent!!!");
    }
  }
  else{
    Serial.println("Data wasn't sent, internal error!");
  }
  http.end();
}

void wifiConnect(){
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD, 6);
  int tries = 0;

  while(WiFi.status() != WL_CONNECTED && tries < 5){
    delay(500);
    Serial.println("...");
    tries++;
  }

  if(WiFi.status() == WL_CONNECTED){
    Serial.println("Wifi successfully connected!");
    Serial.println(WiFi.localIP().toString());
  }
  else{
    Serial.println("IIOT board wasn't able to connect to wifi!");
  }

}

boolean timeout(int timing_sec){
    return (millis()-timer)>= (timing_sec * 1000);
}
