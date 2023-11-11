// #include <SimplyAtomic.h>
#include <ESP32Encoder.h>

class Motor {
  private:
    // const long Ts;
    // const long Vm;

    int PWM;
    int IN_1;
    int IN_2;

    int ticks;
    int ticksRef;
    long tickTimer;
    long tickRate;

    long tickToRad;

    ESP32Encoder encoder;
  
  public:
    int ENC_A;

    Motor(int ENC_A, int ENC_B, int PWM, int IN_1, int IN_2, long PPR) {
      encoder.attachHalfQuad(ENC_A, ENC_B);
      
      this->PWM = PWM;
      this->IN_1 = IN_1;
      this->IN_2 = IN_2;
      tickToRad = 1 / (2 * 3.1415 * PPR); 
      
      tickTimer = millis();
    }

    void init() {
      pinMode(PWM, OUTPUT);
      pinMode(IN_1, OUTPUT);
      pinMode(IN_2, OUTPUT);
    }

    void update() {
      if (digitalRead(ENC_B) > 0) {
        ticks++;
      } else {
        ticks--;
      }
      tickRate = 1 / (millis() - tickTimer);
      tickTimer = millis();
    }

    void setTorque(long torque) {
      setVoltage(torque); // CHANGE
    }

    void setVoltage(long voltage) {
      int pwm = max(int(voltage * 255 / 12), 255);
      pwm = constrain(pwm, -255, 255);
      if (abs(pwn) < 1) {
        pwm = 0;
      }
      analogWrite(abs(pwm), PWM);
      if (pwm == 0) {
        digitalWrite(IN_1, LOW);
        digitalWrite(IN_2, LOW);
      } else if (pwm > 0) {
        digitalWrite(IN_1, HIGH);
        digitalWrite(IN_2, LOW);
      } else {
        digitalWrite(IN_1, LOW);
        digitalWrite(IN_2, HIGH);
      }  
    }

    long getPos() {
      return encoder.getCount() * tickToRad;
    }

    long getVel() {
      return tickRate * tickToRad;
    }

    long setRef() {
      encoder.clearCount();
    }
};