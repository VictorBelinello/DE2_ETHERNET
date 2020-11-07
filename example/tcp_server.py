import socket
from random import randint
from time import sleep

def read_sensor():
  return str(randint(0, 255))

def accept(sock):
  # Implementado assim para permitir Ctrl+C quando nao tem cliente conectado ainda
  while True:
    try:
        conn, addr = sock.accept()
    except socket.timeout:
        continue
    return conn, addr

TCP_IP = ''
TCP_PORT = 5000

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(1)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)
print("Esperando conexao...")
try:
  conn, addr = accept(s)
  print ("IP conectado:", addr)
  while 1:
    sensor = read_sensor()
    val = sensor.encode()
    print(f"Enviando valor: {sensor}")
    conn.send(val)
    sleep(2)
except ConnectionAbortedError:
  print("Cliente encerrou conexao")
  s.close()
except KeyboardInterrupt:
  s.close()