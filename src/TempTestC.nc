#include <Timer.h>
#include <stdio.h>
#include <string.h>
#include "printf.h"

#include "TempTest.h"



module TempTestC
{
	
	uses {
		// define the general interfaces
		interface Boot;
		interface Timer<TMilli>; // will always complain
		interface Leds;
		
		// read
		interface Read<uint16_t> as TempRead;
		
		interface Read<uint16_t> as LightRead;
		
	}
	
	uses {
		
		// interfaces for sending/receiving/wireless transmission
		interface Packet;
		interface AMPacket;
		interface AMSend;
		
		
		interface SplitControl as AMControl;
		
		interface Receive;
	}
}
implementation
{

	// Radio Globals
	bool _radioBusy = FALSE;
	message_t _packet;
	
	uint16_t _centiGrade;
	uint16_t _luminance;	
	

	event void Boot.booted(){
		
		// set up our timer
		call Timer.startPeriodic(5000);
		
		// start our radio!!!!!
		call AMControl.start();
		
		
		// turn on one led to indicated the sensor is running

	}
	
	event void Timer.fired()
	{
		call Leds.led0Off();
		
		call TempRead.read();
		call LightRead.read();


		if (_radioBusy == FALSE)
		{
			// now we want to send the packet
			TempTestPacket_t *msg = call Packet.getPayload(&_packet, sizeof(TempTestPacket_t));
			
			// add our values to our packet
			msg->NodeId = TOS_NODE_ID;
			msg->Luminance = _luminance;
			msg->Temp = _centiGrade;
			
			// now send the packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(TempTestPacket_t)) == SUCCESS)
			{
				_radioBusy = TRUE;
				printf("Sent message\r\n");
			}
			else
			{
				printf("Error Sending\r\n");
			}
		}
	}

	event void TempRead.readDone(error_t result, uint16_t val){
		
		// stores our correct val in our global var
		_centiGrade = (-39.60 + 0.01 * val);
		
		
		
	}
	
	event void LightRead.readDone(error_t result, uint16_t val)
	{
	
		// stores our correct val in our global var
		_luminance = 2.5 * (val / 4096.0) * 6250.0;
				
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if (msg == &_packet)
		{
			_radioBusy = FALSE;
		}
		else
			call Leds.led2Toggle();
	}

	event void AMControl.startDone(error_t error){
		
		// checks if the radio is on
		if (error == SUCCESS)
		{
			call Leds.led2Toggle();
		}
		else
		{
			// loop again
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error){

	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if (len == sizeof(TempTestPacket_t))
		{
			TempTestPacket_t *incomingPacket = (TempTestPacket_t *)payload;
	
			uint16_t nodeid = incomingPacket->NodeId;
			uint16_t temp = incomingPacket->Temp;
			uint16_t light = incomingPacket->Luminance;
	
			// now we can read sensor value
			printf("From Node with ID: %d\r\n", nodeid);
			printf("Current Temp is: %d\r\n", temp);
			printf("Current Light is: %d\r\n", light);
		}
				
		return msg;
	}



}