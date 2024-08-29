#include <Braccio.h>
#include <Servo.h>
#include <string.h>

#define SPTR_SIZE 20
Servo base;
Servo shoulder;
Servo elbow;
Servo wrist_ver;
Servo wrist_rot;
Servo gripper;
/*
char *sPtr [SPTR_SIZE];

int separate (String str, char **p, int size)
{
  int n;
  char s[100];

  strcpy (s. str.c_sstr());
  *p++ = strtok (s," ");
  for (n = 1; NULL != (*p++ = strtok(NULL," "), n++)
    if(size == n)
      break;
  return n;
}*/

int m1 = 0, m2 = 45, m3 = 45, m4 = 45, m5 = 90, m6 = 73;
int servo_delay = 10;

String M1_str;
String M2_str;
String M3_str;
String M4_str;
String M5_str;
String M6_str;

void setup() {
  Braccio.begin();

  Serial.begin(9600);
}

void loop() {
  
  /*
  if (Serial.available()){

    M1_str = Serial.readStringUntil(',');
    M2_str = Serial.readStringUntil(',');
    M3_str = Serial.readStringUntil(',');
    M4_str = Serial.readStringUntil(',');
    M5_str = Serial.readStringUntil(',');
    M6_str = Serial.readStringUntil(',');

    m1 = M1_str.toInt();
    m2 = M2_str.toInt();
    m3 = M3_str.toInt();
    m4 = M4_str.toInt();
    m5 = M5_str.toInt();
    m6 = M6_str.toInt();
    
    Serial.println();
    Serial.println(M1_str);
    Serial.println(M2_str);
    Serial.println(M3_str);
    Serial.println(M4_str);
    Serial.println(M5_str);
    Serial.println(M6_str);
  
  }
  */
  
  Braccio.ServoMovement(servo_delay, 180, 90, 90, 90, 90, m6);
}
