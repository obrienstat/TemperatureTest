#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "TempTest.h"

configuration TempTestAppC
{
	
}

implementation
{
	// lets do the wiritng
	
	// general components	
	components MainC;
	components LedsC;
	components new TimerMilliC();
	components TempTestC as App;
	
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> TimerMilliC;
	
	// for writing to serial port
	components SerialPrintfC; // doesn't need wiring
	
	// temperature component
	components new SensirionSht11C() as TempSensor;
	
	App.TempRead -> TempSensor.Temperature;
	
	// light component
	components new HamamatsuS10871TsrC() as LightSensor;
	
	App.LightRead -> LightSensor;
	
	// Radio Components
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);
	
	// wire the radio components
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	
}