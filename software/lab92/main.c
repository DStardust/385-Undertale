/*
 * main.c
 *
 *  Created on: 2023��4��23��
 *      Author: DStardust
 */
#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alt_types.h>
#include "text_mode_vga_color.h"
#include "palette_test.h"
void main() {
	while(1==1) {
		paletteTest();
		textVGAColorScreenSaver();
}
}



