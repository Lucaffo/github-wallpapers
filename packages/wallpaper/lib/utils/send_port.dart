/*
*   Send Port Class, a generic callback wrapper.
*
*   Luca Raffo @ 25/02/2025
*/ 
class SendPort<T> {
  Function(T)? port;
  
  SendPort(this.port);

  void send(T message) {
    if(port == null) return;
    port!(message);
  }
}
