import socket
import time

HOST = '192.168.0.2'     # Endereco IP do Servidor
PORT = 5000            # Porta que o Servidor esta
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
dest = (HOST, PORT)
try:
  s.connect(dest)
  print(f"Conectado com {dest}")
  while 1:
    message = s.recv(1024).decode() # Converte bytes para str, usando por padrao UTF-8
    if not message:
      print("Nada recebido, servidor deve ter fechado.\nTerminando conexao")
      s.close()
      break
    print(f"Recebeu {message}")
except ConnectionRefusedError:
  print("Falha ao conectar com servidor")
  s.close()
except KeyboardInterrupt:
  s.close()