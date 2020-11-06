/******************************************************************************
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
* Date - October 24, 2006                                                     *
* Module - simple_socket_server.c                                             *
*                                                                             *
******************************************************************************/
 
/******************************************************************************
 * Simple Socket Server (SSS) example. 
 * 
 * This example demonstrates the use of MicroC/OS-II running on NIOS II.       
 * In addition it is to serve as a good starting point for designs using       
 * MicroC/OS-II and Altera NicheStack TCP/IP Stack - NIOS II Edition.                                          
 *                                                                             
 * -Known Issues                                                             
 *     None.   
 *      
 * Please refer to the Altera NicheStack Tutorial documentation for details on this 
 * software example, as well as details on how to configure the NicheStack TCP/IP 
 * networking stack and MicroC/OS-II Real-Time Operating System.  
 */
 
#include <stdio.h>
#include <string.h>
#include <ctype.h> 

/* MicroC/OS-II definitions */
#include "includes.h"

/* Simple Socket Server definitions */
#include "simple_socket_server.h"                                                                    
#include "alt_error_handler.h"

/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"


void MainTask()
{
  int fd_socket;
  struct sockaddr_in addr;
  
  /*
   * Traditionally, in the Sockets API, PF_INET and AF_INET is used for the 
   * protocol and address families respectively. However, there is usually only
   * 1 address per protocol family. Thus PF_INET and AF_INET can be interchanged.
   * In the case of NicheStack, only the use of AF_INET is supported.
   * PF_INET is not supported in NicheStack.
   */ 
  if ((fd_socket = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Socket creation failed");
  }
  /* Esse programa eh apenas um cliente,
   * o codigo comentado eh necessario caso seja um servidor
   * remova a chamada para connect caso esteja implementando um servidor (essa chamada eh feito pelo cliente)
   */

  addr.sin_family = AF_INET;
  addr.sin_port = htons(5000); 						// ALTERAR PORTA
  addr.sin_addr.s_addr = inet_addr("192.168.0.2"); 	// ALTERAR IP
  // Caso seja um servidor mude para linha abaixo para ouvir em todas as interfaces locais
  // addr.sin_addr.s_addr = INADDR_ANY



  /*if ((bind(fd_socket,(struct sockaddr *)&addr,sizeof(addr))) < 0)
  {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Bind failed");
  }*/
    
  /*
   * Sockets primer, continued...
   * The listen socket is a socket which is waiting for incoming connections.
   * This call to listen will block (i.e. not return) until someone tries to 
   * connect to this port.
   */ 
  /*if ((listen(fd_socket,1)) < 0)
  {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Listen failed");
  }*/

  /* At this point we have successfully created a socket which is listening
   * on SSS_PORT for connection requests from any remote address.
   */
  if((connect(fd_socket, (struct sockaddr *)&addr, sizeof(addr))) < 0){
	  alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Connect failed");
  }
  printf("[sss_task] Connected\n");
  char buf[1024];
  int value;
  while(1){
	  if((recv(fd_socket, buf, sizeof(buf),0)) < 0){
		  alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Receive failed");
	  } else {
		  printf("Mensagem recebida: %s\n", buf);
		  value = atoi(buf);
		  memset(&buf, 0, sizeof(buf)/sizeof(char)); // Clear the buffer.
	  }
  }
}

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
