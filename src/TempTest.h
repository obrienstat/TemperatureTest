#ifndef TEMP_TEST_H
#define TEMP_TEST_H

/*
 * This is our packet struct
 */
typedef nx_struct TempTestPacket
{
	nx_uint16_t NodeId;
	nx_uint16_t Temp;
	nx_uint16_t Luminance;
	
} TempTestPacket_t;

enum
{
	AM_RADIO = 6
};

#endif /* TEMP_TEST_H */
