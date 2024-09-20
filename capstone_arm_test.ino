#include <Braccio.h>
#include <Servo.h>
#include <string.h>

#define BUFFER_SIZE 6
#define SERVO_DELAY 10

Servo base;
Servo shoulder;
Servo elbow;
Servo wrist_ver;
Servo wrist_rot;
Servo gripper;

/*
   Step Delay: a milliseconds delay between the movement of each servo.  Allowed values from 10 to 30 msec.
   M1=base degrees. Allowed values from 0 to 180 degrees
   M2=shoulder degrees. Allowed values from 15 to 165 degrees
   M3=elbow degrees. Allowed values from 0 to 180 degrees
   M4=wrist vertical degrees. Allowed values from 0 to 180 degrees
   M5=wrist rotation degrees. Allowed values from 0 to 180 degrees
   M6=gripper degrees. Allowed values from 10 to 73 degrees. 10: the toungue is open, 73: the gripper is closed.
*/

/*  INPUT INCLUDES ANGLES FOR ARM MOVEMENT
    FORMAT: byte 0 has to be 255          --> Extra layer for error checking 
            1st byte: M1
            2nd byte: M2
            3rd byte: M3
            4th byte: M4
            5th byte: M5
            6th byte: M6
            ending byte has to be 254     --> Extra layer for error checking 

    INPUT SEQUENCE EXAMPLE: [255, 90, 90, 90, 90, 90, 73, 254] equivalent to hex: [0xFF, 0x5A, 0x5A, 0x5A, 0x5A, 0x5A, 0x49, 0xFE]
    BUFFER: [90, 90, 90, 90, 90, 73]
    OUTPUT: Move arm to position (90, 90, 90, 90, 90, 73)

    PSEUDOCODE:

    READ 1ST BYTE
    
    Read until byte is 255
    If read 255
      store next 6 bytes into buffer
    If next read is 254
      convert buffer to integers and move arm
    Else
      reset buffer
*/

int m1 = 0, m2 = 45, m3 = 45, m4 = 45, m5 = 90, m6 = 73;
int servo_delay = 10;

char* buffer[SPTR_SIZE - 1];

String M1_str;
String M2_str;
String M3_str;
String M4_str;
String M5_str;
String M6_str;

void setup() {
  Braccio.begin();
  Serial.begin(115200);
}

void loop() {
  // READ 1ST BYTE
  // If byte read is not 255
  //    read until byte is 255
  // If read 255
  //    store next 6 bytes into buffer
  // If next read is 254
  //    convert buffer to integers and move arm
  // Else
  //    reset buffer

  if (Serial.available() > 0) {
    if (Serial.read() == 255) {
      for (int i = 0; i < BUFFER_SIZE; i++) {
        buffer[i] = Serial.read();
      }
      if (Serial.read() == 254) {
        m1 = buffer[0];
        m2 = buffer[1];
        m3 = buffer[2];
        m4 = buffer[3];
        m5 = buffer[4];
        m6 = buffer[5];        
        Braccio.ServoMovement(servo_delay, m1, m2, m3, m4, m5, m6);
      } else {
        for (int i = 0; i < BUFFER_SIZE; i++) {
          buffer[i] = 0;
        }
      }
    }
  } 
}


// UNUSED CODE

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